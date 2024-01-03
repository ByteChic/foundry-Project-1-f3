// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {DeployFundMe} from "../../script/DeployFundeMe.s.sol";
import {WithdrawFundMe, FundFundME} from "../../script/Interaction.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/DeployFundeMe.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract IntegrationsTest is StdCheats, Test {
    FundMe public fundMe;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    function setUp() external {
        // DeployFundMe deployer = new DeployFundMe();
        // FundMe newFundMe = deployer.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundFundME fundFundMe = new FundFundME();
        fundFundMe.fundFundMe(address(fundMe));

        // Remove the line below to fix the problem of the unused local variable.
        // WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        WithdrawFundMe(payable(address(fundMe))).withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}