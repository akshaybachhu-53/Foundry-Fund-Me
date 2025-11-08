//SPDX-License-Identifier: MIT

// Deploy mocks on when we are on a local anvil chain
// Keep track of contract address across different chains
// Sepolia ETH/USD, Mainnet ETH/USD

pragma solidity ^0.8.30;
import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/Mockv3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // priceFeed Address
        return NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // priceFeed Address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // 1. Deploy and return mockAddress
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        // mockPriceFeed is a variable of type MockV3Aggregator (which is a contract type).
        // Every contract type in Solidity is actually a reference to a deployed contract on-chain,
        // not an address itself. PriceFeed must be of type address, not a contract reference.
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
