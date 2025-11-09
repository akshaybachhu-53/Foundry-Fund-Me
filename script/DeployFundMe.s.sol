// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address public deployer;

    constructor() {
        deployer = msg.sender;
    }

    function run() external returns (FundMe) {
        // Before startBroadcast -> Not a real tx foundry just gon'a simulate it
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        // After startBroadcast it is a real tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        console.log("Fund Me deployed at ", address(fundMe));
        vm.stopBroadcast();
        return fundMe;
    }
    // 0x694AA1769357215DE4FAC081bf1f309aDC325306
}
