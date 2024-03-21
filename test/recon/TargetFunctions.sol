
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties, BeforeAfter {

    // Compare
    // Telling the fuzzer that the optimized must match the standard

    function oPTIMIZED_RelativeTwapWeightedObserver_observe() public {
      uint256 fromOptimized;
      uint256 fromStandard;
      bool optimizedRevert;
      bool standardRevert;

      try optimized.observe() returns (uint256 val) {
        fromOptimized = val;
      } catch {
        optimizedRevert = true;
      }

      try standard.observe() returns (uint256 val) {
        fromStandard = val;
      } catch {
        standardRevert = true;
      }

      t(fromOptimized == fromStandard, "must match");
      t(optimizedRevert == standardRevert, "must match revert");
    }

    function oPTIMIZED_RelativeTwapWeightedObserver_observeGasGrief(uint256 gas) public {
      standard.observe{gas: gas}(); // Only calls in which standard doesn't revert

      try optimized.observe{gas: gas}() {} catch {
        t(false, "Optimized fails when standard succeeds");
      }
      
    }


    function oPTIMIZED_RelativeTwapWeightedObserver_setValue(uint128 newValue) public {
      optimized.setValue(newValue);
    }

    function oPTIMIZED_RelativeTwapWeightedObserver_update() public {
      optimized.update();
    }


    function rEFERENCE_RelativeTwapWeightedObserver_setValue(uint256 newValue) public {
      standard.setValue(newValue);
    }

    function rEFERENCE_RelativeTwapWeightedObserver_update() public {
      standard.update();
    }
}
