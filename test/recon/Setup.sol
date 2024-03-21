
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

    OPTIMIZED_RelativeTwapWeightedObserver optimized;
    REFERENCE_RelativeTwapWeightedObserver standard;

    function setup() internal virtual override {
      optimized = new OPTIMIZED_RelativeTwapWeightedObserver(0); // TODO: Add parameters here
      standard = new REFERENCE_RelativeTwapWeightedObserver(0); // TODO: Add parameters here
    }
}
