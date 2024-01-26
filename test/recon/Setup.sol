
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";

import "src/TwapObserver.sol";
import "src/OPTIMIZED_RelativeTwapWeightedObserver.sol";
import "src/TwapWeightedObserver.sol";
import "src/INLINED_OPTIMIZED_RelativeTwapWeightedObserver.sol";
import "src/REFERENCE_RelativeTwapWeightedObserver.sol";
import "src/U72_OptimizedTwap.sol";
import "src/ExampleTwap.sol";

abstract contract Setup is BaseSetup {

    OPTIMIZED_RelativeTwapWeightedObserver oPTIMIZED_RelativeTwapWeightedObserver;
    REFERENCE_RelativeTwapWeightedObserver rEFERENCE_RelativeTwapWeightedObserver;

    function setup() internal virtual override {
      oPTIMIZED_RelativeTwapWeightedObserver = new OPTIMIZED_RelativeTwapWeightedObserver(); // TODO: Add parameters here
      rEFERENCE_RelativeTwapWeightedObserver = new REFERENCE_RelativeTwapWeightedObserver(); // TODO: Add parameters here
    }
}
