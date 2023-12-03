// SPDX-License Identifier: MIT

pragma solidity 0.8.17;

import {ExampleTwap} from "./ExampleTwap.sol";
import "forge-std/console2.sol";

// Optimized variant of the TWAP Observer
// Basically let's reset the cum0 each time
// And the t0
// Since we only need the delta
// This should: Prevent overflow barring insane minting
/// Allow us to pack "everything" in one slot?


// TODO: Before doing optimized, we should do a u256 version
// We can then differential fuzz the two
// With the constraint being max time (u64)
// And the total eBTC (100e27)
// if they behave in the same way for those scenarios, then we are comfy

contract RelativeTwapWeightedObserver {
    // last PriceCum
    // last T0

    // NOTE: Packing manually is cheaper, but this is simpler for everyone to understand and follow
    struct PackedData {
        uint128 priceCumulative0; // Divide the value by 5e19
        uint128 accumulator; // Divide the value by 5e19
        
        uint64 t0;
        uint64 lastUpdate;
        uint128 avgValue; // Expect eBTC debt to never surpass 100e27, which is 100 BILLION eBTC
    }

    PackedData data;

    // Insanely Packed
    // t0 could becomes epochs, cause we know it grows by weeks
    // But we may need remainder
    // So it would need to be 
    // NOTE: Packing manually is cheaper, but this is simpler for everyone to understand and follow
    struct ExtremelyPackedData {
        uint72 priceCumulative0; // Multiply the value by 1e18
        uint72 accumulator; // Multiply the value by 1e18
        uint32 t0; // 100 years left
        uint32 lastUpdate;
        uint48 avgValue; // // Multiply the value by 1e18
    }

   ExtremelyPackedData insaneMode;

   uint128 valueToTrack; // This would be totalSupply from ActivePool

    
    // ACC LOGIC //

    // Set to new value, sync accumulator to now with old value
    // Changes in same block have no impact, as no time has expired
    // Effectively we use the previous block value, and we magnify it by weight
    function setValue(uint128 newValue) external {
        _updateAcc(valueToTrack);

        data.lastUpdate = uint64(block.timestamp);
        data.accumulator = 0;
    }

    // Update the accumulator based on time passed
    function _updateAcc(uint128 oldValue) internal {    
        data.accumulator += oldValue * (timeToAccrue());
    }

    function timeToAccrue() public view returns (uint32) {
        return uint32(block.timestamp - data.lastUpdate);
    }

    // Return the update value to now
    function _syncToNow(uint128 oldValue) internal view returns (uint128) {
        return data.accumulator + (oldValue * (timeToAccrue()));
    }

    function getLatestAccumulator() public view returns (uint128) {
        return _syncToNow(valueToTrack);
    }

    // Value

    // priceCum0 / t0 is the old ACC
    // we need t0
    // New Acc (virtual)
    // Acc (Current)
    // Prev Value

    uint256 constant PERIOD = 7 days;

    // Relative Time

    // Relative Change

    constructor(uint128 initialValue) {

        data.priceCumulative0 = getLatestAccumulator();
        data.t0 = uint64(block.timestamp);
        data.avgValue = initialValue;
    }

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
        uint256 virtualAvgValue = (getLatestAccumulator() - data.priceCumulative0) / (block.timestamp - data.t0);

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

    function update() public returns (uint256) {
        // On epoch flip, we update as intended
        if (block.timestamp >= data.t0 + PERIOD) {
            // Compute based on delta
            data.avgValue = (getLatestAccumulator() - data.priceCumulative0) / (uint64(block.timestamp) - data.t0);

            // Then we update
            data.priceCumulative0 = getLatestAccumulator();
            data.t0 = uint64(block.timestamp);
        }
    }
}
