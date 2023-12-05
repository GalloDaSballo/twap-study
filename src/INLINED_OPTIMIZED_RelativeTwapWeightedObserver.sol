// SPDX-License Identifier: MIT
pragma solidity 0.8.17;

// NOTE: This is DANGEROUS unless you know exactly what you're doing
// NOTE: This is missing division, so this CAN overflow given sufficient time

contract INLINED_OPTIMIZED_RelativeTwapWeightedObserver {
    // NOTE: Packing manually is cheaper, but this is simpler for everyone to understand and follow
    struct PackedData {
        // Slot 0

        // Seconds in a year: 3.154e+7
        uint128 priceCumulative0; // 3.154e+7 * 80 * 100e27 = 2.5232e+38 | log_2(100e27 * 3.154e+7 * 80) = 127.568522171
        uint128 accumulator; // 3.154e+7 * 80 * 100e27 = 2.5232e+38 | log_2(100e27 * 3.154e+7 * 80) = 127.568522171
        // NOTE: We can further compress this slot but we will not be able to use only one (see u72 impl)
        /// So what's the point of making the code more complex?

        // Slot 1
        uint64 t0; // Thousands of Years, if we use relative time we can use u32 | Relative to deploy time (as immutable)
        uint64 lastUpdate; // Thousands of years
        // Expect eBTC debt to never surpass 100e27, which is 100 BILLION eBTC
        // log_2(100e27) = 96.3359147517 | log_2(100e27 / 1e18) = 36.5412090438
        // We could use a u64
        uint128 avgValue;
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
        data.accumulator += oldValue * (uint64(block.timestamp) - data.lastUpdate);
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

    function observeOptimized() external returns (uint256) {
        // Here, we need to apply the new accumulator to skew the price in some way
        // The weight of the skew should be proportional to the time passed
        uint64 deltaTime = uint64(block.timestamp) - data.t0;

        if (deltaTime == 0) {
            return data.avgValue;
        }

        // A reference period is 7 days
        // For each second passed after update
        // Let's virtally sync TWAP
        // With a weight, that is higher, the more time has passed

        // getLatestAccumulator -> return data.accumulator + (valueToTrack * (timeToAccrue()));
        // timeToAccrue -> uint64(block.timestamp) - data.lastUpdate;
        uint64 timeToAccrueCached = uint64(block.timestamp) - data.lastUpdate;
        uint128 latestAcc = data.accumulator + (valueToTrack * (timeToAccrueCached));

        // TODO: Maybe we can change this in case of overflow

        uint128 virtualAvgValue = (latestAcc - data.priceCumulative0) / (uint64(block.timestamp) - deltaTime);

        /// If more than PERIOD passed, we observe a new one
        // PERIOD is capped, so it's ok
        if (deltaTime > PERIOD) {
            // UpdateFromCachedLookup is inlined to save gas
            data.avgValue = virtualAvgValue;

            // Then we update
            data.priceCumulative0 = latestAcc;
            data.t0 = uint64(block.timestamp);

            // Return virtual
            return virtualAvgValue;
        }

        uint256 maxWeight = PERIOD;
        uint256 futureWeight = deltaTime;

        uint256 weightedAvg = data.avgValue * (maxWeight - futureWeight);
        uint256 weightedVirtual = virtualAvgValue * (futureWeight);

        // By definition SUM(maxWeight - futureWeight + futureWeight) = maxWeight
        uint256 weightedMean = (weightedAvg + weightedVirtual) / PERIOD;

        return weightedMean;
    }

    // Anybody can call this
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
