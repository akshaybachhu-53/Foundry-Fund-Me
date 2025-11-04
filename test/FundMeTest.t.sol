// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        // assertEq(fundMe.MINIMUM_USD(), 6e18);// Failed
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        assertEq(fundMe.i_owner(), address(this));
    }

    // function testPriceFeedVersionIsAccurate() public view {
    //     uint256 version = fundMe.getVersion();
    //     assertEq(version, 4);
    // }

    function testChainId() public view {
        console.log("Chain Id: ", block.chainid);
    }
}
