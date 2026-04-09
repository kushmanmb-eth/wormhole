# Mainnet-Only Authorization for Wormhole Bridge

## Overview

This document describes the mainnet-only restriction for authorized addresses in the Wormhole Token Bridge. Authorization is only permitted on mainnet chains to ensure security and prevent unauthorized testnet usage.

## Requirements

As per the requirement: **"I'm sure all owner addresses are active on mainnets only, config new wormhole contract is using etherscan and bscscan rpc on chain id 1"**

1. **Mainnet Only**: Authorized addresses can ONLY be set on mainnet chains
2. **Chain ID 1 Support**: Configuration specifically for Ethereum mainnet (chain ID 1) using Etherscan RPC
3. **BSCScan RPC**: Support for BSC mainnet operations via BSCScan RPC

## Mainnet Chain IDs

The following EVM chain IDs are recognized as mainnet:

| Chain Name | Chain ID | RPC Provider |
|------------|----------|--------------|
| Ethereum | 1 | Etherscan, Infura, Alchemy |
| BSC (Binance Smart Chain) | 56 | BSCScan |
| Polygon | 137 | PolygonScan |
| Avalanche C-Chain | 43114 | SnowTrace |
| Fantom | 250 | FTMScan |
| Arbitrum One | 42161 | Arbiscan |
| Optimism | 10 | Optimistic Etherscan |
| Base | 8453 | BaseScan |
| Linea | 59144 | LineaScan |
| Scroll | 534352 | ScrollScan |
| Blast | 81457 | BlastScan |
| Mantle | 5000 | MantleScan |
| Gnosis Chain | 100 | GnosisScan |
| Moonbeam | 1284 | Moonscan |
| Polygon zkEVM | 1101 | zkEVM PolygonScan |
| Celo | 42220 | CeloScan |
| Aurora | 1313161554 | AuroraScan |
| Klaytn | 8217 | KlaytnScope |
| Rootstock | 30 | Rootstock Explorer |
| Karura | 686 | Karura Subscan |
| Acala | 787 | Acala Subscan |
| And many more... | See BridgeSetters.sol | Various |

## Implementation

### Contract Changes

#### BridgeSetters.sol

Added `isMainnetChain()` function that checks `block.chainid` against a whitelist of mainnet chain IDs:

```solidity
function setAuthorizedAddress(address addr, bool authorized) internal {
    require(addr != address(0), "invalid address");
    // Only allow authorization on mainnet chains
    require(isMainnetChain(), "authorized addresses only allowed on mainnet");
    _state.authorizedAddresses[addr] = authorized;
}

function isMainnetChain() internal view returns (bool) {
    uint256 chainId = block.chainid;
    return (
        chainId == 1 ||    // Ethereum mainnet
        chainId == 56 ||   // BSC mainnet  
        chainId == 137 ||  // Polygon mainnet
        // ... and more mainnet chains
    );
}
```

### Configuration Files

#### For Ethereum Mainnet (Chain ID 1)

File: `env/.env.ethereum.mainnet.authorized`

Key configurations:
- **RPC URL**: Uses Etherscan API endpoints
- **Backup RPC**: Infura or Alchemy as fallback
- **Chain ID**: 1 (Ethereum mainnet)
- **Mainnet Only**: Enforced by smart contract

Example:
```bash
ETHERSCAN_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/${ETHERSCAN_API_KEY}
RPC_URL=${ETHERSCAN_RPC_URL}
EVM_CHAIN_ID=1
MAINNET_ONLY=true
```

#### For BSC Mainnet (Chain ID 56)

Uses BSCScan RPC endpoints:
```bash
BSCSCAN_RPC_URL=https://bsc-dataseed.binance.org/
RPC_URL=${BSCSCAN_RPC_URL}
EVM_CHAIN_ID=56
MAINNET_ONLY=true
```

## Usage

### Authorizing an Address on Mainnet

Use the provided script:

```bash
# Set environment variables
export RPC_URL="https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
export BRIDGE_ADDRESS="0xYourBridgeAddress"
export ADDRESS_TO_AUTHORIZE="0xAddressToAuthorize"
export AUTHORIZE=true
export MAINNET_ONLY=true

# Run the authorization script
./sh/authorizeMainnetAddress.sh
```

The script will:
1. ✅ Verify the chain is a mainnet (reject testnet)
2. ✅ Check the RPC connection
3. ✅ Generate the governance payload
4. ✅ Display current authorization status
5. ✅ Save payload for governance submission

### Attempting Authorization on Testnet

If you try to authorize an address on a testnet:

```bash
export RPC_URL="https://sepolia.infura.io/v3/YOUR_API_KEY"  # Testnet!
./sh/authorizeMainnetAddress.sh
```

**Result**: 
```
ERROR: Chain ID 11155111 is not a mainnet chain
Authorized addresses are only allowed on mainnet
```

