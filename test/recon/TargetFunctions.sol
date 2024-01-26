
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties, BeforeAfter {

    function oPTIMIZED_RelativeTwapWeightedObserver_observe() public {
      oPTIMIZED_RelativeTwapWeightedObserver.observe();
    }

    function oPTIMIZED_RelativeTwapWeightedObserver_setValue(uint128 newValue) public {
      oPTIMIZED_RelativeTwapWeightedObserver.setValue(newValue);
    }

    function oPTIMIZED_RelativeTwapWeightedObserver_update() public {
      oPTIMIZED_RelativeTwapWeightedObserver.update();
    }

    function rEFERENCE_RelativeTwapWeightedObserver_observe() public {
      rEFERENCE_RelativeTwapWeightedObserver.observe();
    }

    function rEFERENCE_RelativeTwapWeightedObserver_setValue(uint256 newValue) public {
      rEFERENCE_RelativeTwapWeightedObserver.setValue(newValue);
    }

    function rEFERENCE_RelativeTwapWeightedObserver_update() public {
      rEFERENCE_RelativeTwapWeightedObserver.update();
    }
}
