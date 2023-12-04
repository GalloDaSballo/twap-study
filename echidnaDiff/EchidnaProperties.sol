// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./crytic/Asserts.sol";
import "../src/OPTIMIZED_RelativeTwapWeightedObserver.sol";
import "../src/REFERENCE_RelativeTwapWeightedObserver.sol";


abstract contract EchidnaProperties is Asserts {
    // Contracts Variables
    // We deploy them
    OPTIMIZED_RelativeTwapWeightedObserver optimized;
    REFERENCE_RelativeTwapWeightedObserver base;

    // TargetContractSetup
    // Basically the deployment
    function _setUp() internal {
        optimized = new OPTIMIZED_RelativeTwapWeightedObserver(0);
        base = new REFERENCE_RelativeTwapWeightedObserver(0);
    }
}
