
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

abstract contract BeforeAfter is Setup {

    struct Vars {
        uint128 oPTIMIZED_RelativeTwapWeightedObserver_getLatestAccumulator;
        uint256 oPTIMIZED_RelativeTwapWeightedObserver_getRealValue;
        uint64 oPTIMIZED_RelativeTwapWeightedObserver_timeToAccrue;

        uint256 rEFERENCE_RelativeTwapWeightedObserver_accumulator;
        uint256 rEFERENCE_RelativeTwapWeightedObserver_getLatestAccumulator;
        uint256 rEFERENCE_RelativeTwapWeightedObserver_getRealValue;
        uint64 rEFERENCE_RelativeTwapWeightedObserver_lastUpdate;
        uint256 rEFERENCE_RelativeTwapWeightedObserver_timeToAccrue;
        uint256 rEFERENCE_RelativeTwapWeightedObserver_valueToTrack;
    }

    Vars internal _before;
    Vars internal _after;

    function __before() internal {
        _before.oPTIMIZED_RelativeTwapWeightedObserver_getLatestAccumulator = optimized.getLatestAccumulator();
        _before.oPTIMIZED_RelativeTwapWeightedObserver_getRealValue = optimized.getRealValue();
        _before.oPTIMIZED_RelativeTwapWeightedObserver_timeToAccrue = optimized.timeToAccrue();

        _before.rEFERENCE_RelativeTwapWeightedObserver_accumulator = standard.accumulator();
        _before.rEFERENCE_RelativeTwapWeightedObserver_getLatestAccumulator = standard.getLatestAccumulator();
        _before.rEFERENCE_RelativeTwapWeightedObserver_getRealValue = standard.getRealValue();
        _before.rEFERENCE_RelativeTwapWeightedObserver_lastUpdate = standard.lastUpdate();
        _before.rEFERENCE_RelativeTwapWeightedObserver_timeToAccrue = standard.timeToAccrue();
        _before.rEFERENCE_RelativeTwapWeightedObserver_valueToTrack = standard.valueToTrack();
    }

    function __after() internal {
        _after.oPTIMIZED_RelativeTwapWeightedObserver_getLatestAccumulator = optimized.getLatestAccumulator();
        _after.oPTIMIZED_RelativeTwapWeightedObserver_getRealValue = optimized.getRealValue();
        _after.oPTIMIZED_RelativeTwapWeightedObserver_timeToAccrue = optimized.timeToAccrue();

        _after.rEFERENCE_RelativeTwapWeightedObserver_accumulator = standard.accumulator();
        _after.rEFERENCE_RelativeTwapWeightedObserver_getLatestAccumulator = standard.getLatestAccumulator();
        _after.rEFERENCE_RelativeTwapWeightedObserver_getRealValue = standard.getRealValue();
        _after.rEFERENCE_RelativeTwapWeightedObserver_lastUpdate = standard.lastUpdate();
        _after.rEFERENCE_RelativeTwapWeightedObserver_timeToAccrue = standard.timeToAccrue();
        _after.rEFERENCE_RelativeTwapWeightedObserver_valueToTrack = standard.valueToTrack();
    }
}
