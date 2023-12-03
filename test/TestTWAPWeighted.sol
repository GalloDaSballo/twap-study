// SPDX-License Identifier: MIT

pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/ExampleTwap.sol";
import "src/TwapWeightedObserver.sol";
import "src/TwapObserver.sol";

contract ExampleTwapObserverTest is Test {
    ExampleTwap twapAcc;
    TwapWeightedObserver twapTesterWeighted;
    TwapObserver twapStepWise;

    function setUp() public {
        twapAcc = new ExampleTwap(0);
        twapTesterWeighted = new TwapWeightedObserver(address(twapAcc));
        twapStepWise = new TwapObserver(address(twapAcc));
    }

    function _log() internal {
        console2.log(block.timestamp, twapTesterWeighted.observe(), twapStepWise.observe(), twapAcc.getRealValue());
    }

    function testDebugObserverWeighted() public {
        uint256 ONE_HUNDRED = 100;
        uint256 ONE_WEEK = 1 weeks;

        vm.warp(10);
        twapAcc.setValue(ONE_HUNDRED);
        _moveForAnHourOverAWeekAndLog();
        twapAcc.setValue(ONE_HUNDRED * 50);
        _moveForAnHourOverAWeekAndLog();
        twapAcc.setValue(ONE_HUNDRED * 20);
        _moveForAnHourOverAWeekAndLog();
    }

    function _moveForAnHourOverAWeekAndLog() internal {
        uint256 startTime = block.timestamp;
        uint256 number_of_increases = 1 weeks / 1 hours;
        uint256 counter;

        while (counter < number_of_increases) {
            vm.warp(startTime + 1 hours * counter++);
            _log();
            twapTesterWeighted.update();
            twapStepWise.update();

            // Random Price change on each turn
            // Let's assume up to 1k times increase
            // and a decrease of up to 99%
            uint256 currentValue = twapAcc.getRealValue();
            uint256 prng = uint256(bytes32(keccak256(abi.encode(block.timestamp))));
            if (prng % 2 == 0) {
                if (currentValue > 10000) {
                    continue;
                }
                // Increase
                twapAcc.setValue(currentValue);
                uint256 increasePercent = prng / 10 % 100; // /10 so we don't re-use the same value
                twapAcc.setValue(currentValue + (currentValue * increasePercent / 100));
            } else {
                if (currentValue < 100) {
                    continue;
                }
                // Decrease
                uint256 decreasePercent = prng / 10 % 100 / 2; // / 2  as to avoid reducing to 1 all the time
                twapAcc.setValue(currentValue - (currentValue * decreasePercent / 100));
            }
        }
    }
}
