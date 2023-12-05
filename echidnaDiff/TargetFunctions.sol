// SPDX-License Identifier: MIT
pragma solidity 0.8.17;

// HEVM if you need pranking
// import "@crytic/properties/contracts/util/Hevm.sol";
import "./EchidnaProperties.sol";

abstract contract TargetFunctions is EchidnaProperties {
    function setValue(uint128 newValue) public {
        base.setValue(newValue);
        optimized.setValue(newValue);
    }

    function timeToAccrue() public {
        uint256 fromBase = base.timeToAccrue();
        uint256 fromOptimized = uint256(optimized.timeToAccrue());
        eq(fromBase, fromOptimized, "Observe");
    }

    function getRealValue() public {
        uint256 fromBase = base.getRealValue();
        uint256 fromOptimized = uint256(optimized.getRealValue());
        eq(fromBase, fromOptimized, "Observe");
    }

    function observe() external {
        uint256 fromBase = base.observe();
        uint256 fromOptimized = uint256(optimized.observe());
        eq(fromBase, fromOptimized, "Observe");
    }

    function update() public {
        base.update();
        optimized.update();
    }
}
