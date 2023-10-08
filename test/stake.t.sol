// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {Test, console2} from "forge-std/Test.sol";
import {StakingContract} from "../src/swapingContract.sol";
import "../src/TokenEKoh.sol";
import "../src/ReceiptToken.sol";

contract StakingTest is Test {
    StakingContract public staking;
    ReceiptToken public receiptToken;
    EkohMoney public ekohToken;

    address WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    StakingContract.Stake public stakeStruct;

    function setUp() public {
        receiptToken = new ReceiptToken();
        ekohToken = new EkohMoney();
        staking = new StakingContract(
            address(ekohToken),
            address(receiptToken),
            WETH_ADDRESS
        );

        stakeStruct = StakingContract.Stake({
            initialAmount: 0,
            stakingTime: block.timestamp
        });
    }

    function testStake() public {
        vm.expectRevert("Must stake some ETH");
        staking.stake{value: 0}();
    }

    function testFailStakeSuccess() public {
        staking.stake{value: 1 ether}();
    }

    function testClaimYield() public {
        vm.expectRevert("Staking duration not reached");
        staking.claimYield();
    }

    function testClaimYieldNotTime() public payable {
        staking.stake{value: 1 ether}();
        // StakingContract.Stake(1,block.timestamp);
        stakeStruct.initialAmount = 1 ether;
        vm.expectRevert("Staking duration not reached");
        staking.claimYield();
    }

    function testClaimNoYield() public {
        staking.stake{value: 1 ether}();
        stakeStruct.initialAmount = 1 ether;
        vm.expectRevert("No yield to claim");
    }
}