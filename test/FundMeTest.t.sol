// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundMe = new DeployFundMe(); // This is a DeployFundMe contract
        // This now has a FundMe contract because run() returns a FundMe contract
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        // assertEq(fundMe.MINIMUM_USD(), 6e18);// Failed
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        // assertEq(version, 6); // this is for mainnet
        assertEq(version, 4);
    }

    function testChainId() public view {
        console.log("Chain Id: ", block.chainid);
    }

    function testDeployFundMeOwner() public view {
        assertEq(deployFundMe.deployer(), address(this));
    }
}
