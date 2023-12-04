// SPDX-License Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/RelativeTwapWeightedObserver_Reference.sol";
import "src/RelativeTwapWeightedObserver_Optimized.sol";

contract ExampleTwapTest is Test {
    REFERENCE_RelativeTwapWeightedObserver twapReference;
    OPTIMIZED_RelativeTwapWeightedObserver twapOptimized;

    function setUp() public {
        twapReference = new REFERENCE_RelativeTwapWeightedObserver(0);
        twapOptimized = new OPTIMIZED_RelativeTwapWeightedObserver(0);
    }


    function _compare() internal {
      assertEq(twapReference.observe(), twapOptimized.observe(), "observe();");
      assertEq(twapReference.getRealValue(), twapOptimized.getRealValue(), "getRealValue();");
    }

    function testCompare(uint256 entropy, uint128 maxValue) public {
        uint256 startTime = block.timestamp;
        uint256 counter;
        while (entropy > 1_000) {
            vm.warp(startTime + 1 hours * counter++);
            twapReference.update();
            twapOptimized.update();
            uint256 currentChunk = entropy % 1_000;

            // 50% Higher | 50% Lower
            uint128 val = uint128(currentChunk * uint256(maxValue) / 500);

            twapReference.setValue(val);

            entropy /= 1_000;
        }
    }
}
