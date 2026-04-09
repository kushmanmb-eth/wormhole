// contracts/Getters.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IWormhole.sol";
import "./interfaces/IWETH.sol";

import "./BridgeState.sol";

contract BridgeGetters is BridgeState {
    function governanceActionIsConsumed(bytes32 hash) public view returns (bool) {
        return _state.consumedGovernanceActions[hash];
    }

    function isInitialized(address impl) public view returns (bool) {
        return _state.initializedImplementations[impl];
    }

    function isTransferCompleted(bytes32 hash) public view returns (bool) {
        return _state.completedTransfers[hash];
    }

    function wormhole() public view returns (IWormhole) {
        return IWormhole(_state.wormhole);
    }

    function chainId() public view returns (uint16){
        return _state.provider.chainId;
    }

    function evmChainId() public view returns (uint256) {
        return _state.evmChainId;
    }

    function isFork() public view returns (bool) {
        return evmChainId() != block.chainid;
    }

    function governanceChainId() public view returns (uint16){
        return _state.provider.governanceChainId;
    }

    function governanceContract() public view returns (bytes32){
        return _state.provider.governanceContract;
    }

    function wrappedAsset(uint16 tokenChainId, bytes32 tokenAddress) public view returns (address){
        return _state.wrappedAssets[tokenChainId][tokenAddress];
    }

    function bridgeContracts(uint16 chainId_) public view returns (bytes32){
        return _state.bridgeImplementations[chainId_];
    }

    function tokenImplementation() public view returns (address){
        return _state.tokenImplementation;
    }

    function WETH() public view returns (IWETH){
        return IWETH(_state.provider.WETH);
    }

    function outstandingBridged(address token) public view returns (uint256){
        return _state.outstandingBridged[token];
    }

    function isWrappedAsset(address token) public view returns (bool){
        return _state.isWrappedAsset[token];
    }

    function finality() public view returns (uint8) {
        return _state.provider.finality;
    }

    function isAuthorizedAddress(address addr) public view returns (bool) {
        return _state.authorizedAddresses[addr];
    }

    function isBlacklistedAddress(address addr) public view returns (bool) {
        return _state.blacklistedAddresses[addr];
    }

    function isMainnetChain() public view returns (bool) {
        // Check if current chain is a mainnet based on EVM chain ID
        // Ethereum mainnet = 1, BSC mainnet = 56, Polygon mainnet = 137, etc.
        uint256 currentChainId = block.chainid;
        return (
            currentChainId == 1 ||    // Ethereum mainnet
            currentChainId == 56 ||   // BSC mainnet  
            currentChainId == 137 ||  // Polygon mainnet
            currentChainId == 43114 || // Avalanche mainnet
            currentChainId == 250 ||  // Fantom mainnet
            currentChainId == 42161 || // Arbitrum One
            currentChainId == 10 ||   // Optimism mainnet
            currentChainId == 8453 || // Base mainnet
            currentChainId == 59144 || // Linea mainnet
            currentChainId == 534352 || // Scroll mainnet
            currentChainId == 81457 || // Blast mainnet
            currentChainId == 5000 || // Mantle mainnet
            currentChainId == 100 ||  // Gnosis Chain
            currentChainId == 1284 || // Moonbeam
            currentChainId == 1101 || // Polygon zkEVM
            currentChainId == 42220 || // Celo mainnet
            currentChainId == 1313161554 || // Aurora mainnet
            currentChainId == 8217 || // Klaytn mainnet
            currentChainId == 30 ||   // Rootstock mainnet
            currentChainId == 686 ||  // Karura mainnet
            currentChainId == 787 ||  // Acala mainnet
            currentChainId == 2222 || // Kava mainnet
            currentChainId == 1666600000 || // Harmony mainnet
            currentChainId == 1116 || // Core mainnet
            currentChainId == 42262 || // Oasis Emerald mainnet
            currentChainId == 288 ||  // Boba Network
            currentChainId == 324 ||  // zkSync Era
            currentChainId == 34443 || // Mode mainnet
            currentChainId == 480 || // World Chain mainnet
            currentChainId == 7777777 || // Zora mainnet
            currentChainId == 690 || // Redstone mainnet
            currentChainId == 255 || // Kroma mainnet
            currentChainId == 1329 // Sei mainnet
        );
    }

    /**
     * @notice Get bridge balance for tracking purposes.
     * @dev Useful for customer support to verify bridge state.
     * @param token The token address to check.
     * @return The balance of tokens held by this bridge contract.
     */
    function getBridgeBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * @notice Check the outstanding bridged amount for a native token.
     * @dev This helps track how many tokens are locked on this chain vs circulating on other chains.
     * @param token The native token address.
     * @return The amount of tokens bridged out to other chains (normalized to 8 decimals).
     */
    function getOutstandingBridged(address token) public view returns (uint256) {
        return outstandingBridged(token);
    }
}
