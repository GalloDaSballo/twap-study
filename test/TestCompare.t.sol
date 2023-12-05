// SPDX-License Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/REFERENCE_RelativeTwapWeightedObserver.sol";
import "src/OPTIMIZED_RelativeTwapWeightedObserver.sol";
import "src/INLINED_OPTIMIZED_RelativeTwapWeightedObserver.sol";

contract ExampleTwapTest is Test {
    REFERENCE_RelativeTwapWeightedObserver twapReference;
    OPTIMIZED_RelativeTwapWeightedObserver twapOptimized;
    INLINED_OPTIMIZED_RelativeTwapWeightedObserver twapOptimizedInlined;

    function setUp() public {
        twapReference = new REFERENCE_RelativeTwapWeightedObserver(0);
        twapOptimized = new OPTIMIZED_RelativeTwapWeightedObserver(0);
        twapOptimizedInlined = new INLINED_OPTIMIZED_RelativeTwapWeightedObserver(0);
    }

    function _compare() internal {
        assertEq(twapReference.observe(), twapOptimized.observe(), "observe();");
        assertEq(twapReference.observe(), twapOptimizedInlined.observeOptimized(), "observe();");
        assertEq(twapReference.getRealValue(), twapOptimized.getRealValue(), "getRealValue();");
        assertEq(twapReference.getRealValue(), twapOptimizedInlined.getRealValue(), "getRealValue();");

        console2.log(
            twapReference.timeToAccrue(),
            twapOptimized.timeToAccrue(),
            twapOptimizedInlined.timeToAccrue(),
            "timeToAccrue();"
        );
        console2.log(
            twapReference.getRealValue(),
            twapOptimized.getRealValue(),
            twapOptimizedInlined.getRealValue(),
            "getRealValue();"
        );
    }

    function testCompare(uint256 entropy, uint128 maxValue) public {
        uint256 startTime = block.timestamp;
        uint256 counter;
        while (entropy > 1_000) {
            _compare();
            vm.warp(startTime + 1 weeks * counter++);
            twapReference.update();
            twapOptimized.update();
            twapOptimizedInlined.update();
            uint256 currentChunk = entropy % 1_000;

            // 50% Higher | 50% Lower
            uint128 val = uint128(currentChunk * uint256(maxValue) / 500) % 1e27; // Cap

            twapReference.setValue(val);
            twapOptimized.setValue(val);
            twapOptimizedInlined.setValue(val);

            entropy /= 1_000;
        }
    }
}
