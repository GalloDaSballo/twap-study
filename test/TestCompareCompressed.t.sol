// SPDX-License Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/REFERENCE_RelativeTwapWeightedObserver.sol";
import "src/U72_OptimizedTwap.sol";

contract ExampleTwapTest is Test {
    REFERENCE_RelativeTwapWeightedObserver twapReference;
    U72_OptimizedTwap twapOptimizedInlined;

    function setUp() public {
        twapReference = new REFERENCE_RelativeTwapWeightedObserver(0);
        twapOptimizedInlined = new U72_OptimizedTwap(0);
    }

    function _compare() internal {
        // Same within 1e18 order
        assertApproxEqAbs(twapReference.observe() / 1e18 * 1e18, uint256(twapOptimizedInlined.observe()) / 1e18 * 1e18, 1e18, "BROKEN_OBSERVE");
        assertEq(twapReference.getRealValue(), twapOptimizedInlined.getRealValue(), "BROKEN_REAL_VALUE");

        console2.log(twapReference.timeToAccrue(), uint256(twapOptimizedInlined.timeToAccrue()), "timeToAccrue();");
        console2.log(twapReference.observe(), twapOptimizedInlined.observe(), "observe()");
        console2.log(twapReference.getRealValue(), twapOptimizedInlined.getRealValue(), "getRealValue();");
    }

    function testCompareCompressed(uint256 entropy, uint128 maxValue) public {
        uint256 startTime = block.timestamp;
        uint256 counter;
        while (entropy > 1_000) {
            _compare();
            vm.warp(startTime + 1 days * counter++);
            twapReference.update();
            twapOptimizedInlined.update();
            uint256 currentChunk = entropy % 1_000;

            // 50% Higher | 50% Lower
            uint128 val = uint128(currentChunk * uint256(maxValue) / 500) % 1e27; // Cap

            twapReference.setValue(val);
            twapOptimizedInlined.setValue(val);

            entropy /= 1_000;
        }
    }
}
