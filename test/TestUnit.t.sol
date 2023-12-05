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

    function testAveragePriceIsPriceIfOnlyPrice(uint256 initialPrice) public {
      
    }

    function testAveragePriceInHalfIfHalfTheWeight(uint128 initialPrice, uint128 secondPrice) public {
      // One week as X

      // One week as Y

      // AVG is half
    }


}