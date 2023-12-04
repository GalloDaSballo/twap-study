// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./TargetFunctions.sol";
import "./EchidnaAsserts.sol";
import "./crytic/hevm.sol";

/// 100% Boilerplate

contract EchidnaTester is TargetFunctions, EchidnaAsserts {
    constructor() payable {
        _setUp();
    }
}
