// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {KipuBankV3} from "../src/KipuBankV3.sol";

/**
 * @title DeployKipuBankV3
 * @notice Deployment script for KipuBankV3 with network-specific configurations
 * @dev Supports Tenderly Fork (Mainnet state) and Sepolia testnet
 */
contract DeployKipuBankV3 is Script {
    // Network identifiers
    uint256 constant MAINNET_CHAIN_ID = 1;
    uint256 constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant TENDERLY_FORK_CHAIN_ID = 1; // Tenderly fork uses mainnet chain ID

    // Mainnet addresses (for Tenderly Fork)
    address constant MAINNET_UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant MAINNET_UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant MAINNET_USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // Sepolia addresses
    address constant SEPOLIA_UNISWAP_V2_ROUTER = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
    address constant SEPOLIA_UNISWAP_V2_FACTORY = 0x7E0987E5b3a30e3f2828572Bb659A548460a3003;
    address constant SEPOLIA_USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    // Bank parameters
    uint256 constant WITHDRAWAL_LIMIT_USDC = 1_000 * 1e6; // 1,000 USDC
    uint256 constant BANK_CAP_USDC = 100_000 * 1e6; // 100,000 USDC

    function run() external returns (KipuBankV3) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=================================");
        console.log("KipuBankV3 Deployment Script");
        console.log("=================================");
        console.log("Deployer:", deployer);
        console.log("Chain ID:", block.chainid);
        console.log("");

        // Get network-specific addresses
        (
            address uniswapRouter,
            address uniswapFactory,
            address usdc,
            string memory networkName
        ) = getNetworkAddresses();

        console.log("Network:", networkName);
        console.log("Uniswap V2 Router:", uniswapRouter);
        console.log("Uniswap V2 Factory:", uniswapFactory);
        console.log("USDC:", usdc);
        console.log("");
        console.log("Bank Parameters:");
        console.log("- Withdrawal Limit:", WITHDRAWAL_LIMIT_USDC / 1e6, "USDC");
        console.log("- Bank Cap:", BANK_CAP_USDC / 1e6, "USDC");
        console.log("");

        vm.startBroadcast(deployerPrivateKey);

        KipuBankV3 bank = new KipuBankV3(
            WITHDRAWAL_LIMIT_USDC,
            BANK_CAP_USDC,
            uniswapRouter,
            uniswapFactory,
            usdc
        );

        vm.stopBroadcast();

        console.log("=================================");
        console.log("Deployment Successful!");
        console.log("=================================");
        console.log("KipuBankV3 deployed at:", address(bank));
        console.log("");
        console.log("Next steps:");
        console.log("1. Verify contract on explorer");
        console.log("2. Test deposits with ETH and USDC");
        console.log("3. Add additional tokens if needed");
        console.log("");
        console.log("Supported tokens by default:");
        console.log("- ETH (native)");
        console.log("- USDC");
        console.log("=================================");

        return bank;
    }

    /**
     * @notice Get network-specific addresses based on chain ID
     * @return uniswapRouter Uniswap V2 Router address
     * @return uniswapFactory Uniswap V2 Factory address
     * @return usdc USDC token address
     * @return networkName Human-readable network name
     */
    function getNetworkAddresses()
        internal
        view
        returns (
            address uniswapRouter,
            address uniswapFactory,
            address usdc,
            string memory networkName
        )
    {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            return (
                SEPOLIA_UNISWAP_V2_ROUTER,
                SEPOLIA_UNISWAP_V2_FACTORY,
                SEPOLIA_USDC,
                "Sepolia Testnet"
            );
        } else if (block.chainid == MAINNET_CHAIN_ID || isTenderlyFork()) {
            return (
                MAINNET_UNISWAP_V2_ROUTER,
                MAINNET_UNISWAP_V2_FACTORY,
                MAINNET_USDC,
                isTenderlyFork() ? "Tenderly Fork (Mainnet)" : "Ethereum Mainnet"
            );
        } else {
            revert("Unsupported network");
        }
    }

    /**
     * @notice Detect if running on Tenderly Fork
     * @dev Checks for TENDERLY_RPC environment variable
     * @return True if Tenderly Fork detected
     */
    function isTenderlyFork() internal view returns (bool) {
        try vm.envString("TENDERLY_RPC") returns (string memory rpc) {
            return bytes(rpc).length > 0;
        } catch {
            return false;
        }
    }
}
