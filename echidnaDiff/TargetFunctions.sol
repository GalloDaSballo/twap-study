// SPDX-License Identifier: MIT
pragma solidity 0.8.17;

// HEVM if you need pranking
// import "@crytic/properties/contracts/util/Hevm.sol";
import "./EchidnaProperties.sol";

abstract contract TargetFunctions is EchidnaProperties {


    // log_2(100e27) == 96.X
    function setValue(uint104 newValue) public {
        bool baseSuccess;
        try base.setValue(newValue) {
            baseSuccess = true;
        } catch (bytes memory err) {
            
        }

        // if optimized reverts, then base must have reverted as well
        try optimized.setValue(newValue) {
            t(baseSuccess, "Both must succeed");
        } catch (bytes memory err) {
            t(!baseSuccess, "Must both revert");
        }
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
        uint256 fromBase;
        uint256 fromOptimized;
        
        bool baseSuccess;

        try base.observe() returns (uint256 baseV) {
            baseSuccess = true;
            fromBase = baseV;
        } catch (bytes memory err) {
            
        }

        // if optimized reverts, then base must have reverted as well
        try optimized.observe() returns (uint256 baseV) {
             fromOptimized = baseV;
        } catch (bytes memory err) {
            t(!baseSuccess, "Must both revert");
        }

        eq(fromBase, fromOptimized, "Observe");
    }

    function update() public {
        base.update();
        optimized.update();
    }
}
