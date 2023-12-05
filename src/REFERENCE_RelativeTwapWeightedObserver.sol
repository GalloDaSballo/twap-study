// SPDX-License Identifier: MIT
pragma solidity 0.8.17;

contract REFERENCE_RelativeTwapWeightedObserver {
    constructor(uint256 initialValue) {
        // Update to last value from beginning
        // The first value is basically insanely strong
        valueToTrack = initialValue;
        accumulator = 0 * block.timestamp;

        priceCum0 = getLatestAccumulator();
        t0 = block.timestamp;
        avgValue = getRealValue();
        lastUpdate = uint64(block.timestamp);
    }

    /// TWAP ///

    uint256 public accumulator;
    uint64 public lastUpdate;

    uint256 public valueToTrack; // Would be Total Debt from AP

    // Set to new value, sync accumulator to now with old value
    // Changes in same block have no impact, as no time has expired
    // Effectively we use the previous block value, and we magnify it by weight
    function setValue(uint256 newValue) public {
        _updateAcc(valueToTrack);

        lastUpdate = uint64(block.timestamp);
        valueToTrack = newValue;
    }

    // Update the accumulator based on time passed
    function _updateAcc(uint256 oldValue) internal {
        accumulator += oldValue * (timeToAccrue());
    }

    function timeToAccrue() public view returns (uint256) {
        return block.timestamp - lastUpdate;
    }

    // Return the update value to now
    function _syncToNow() internal view returns (uint256) {
        return accumulator + (valueToTrack * (timeToAccrue()));
    }

    // == Getters == //
    function getRealValue() public view returns (uint256) {
        return valueToTrack;
    }

    function getLatestAccumulator() public view returns (uint256) {
        return _syncToNow();
    }

    /// END TWAP ///

    /// TWAP WEIGHTED OBSERVER ///
    uint256 priceCum0;
    uint256 t0;
    uint256 avgValue;

    uint256 constant PERIOD = 7 days;

    // Look at last
    // Linear interpolate (or prob TWAP already does that for you)

    function observe() external returns (uint256) {
        // Here, we need to apply the new accumulator to skew the price in some way
        // The weight of the skew should be proportional to the time passed

        if (block.timestamp - t0 == 0) {
            return avgValue;
        }

        // A reference period is 7 days
        // For each second passed after update
        // Let's virtally sync TWAP
        // With a weight, that is higher, the more time has passed
        uint256 virtualAvgValue = (getLatestAccumulator() - priceCum0) / (block.timestamp - t0);

        uint256 futureWeight = block.timestamp - t0;
        uint256 maxWeight = PERIOD;

        if (futureWeight > maxWeight) {
            update(); // May as well update
            // Return virtual
            return virtualAvgValue;
        }

        uint256 weightedAvg = avgValue * (maxWeight - futureWeight);
        uint256 weightedVirtual = virtualAvgValue * (futureWeight);

        uint256 weightedMean = (weightedAvg + weightedVirtual) / PERIOD;

        return weightedMean;
    }

    function update() public {
        // On epoch flip, we update as intended
        if (block.timestamp >= t0 + PERIOD) {
            // Compute based on delta
            avgValue = (getLatestAccumulator() - priceCum0) / (block.timestamp - t0);

            // Then we update
            priceCum0 = getLatestAccumulator();
            t0 = block.timestamp;
        }
    }

    /// END TWAP WEIGHTED OBSERVER ///
}
