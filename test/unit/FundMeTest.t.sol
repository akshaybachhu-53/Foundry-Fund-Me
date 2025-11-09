// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address USER = makeAddr("user"); //Don't make this as a constant, string acts like a seed for generating the address.
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundMe = new DeployFundMe(); // This is a DeployFundMe contract
        // This now has a FundMe contract because run() returns a FundMe contract
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // give user ETH if needed
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

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund(); // we sent 0 value so msg.value = 0 and < min. So, this reverts and test passes
    }

    // function testFundUpdatesFundedDataStructure() public {
    //     console.log("The address of caller of this function ",msg.sender);
    //     fundMe.fund{value:10e18}();// 10 ETH > $5
    //     // uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender); This fails
    //     uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
    //     assertEq(amountFunded, 10e18);
    //     console.log("Function caller ", msg.sender);
    // }
    function testFundUpdatesFundedDataStructure() public {
        console.log("Function caller ", msg.sender);
        console.log("User ", USER);
        // address user = address(0x123);
        vm.prank(USER); // next call comes from `user`
        fundMe.fund{value: SEND_VALUE}(); // inside FundMe, msg.sender == user

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
        console.log("Function caller at end ", msg.sender);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // This is a EOA 0x18..
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft(); // 1000
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // cost 200
        fundMe.withdraw();
        uint256 gasEnd = gasleft(); // 800
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
        // endingOwnerBalance = startingOwnerBalance + startingFundMeBalance - gasCost
        // gasCost = gasUsed * gasPrice
        // There’s no actual gas paid from the owner’s balance.
        //Gas usage is tracked,
        // But balances aren’t deducted for gas fees unless you explicitly simulate real gas spending
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank and vm.deal done by both forge standard hoax
            // we can generate address using address(i) like address(0). But we need to use uint160
            // If we want numbers to generate addresses the numbers should be uint160
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance; // This is a EOA 0x18..
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance; // This is a EOA 0x18..
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
}
