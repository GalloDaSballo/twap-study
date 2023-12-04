// SPDX-License Identifier: MIT
pragma solidity 0.8.17;

contract OPTIMIZED_RelativeTwapWeightedObserver {
    // NOTE: Packing manually is cheaper, but this is simpler for everyone to understand and follow
    struct PackedData {
        uint128 priceCumulative0; // Divide the value by 5e19
        uint128 accumulator; // Divide the value by 5e19
        uint64 t0;
        uint64 lastUpdate;
        uint128 avgValue; // Expect eBTC debt to never surpass 100e27, which is 100 BILLION eBTC
    }

    PackedData data;

    uint128 valueToTrack; // Not packed

    constructor(uint128 initialValue) {
        PackedData memory cachedData = PackedData({
            priceCumulative0: initialValue,
            accumulator: initialValue,
            t0: uint64(block.timestamp),
            lastUpdate: uint64(block.timestamp),
            avgValue: initialValue
        });

        valueToTrack = initialValue;

        data = cachedData;
    }

    /// TWAP ///

    // Set to new value, sync accumulator to now with old value
    // Changes in same block have no impact, as no time has expired
    // Effectively we use the previous block value, and we magnify it by weight
    function setValue(uint128 newValue) public {
        _updateAcc(valueToTrack);

        data.lastUpdate = uint64(block.timestamp);
        valueToTrack = newValue;
    }

    // TODO: Most likely best to read as struct, which requires further refactoring

    // Update the accumulator based on time passed
    function _updateAcc(uint128 oldValue) internal {
        data.accumulator += oldValue * (timeToAccrue());
    }

    // Safe for Tens of Thousand of Years
    function timeToAccrue() public view returns (uint64) {
        return uint64(block.timestamp) - data.lastUpdate;
    }

    // Return the update value to now
    function _syncToNow() internal view returns (uint128) {
        return data.accumulator + (valueToTrack * (timeToAccrue()));
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
        // Here, we need to apply the new accumulator to skew the price in some way
        // The weight of the skew should be proportional to the time passed
        if (block.timestamp - data.t0 == 0) {
            return data.avgValue;
        }

        // A reference period is 7 days
        // For each second passed after update
        // Let's virtally sync TWAP
        // With a weight, that is higher, the more time has passed
        uint256 virtualAvgValue = (getLatestAccumulator() - data.priceCumulative0) / (uint64(block.timestamp) - data.t0);

        uint256 futureWeight = block.timestamp - data.t0;
        uint256 maxWeight = PERIOD;

        if (futureWeight > maxWeight) {
            update(); // May as well update
            // Return virtual
            return virtualAvgValue;
        }

        uint256 weightedAvg = data.avgValue * (maxWeight - futureWeight);
        uint256 weightedVirtual = virtualAvgValue * (futureWeight);

        uint256 weightedMean = (weightedAvg + weightedVirtual) / PERIOD;

        return weightedMean;
    }

    function update() public {
        // On epoch flip, we update as intended
        if (block.timestamp >= data.t0 + PERIOD) {
            // Compute based on delta
            data.avgValue = (getLatestAccumulator() - data.priceCumulative0) / (uint64(block.timestamp) - data.t0);

            // Then we update
            data.priceCumulative0 = getLatestAccumulator();
            data.t0 = uint64(block.timestamp);
        }
    }

    /// END TWAP WEIGHTED OBSERVER ///
}
