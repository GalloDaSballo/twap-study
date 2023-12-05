// SPDX-License Identifier: MIT
pragma solidity 0.8.17;

// This is experimental, DO NOT USE UNDER ANY CIRCUMNSTANCE!!!!
import "forge-std/console2.sol";

contract U72_OptimizedTwap {
    // Insanely Packed
    // t0 could becomes epochs, cause we know it grows by weeks
    // But we may need remainder
    // So it would need to be
    // NOTE: Packing manually is cheaper, but this is simpler for everyone to understand and follow
    struct ExtremelyPackedData {
        uint72 compressedPriceCumulative0; // Multiply the value by 1e18
        uint72 compressedAccumulator; // Multiply the value by 1e18
        uint32 t0; // 100 years left | NOTE: We can offset by an immutable to pack this
        uint32 lastUpdate; // 100 years left | NOTE: We can offset by an immutable to pack this
        uint48 compressedAvgValue; // // Multiply the value by 1e18
    }

    ExtremelyPackedData data;

    uint128 valueToTrack; // Not packed

    /**
     * LOG MATH
     *     log_2(1e18) = 59.794705708
     *     log_2(1e27) = 89.692058562 // Max supply of eBTC (100 BILLION with 18 decimals!!)
     *     log_2(1e27 / 1e18) = 29.897352854 // Max supply of eBTC (100 BILLION with 18 decimals!!)
     *
     *     100 years (time limitation)
     *     3.154e+7
     *
     *     log_2(1e27 * 100 * 3.154e+7) = 121.246594076
     *     log_2(1e27 * 100  * 3.154e+7 / 1e18) = 61.4518883681
     *
     *     Losing precision by up to 1 eBTC halves the bits we need
     */

    uint72 constant SCALE_MULTIPLIER = 1e18;

    // Given a u128, divide by 1e18
    function _applyCompressionToU72(uint128 number) public pure returns (uint72) {
        // TODO: Run Invariant to prove it never overflows
        return uint72(number / SCALE_MULTIPLIER);
    }

    function _applyCompressionToU48(uint128 number) public pure returns (uint48) {
        // TODO: Run Invariant to prove it never overflows
        return uint48(number / SCALE_MULTIPLIER);
    }

    // Given a u72, multiply by 1e18
    function _undoCompressionFromU72(uint72 number) public pure returns (uint128) {
        // TODO: Run Invariant to prove it never overflows
        return uint128(number) * uint128(SCALE_MULTIPLIER);
    }

    function _undoCompressionFromU48(uint48 number) public pure returns (uint128) {
        // TODO: Run Invariant to prove it never overflows
        return uint128(number) * uint128(SCALE_MULTIPLIER);
    }

    constructor(uint128 initialValue) {
        ExtremelyPackedData memory cachedData = ExtremelyPackedData({
            compressedPriceCumulative0: _applyCompressionToU72(initialValue),
            compressedAccumulator: _applyCompressionToU72(initialValue),
            t0: uint32(block.timestamp),
            lastUpdate: uint32(block.timestamp),
            compressedAvgValue: _applyCompressionToU48(initialValue)
        });

        valueToTrack = initialValue; // Never packed because it's from CDP System

        data = cachedData;
    }

    /// TWAP ///

    // Set to new value, sync compressedAccumulator to now with old value
    // Changes in same block have no impact, as no time has expired
    // Effectively we use the previous block value, and we magnify it by weight
    function setValue(uint128 newValue) public {
        _updateAcc(valueToTrack);

        data.lastUpdate = uint32(block.timestamp);
        valueToTrack = newValue;
    }

    // TODO: Most likely best to read as struct, which requires further refactoring

    // Update the compressedAccumulator based on time passed
    function _updateAcc(uint128 oldValue) internal {
        data.compressedAccumulator += _applyCompressionToU72(oldValue * (timeToAccrue()));
    }

    // Safe for Tens of Thousand of Years
    function timeToAccrue() public view returns (uint32) {
        return uint32(block.timestamp) - data.lastUpdate;
    }

    // Return the update value to now
    function _syncToNow() internal view returns (uint128) {
        // TODO: Am I supposed to compress the value? Pretty sure it causes further loss
        console2.log("_syncToNow");

        uint128 uncompressedAccumulator =_undoCompressionFromU72(data.compressedAccumulator);
        console2.log("_syncToNow 1");
        uint128 toAddUncompressed = valueToTrack * timeToAccrue();
        console2.log("_syncToNow 2");

        uint128 sum = uncompressedAccumulator + toAddUncompressed;
        console2.log("_syncToNow 3");
        
        return sum;
    }

    // == Getters == //
    function getRealValue() public view returns (uint256) {
        return valueToTrack;
    }

    function getLatestAccumulator() public view returns (uint128) {
        return _syncToNow();
    }

    /// END TWAP ///

    /// TWAP WEIGHTED OBSERVER ///
    uint256 constant PERIOD = 7 days;

    // Look at last
    // Linear interpolate (or prob TWAP already does that for you)

    function observe() external returns (uint256) {
        // Here, we need to apply the new compressedAccumulator to skew the price in some way
        // The weight of the skew should be proportional to the time passed
        if (block.timestamp - data.t0 == 0) {
            return _undoCompressionFromU72(data.compressedAvgValue);
        }
        console2.log("1");

        // A reference period is 7 days
        // For each second passed after update
        // Let's virtally sync TWAP
        // With a weight, that is higher, the more time has passed
        uint256 diffAcc = getLatestAccumulator() - _undoCompressionFromU72(data.compressedPriceCumulative0);
        console2.log("92");
        uint256 virtualAvgValue = (diffAcc)
            / (uint32(block.timestamp) - data.t0);
        console2.log("2");

        uint256 futureWeight = block.timestamp - data.t0;
        console2.log("3");
        uint256 maxWeight = PERIOD;

        if (futureWeight > maxWeight) {
            console2.log("4");
            update(); // May as well update
            // Return virtual
            return virtualAvgValue;
        }

        console2.log("9");
        uint256 weightedAvg = _undoCompressionFromU72(data.compressedAvgValue) * (maxWeight - futureWeight);
        console2.log("10");
        uint256 weightedVirtual = virtualAvgValue * (futureWeight);

        uint256 weightedMean = (weightedAvg + weightedVirtual) / PERIOD;

        return weightedMean;
    }

    function update() public {
        // On epoch flip, we update as intended
        if (block.timestamp >= data.t0 + PERIOD) {
            console2.log("5");
            // Compute based on delta
            data.compressedAvgValue = _applyCompressionToU48(
                (getLatestAccumulator() - _undoCompressionFromU72(data.compressedPriceCumulative0))
                    / (uint32(block.timestamp) - data.t0)
            );
            console2.log("6");

            // Then we update
            data.compressedPriceCumulative0 = _applyCompressionToU72(getLatestAccumulator());
            console2.log("7");
            data.t0 = uint32(block.timestamp);
            console2.log("8");
        }
    }

    /// END TWAP WEIGHTED OBSERVER ///
}
