
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
        _before.oPTIMIZED_RelativeTwapWeightedObserver_getLatestAccumulator = oPTIMIZED_RelativeTwapWeightedObserver.getLatestAccumulator();
        _before.oPTIMIZED_RelativeTwapWeightedObserver_getRealValue = oPTIMIZED_RelativeTwapWeightedObserver.getRealValue();
        _before.oPTIMIZED_RelativeTwapWeightedObserver_timeToAccrue = oPTIMIZED_RelativeTwapWeightedObserver.timeToAccrue();

        _before.rEFERENCE_RelativeTwapWeightedObserver_accumulator = rEFERENCE_RelativeTwapWeightedObserver.accumulator();
        _before.rEFERENCE_RelativeTwapWeightedObserver_getLatestAccumulator = rEFERENCE_RelativeTwapWeightedObserver.getLatestAccumulator();
        _before.rEFERENCE_RelativeTwapWeightedObserver_getRealValue = rEFERENCE_RelativeTwapWeightedObserver.getRealValue();
        _before.rEFERENCE_RelativeTwapWeightedObserver_lastUpdate = rEFERENCE_RelativeTwapWeightedObserver.lastUpdate();
        _before.rEFERENCE_RelativeTwapWeightedObserver_timeToAccrue = rEFERENCE_RelativeTwapWeightedObserver.timeToAccrue();
        _before.rEFERENCE_RelativeTwapWeightedObserver_valueToTrack = rEFERENCE_RelativeTwapWeightedObserver.valueToTrack();
    }

    function __after() internal {
        _after.oPTIMIZED_RelativeTwapWeightedObserver_getLatestAccumulator = oPTIMIZED_RelativeTwapWeightedObserver.getLatestAccumulator();
        _after.oPTIMIZED_RelativeTwapWeightedObserver_getRealValue = oPTIMIZED_RelativeTwapWeightedObserver.getRealValue();
        _after.oPTIMIZED_RelativeTwapWeightedObserver_timeToAccrue = oPTIMIZED_RelativeTwapWeightedObserver.timeToAccrue();

        _after.rEFERENCE_RelativeTwapWeightedObserver_accumulator = rEFERENCE_RelativeTwapWeightedObserver.accumulator();
        _after.rEFERENCE_RelativeTwapWeightedObserver_getLatestAccumulator = rEFERENCE_RelativeTwapWeightedObserver.getLatestAccumulator();
        _after.rEFERENCE_RelativeTwapWeightedObserver_getRealValue = rEFERENCE_RelativeTwapWeightedObserver.getRealValue();
        _after.rEFERENCE_RelativeTwapWeightedObserver_lastUpdate = rEFERENCE_RelativeTwapWeightedObserver.lastUpdate();
        _after.rEFERENCE_RelativeTwapWeightedObserver_timeToAccrue = rEFERENCE_RelativeTwapWeightedObserver.timeToAccrue();
        _after.rEFERENCE_RelativeTwapWeightedObserver_valueToTrack = rEFERENCE_RelativeTwapWeightedObserver.valueToTrack();
    }
}