The contract will also reject it:
```
Error: execution reverted: authorized addresses only allowed on mainnet
```

## Security Guarantees

### Contract-Level Protection

1. **Hardcoded Mainnet Check**: The `isMainnetChain()` function uses `block.chainid` which cannot be spoofed
2. **Require Statement**: Authorization will revert if not on mainnet
3. **Governance Only**: Only governance can call authorization functions

### Script-Level Protection

1. **Pre-flight Checks**: Script verifies chain ID before generating payload
2. **Mainnet Flag**: `MAINNET_ONLY=true` must be set
3. **Clear Warnings**: Script displays network type prominently

## RPC Configuration for Chain ID 1

### Etherscan RPC

```bash
# Using Etherscan via Alchemy (recommended)
ETHERSCAN_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/${ETHERSCAN_API_KEY}

# Using Infura
ETHERSCAN_RPC_URL=https://mainnet.infura.io/v3/${INFURA_API_KEY}

# Direct node (if available)
ETHERSCAN_RPC_URL=https://mainnet.gateway.tenderly.co
```

### BSCScan RPC (for cross-chain)

```bash
BSCSCAN_RPC_URL=https://bsc-dataseed.binance.org/
BSCSCAN_RPC_URL_BACKUP=https://bsc-dataseed1.defibit.io/
```

## Example Workflow: Ethereum Mainnet

```bash
# 1. Load mainnet configuration
cd ethereum
cp env/.env.ethereum.mainnet.authorized .env
source .env

# 2. Set your Etherscan API key
export ETHERSCAN_API_KEY="your_api_key_here"

# 3. Configure for chain ID 1
export RPC_URL="https://eth-mainnet.g.alchemy.com/v2/${ETHERSCAN_API_KEY}"
export EVM_CHAIN_ID=1

# 4. Authorize an address
export ADDRESS_TO_AUTHORIZE="0x1234567890123456789012345678901234567890"
export AUTHORIZE=true
export BRIDGE_ADDRESS="0xYourDeployedBridgeAddress"

# 5. Run authorization script
./sh/authorizeMainnetAddress.sh

# 6. Submit governance VAA (follow displayed instructions)
```

## Checking Authorization Status

```bash
# Using cast
cast call $BRIDGE_ADDRESS \
  "isAuthorizedAddress(address)(bool)" \
  $ADDRESS_TO_CHECK \
  --rpc-url $RPC_URL

# Using the script (shows in step 5)
./sh/authorizeMainnetAddress.sh
```

## Testnet Prevention

### What Happens on Testnet?

```bash
# Try on Sepolia (testnet)
export RPC_URL="https://sepolia.infura.io/v3/..."

# Script check
./sh/authorizeMainnetAddress.sh
# Output: ERROR: Chain ID 11155111 is not a mainnet chain

# Contract check (if you bypass script)
cast send $BRIDGE_ADDRESS "setAuthorizedAddress..." --rpc-url $RPC_URL
# Output: Error: execution reverted: authorized addresses only allowed on mainnet
```

## Governance Integration

To authorize an address on mainnet:

1. **Generate Payload**: Use `authorizeMainnetAddress.sh`
2. **Create VAA**: Use Wormhole governance tools
3. **Submit Proposal**: Through governance multisig
4. **Execute**: Call `setAuthorizedAddressFromGovernance(bytes encodedVM)`

## API Keys Required

- **Etherscan**: For Ethereum mainnet RPC
- **BSCScan**: For BSC mainnet RPC (optional, public endpoint available)
- **Infura/Alchemy**: Alternative providers for Ethereum

Get your keys:
- Etherscan: https://etherscan.io/apis
- BSCScan: https://bscscan.com/apis
- Infura: https://infura.io/
- Alchemy: https://www.alchemy.com/

## Troubleshooting

### Issue: "authorized addresses only allowed on mainnet"

**Cause**: Attempting to authorize on a testnet
**Solution**: Use a mainnet RPC URL and ensure chain ID is mainnet

### Issue: "Chain ID X is not a mainnet chain"

**Cause**: Script detected testnet or unknown chain
**Solution**: Verify you're using the correct RPC URL for mainnet

### Issue: RPC connection failed

**Cause**: Invalid API key or RPC URL
**Solution**: Check your `ETHERSCAN_API_KEY` or `BSCSCAN_API_KEY`

## Summary

✅ **Mainnet Only**: Authorization only works on mainnet chains
✅ **Chain ID 1**: Full support for Ethereum mainnet via Etherscan RPC
✅ **BSCScan RPC**: Support for BSC mainnet operations
✅ **Contract Protection**: Hardcoded chain ID check in smart contract
✅ **Script Protection**: Pre-flight validation before governance submission
✅ **No Testnet**: Impossible to authorize addresses on testnet networks
