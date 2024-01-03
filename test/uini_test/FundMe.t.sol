// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundeMe.s.sol";
import "forge-std/console.sol";

contract FundME is Test {
    uint256 constant sendvalue = 0.1 ether;
    uint256 constant statring = 10 ether;
    uint256 constant gasPrice = 1 ether;
    address USER = makeAddr("user");
    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, statring);
    }

    function testminimumDollarisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisMsgSendewr() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAggregatorVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: sendvalue}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, sendvalue);
    }

    function testAddsFunderToarrayofFunder() public {
        vm.prank(USER);
        fundMe.fund{value: sendvalue}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: sendvalue}();
        _;
    }

    function testOntyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFUnder() public funded {
        //Arrange
        uint256 StartingOwnerBalance = fundMe.getOwner().balance;
        uint256 StartingFunderBalance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        // uint endingFunderBalance = address(fundMe).balance;
        // assertEq(endingOwnerBalance, 0);
        assertEq(StartingOwnerBalance + StartingFunderBalance, endingOwnerBalance);
    }

    function testWithdrawFomMultiplleFUnder() public funded {
        uint160 numderOfFunder = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numderOfFunder; i++) {
            hoax(address(i), sendvalue);
            fundMe.fund{value: sendvalue}();
        }
        uint256 StartingOwnerBalance = fundMe.getOwner().balance;
        uint256 StartingFunderBalance = address(fundMe).balance;
        uint256 gasStart = gasleft();
        vm.txGasPrice(gasPrice);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gasUsed", gasUsed);
        vm.stopPrank();
        //Assert:
        assertEq(address(fundMe).balance, 0);
        assertEq(StartingOwnerBalance + StartingFunderBalance, fundMe.getOwner().balance);
    }

    function testWithdrawFomMultiplleFUnderCheaperWithdraw() public funded {
        uint160 numderOfFunder = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numderOfFunder; i++) {
            hoax(address(i), sendvalue);
            fundMe.fund{value: sendvalue}();
        }
        uint256 StartingOwnerBalance = fundMe.getOwner().balance;
        uint256 StartingFunderBalance = address(fundMe).balance;
        uint256 gasStart = gasleft();
        vm.txGasPrice(gasPrice);
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("gasUsed", gasUsed);
        vm.stopPrank();
        //Assert:
        assertEq(address(fundMe).balance, 0);
        assertEq(StartingOwnerBalance + StartingFunderBalance, fundMe.getOwner().balance);
    }
}
