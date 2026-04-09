// contracts/Setters.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.0;

import "./BridgeState.sol";

contract BridgeSetters is BridgeState {
    function setInitialized(address implementatiom) internal {
        _state.initializedImplementations[implementatiom] = true;
    }

    function setGovernanceActionConsumed(bytes32 hash) internal {
        _state.consumedGovernanceActions[hash] = true;
    }

    function setTransferCompleted(bytes32 hash) internal {
        _state.completedTransfers[hash] = true;
    }

    function setChainId(uint16 chainId) internal {
        _state.provider.chainId = chainId;
    }

    function setGovernanceChainId(uint16 chainId) internal {
        _state.provider.governanceChainId = chainId;
    }

    function setGovernanceContract(bytes32 governanceContract) internal {
        require(governanceContract != bytes32(0), "governance contract cannot be zero address");
        _state.provider.governanceContract = governanceContract;
    }

    function setBridgeImplementation(uint16 chainId, bytes32 bridgeContract) internal {
        _state.bridgeImplementations[chainId] = bridgeContract;
    }

    function setTokenImplementation(address impl) internal {
        require(impl != address(0), "invalid implementation address");
        _state.tokenImplementation = impl;
    }

    function setWETH(address weth) internal {
        require(weth != address(0), "invalid WETH address");
        _state.provider.WETH = weth;
    }

    function setWormhole(address wh) internal {
        require(wh != address(0), "invalid wormhole address");
        _state.wormhole = payable(wh);
    }

    function setWrappedAsset(uint16 tokenChainId, bytes32 tokenAddress, address wrapper) internal {
        _state.wrappedAssets[tokenChainId][tokenAddress] = wrapper;
        _state.isWrappedAsset[wrapper] = true;
    }

    function setOutstandingBridged(address token, uint256 outstanding) internal {
        _state.outstandingBridged[token] = outstanding;
    }

    function setFinality(uint8 finality) internal {
        _state.provider.finality = finality;
    }

    function setEvmChainId(uint256 evmChainId) internal {
        require(evmChainId == block.chainid, "invalid evmChainId");
        _state.evmChainId = evmChainId;
    }

    function setAuthorizedAddress(address addr, bool authorized) internal {
        require(addr != address(0), "invalid address");
        // Only allow authorization on mainnet chains
        require(isMainnetChain(), "authorized addresses only allowed on mainnet");
        _state.authorizedAddresses[addr] = authorized;
    }

    function isMainnetChain() internal view returns (bool) {
        // Check if current chain is a mainnet based on EVM chain ID
        // Ethereum mainnet = 1, BSC mainnet = 56, Polygon mainnet = 137, etc.
        uint256 chainId = block.chainid;
        return (
            chainId == 1 ||    // Ethereum mainnet
            chainId == 56 ||   // BSC mainnet  
            chainId == 137 ||  // Polygon mainnet
            chainId == 43114 || // Avalanche mainnet
            chainId == 250 ||  // Fantom mainnet
            chainId == 42161 || // Arbitrum One
            chainId == 10 ||   // Optimism mainnet
            chainId == 8453 || // Base mainnet
            chainId == 59144 || // Linea mainnet
            chainId == 534352 || // Scroll mainnet
            chainId == 81457 || // Blast mainnet
            chainId == 5000 || // Mantle mainnet
            chainId == 100 ||  // Gnosis Chain
            chainId == 1284 || // Moonbeam
            chainId == 1101 || // Polygon zkEVM
            chainId == 42220 || // Celo mainnet
            chainId == 1313161554 || // Aurora mainnet
            chainId == 8217 || // Klaytn mainnet
            chainId == 30 ||   // Rootstock mainnet
            chainId == 686 ||  // Karura mainnet
            chainId == 787 ||  // Acala mainnet
            chainId == 2222 || // Kava mainnet
            chainId == 1666600000 || // Harmony mainnet
            chainId == 1116 || // Core mainnet
            chainId == 42262 || // Oasis Emerald mainnet
            chainId == 288 ||  // Boba Network
            chainId == 324 ||  // zkSync Era
            chainId == 34443 || // Mode mainnet
            chainId == 480 || // World Chain mainnet
            chainId == 7777777 || // Zora mainnet
            chainId == 690 || // Redstone mainnet
            chainId == 255 || // Kroma mainnet
            chainId == 1329 // Sei mainnet
        );
    }
}
