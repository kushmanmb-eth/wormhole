# Mainnet-Only Operations - Complete Bridge Restriction

## Overview

**The Wormhole Token Bridge now operates EXCLUSIVELY on mainnet chains.** All bridge operations, including token transfers, attestations, and wrapping operations, are completely blocked on testnet networks.

## Requirement

**"Operate on mainnets only"**

The bridge must refuse to execute any operations on testnet chains, ensuring that all activity occurs only on production mainnet networks.

## Implementation

### Global Mainnet Enforcement

A new `onlyMainnet` modifier has been added to the Bridge contract that validates the current chain is a recognized mainnet before allowing any operation to proceed.

```solidity
modifier onlyMainnet() {
    require(isMainnetChain(), "operation only allowed on mainnet");
    _;
}
```

### Affected Operations

The following operations are now **mainnet-only**:

#### Outgoing Operations (Mainnet + Authorization Required)
1. **`transferTokens()`** - Transfer ERC20 tokens cross-chain
2. **`transferTokensWithPayload()`** - Transfer tokens with additional payload
3. **`wrapAndTransferETH()`** - Wrap ETH and transfer cross-chain
4. **`wrapAndTransferETHWithPayload()`** - Wrap ETH and transfer with payload

#### Token Attestation (Mainnet Required)
5. **`attestToken()`** - Create asset metadata message for a token

### Unrestricted Operations

The following operations remain **unrestricted** to allow cross-chain functionality:

- **`completeTransfer()`** - Complete incoming token transfers
- **`completeTransferWithPayload()`** - Complete incoming transfers with payload
- **`completeTransferAndUnwrapETH()`** - Complete incoming ETH transfers
- **`completeTransferAndUnwrapETHWithPayload()`** - Complete incoming ETH with payload
- **`updateWrapped()`** - Update wrapped token metadata
- **`createWrapped()`** - Create new wrapped token contracts

## Recognized Mainnet Chains

The `isMainnetChain()` function validates against the following EVM chain IDs:

| Chain Name | Chain ID | Status |
|------------|----------|--------|
| **Ethereum** | 1 | ✅ Mainnet |
| **BSC (Binance Smart Chain)** | 56 | ✅ Mainnet |
| **Polygon** | 137 | ✅ Mainnet |
| **Avalanche C-Chain** | 43114 | ✅ Mainnet |
| **Fantom** | 250 | ✅ Mainnet |
| **Arbitrum One** | 42161 | ✅ Mainnet |
| **Optimism** | 10 | ✅ Mainnet |
| **Base** | 8453 | ✅ Mainnet |
| **Linea** | 59144 | ✅ Mainnet |
| **Scroll** | 534352 | ✅ Mainnet |
| **Blast** | 81457 | ✅ Mainnet |
| **Mantle** | 5000 | ✅ Mainnet |
| **Gnosis Chain** | 100 | ✅ Mainnet |
| **Moonbeam** | 1284 | ✅ Mainnet |
| **Polygon zkEVM** | 1101 | ✅ Mainnet |
| **Celo** | 42220 | ✅ Mainnet |
| **Aurora** | 1313161554 | ✅ Mainnet |
| **Klaytn** | 8217 | ✅ Mainnet |
| **Rootstock** | 30 | ✅ Mainnet |
| **Karura** | 686 | ✅ Mainnet |
| **Acala** | 787 | ✅ Mainnet |
| **Kava** | 2222 | ✅ Mainnet |
| **Harmony** | 1666600000 | ✅ Mainnet |
| **Core** | 1116 | ✅ Mainnet |
| **Oasis Emerald** | 42262 | ✅ Mainnet |
| **Boba Network** | 288 | ✅ Mainnet |
| **zkSync Era** | 324 | ✅ Mainnet |
| **Mode** | 34443 | ✅ Mainnet |
| **World Chain** | 480 | ✅ Mainnet |
| **Zora** | 7777777 | ✅ Mainnet |
| **Redstone** | 690 | ✅ Mainnet |
| **Kroma** | 255 | ✅ Mainnet |
| **Sei** | 1329 | ✅ Mainnet |

### Blocked Testnet Chains

**ALL** testnets are blocked, including but not limited to:

| Chain Name | Chain ID | Status |
|------------|----------|--------|
| Sepolia | 11155111 | ❌ **BLOCKED** |
| Goerli | 5 | ❌ **BLOCKED** |
| Holesky | 17000 | ❌ **BLOCKED** |
| BSC Testnet | 97 | ❌ **BLOCKED** |
| Polygon Mumbai | 80001 | ❌ **BLOCKED** |
| Avalanche Fuji | 43113 | ❌ **BLOCKED** |
| Arbitrum Sepolia | 421614 | ❌ **BLOCKED** |
| Optimism Sepolia | 11155420 | ❌ **BLOCKED** |
| Base Sepolia | 84532 | ❌ **BLOCKED** |
| *Any other testnet* | * | ❌ **BLOCKED** |

## Behavior Examples

### Scenario 1: Mainnet Operation (Authorized)

```solidity
// Chain: Ethereum Mainnet (Chain ID 1)
// User: Authorized address

bridge.transferTokens(token, amount, recipientChain, recipient, fee, nonce);
// ✅ SUCCESS - Mainnet check passes, authorization check passes
```

### Scenario 2: Testnet Operation (Even if Authorized)

```solidity
// Chain: Sepolia Testnet (Chain ID 11155111)
// User: Authorized address (doesn't matter)

bridge.transferTokens(token, amount, recipientChain, recipient, fee, nonce);
// ❌ REVERTS: "operation only allowed on mainnet"
// Authorization is never checked because mainnet check fails first
```

### Scenario 3: Mainnet Operation (Unauthorized)

```solidity
// Chain: Ethereum Mainnet (Chain ID 1)
// User: NOT authorized

bridge.transferTokens(token, amount, recipientChain, recipient, fee, nonce);
// ❌ REVERTS: "sender not authorized for outgoing transfers"
// Mainnet check passes, but authorization check fails
```

### Scenario 4: Token Attestation on Mainnet

```solidity
// Chain: BSC Mainnet (Chain ID 56)
// User: Any address

bridge.attestToken(tokenAddress, nonce);
// ✅ SUCCESS - Mainnet check passes (no authorization required for attestation)
```

### Scenario 5: Token Attestation on Testnet

```solidity
// Chain: BSC Testnet (Chain ID 97)
// User: Any address

bridge.attestToken(tokenAddress, nonce);
// ❌ REVERTS: "operation only allowed on mainnet"
```

### Scenario 6: Incoming Transfer (Cross-Chain Completion)

```solidity
// Chain: Ethereum Mainnet (Chain ID 1)
// User: Any address completing a transfer from another chain

bridge.completeTransfer(encodedVm);
// ✅ SUCCESS - No mainnet restriction on incoming transfers
// This allows cross-chain transfers to be completed
```

## Security Rationale

### Why Mainnet-Only?

1. **Production Security**: Testnets are for testing, not production value
2. **Real Value Protection**: Only real assets on mainnets should be bridged
3. **Prevent Confusion**: Clear separation between test and production environments
4. **Governance Control**: Mainnet-only ensures proper governance oversight
5. **Authorization Alignment**: Authorized addresses are active on mainnets only

### Defense in Depth

The bridge now has **two layers** of protection:

```
Layer 1: Mainnet Check → Must be on recognized mainnet
         ↓ (if passes)
Layer 2: Authorization Check → Must be authorized address
         ↓ (if passes)
         Operation Executes
```

### Why Incoming Transfers Are NOT Restricted

Incoming transfers (completing transfers from other chains) are not restricted to mainnet-only because:

1. **Cross-Chain Nature**: A transfer initiated on one mainnet needs to be completed on another chain
2. **Message Verification**: Wormhole's VAA verification ensures only valid cross-chain messages are processed
3. **Recipient Control**: The recipient of a cross-chain transfer should be able to complete it
4. **No New Outflow**: Completing a transfer doesn't create new outgoing transfers

## Checking Mainnet Status

### From Contract

```solidity
bool isMainnet = bridge.isMainnetChain();

if (isMainnet) {
    // On mainnet - operations allowed (if authorized)
} else {
    // On testnet - all operations will fail
}
```

### From Script/Web3

```javascript
const isMainnet = await bridge.isMainnetChain();
console.log(`On mainnet: ${isMainnet}`);

// Or check chain ID directly
const chainId = await provider.getNetwork().then(n => n.chainId);
const MAINNET_CHAINS = [1, 56, 137, 43114, 250, 42161, 10, 8453, /* ... */];
const isMainnet = MAINNET_CHAINS.includes(chainId);
```

### From CLI (cast)

```bash
# Check if bridge thinks it's on mainnet
cast call $BRIDGE_ADDRESS "isMainnetChain()(bool)" --rpc-url $RPC_URL

# Check actual chain ID
cast chain-id --rpc-url $RPC_URL
```

## Error Messages

| Error Message | Cause | Solution |
|--------------|-------|----------|
| `"operation only allowed on mainnet"` | Attempting to execute bridge operation on testnet | Deploy to mainnet or use mainnet RPC |
| `"sender not authorized for outgoing transfers"` | Address not authorized (on mainnet) | Submit governance proposal to authorize address |
| `"authorized addresses only allowed on mainnet"` | Attempting to authorize address on testnet | Cannot authorize on testnet - this is by design |

## Testing on Testnets

### What You CAN'T Do

❌ Transfer tokens out via the bridge
❌ Attest tokens
❌ Wrap and transfer ETH
❌ Any outgoing bridge operations

### What You CAN Do

✅ Test contract deployment
✅ Test governance functions (that don't require mainnet)
✅ Test view functions (`isMainnetChain()`, `isAuthorizedAddress()`, etc.)
✅ Test incoming transfer completion (if you have valid VAAs from mainnet)
✅ Test token wrapping/unwrapping logic

### Testing Strategy

For testing bridge functionality:

1. **Unit Tests**: Test logic in isolation with mainnet chain ID mocked
2. **Fork Tests**: Use mainnet forks (e.g., with Foundry's fork mode)
3. **Integration Tests**: Deploy to mainnet and test with small amounts
4. **Mainnet Testing**: Use a mainnet testnet account with minimal funds

**DO NOT** expect the bridge to work on actual testnets - it won't and it shouldn't.

## Migration & Deployment

### For New Deployments

1. Deploy bridge to mainnet only
2. Verify `isMainnetChain()` returns `true`
3. Submit governance proposals to authorize initial addresses
4. Test with authorized addresses on mainnet

### For Existing Deployments (Upgrade)

1. **Critical**: This is a breaking change for testnet users
2. **Action Required**: Migrate all testnet activity to mainnet
3. **Timeline**: Plan migration before upgrade
4. **Communication**: Notify users that testnet support is being removed

### Deployment Checklist

- [ ] Deploy to recognized mainnet (chain ID in supported list)
- [ ] Verify `isMainnetChain()` returns `true`
- [ ] DO NOT deploy to testnets (operations will fail)
- [ ] Configure mainnet RPC URLs (Etherscan, BSCScan, etc.)
- [ ] Submit governance VAAs to authorize initial addresses
- [ ] Test outgoing transfers with authorized addresses
- [ ] Verify testnet operations fail as expected

## API Reference

### Public Functions

```solidity
// Check if current chain is a mainnet
function isMainnetChain() public view returns (bool);

// All outgoing operations use this modifier
modifier onlyMainnet() {
    require(isMainnetChain(), "operation only allowed on mainnet");
    _;
}
```

### Protected Operations

All functions with `onlyMainnet` modifier:

```solidity
function attestToken(address tokenAddress, uint32 nonce) 
    public payable onlyMainnet returns (uint64);

function transferTokens(...) 
    public payable nonReentrant onlyMainnet onlyAuthorized returns (uint64);

function transferTokensWithPayload(...) 
    public payable nonReentrant onlyMainnet onlyAuthorized returns (uint64);

function wrapAndTransferETH(...) 
    public payable onlyMainnet onlyAuthorized returns (uint64);

function wrapAndTransferETHWithPayload(...) 
    public payable onlyMainnet onlyAuthorized returns (uint64);
```

## Summary

✅ **Mainnet Only**: Bridge operations ONLY work on mainnet chains
✅ **30+ Mainnets**: Supports all major EVM mainnets
✅ **Testnet Blocked**: ALL testnets are completely blocked
✅ **Double Protection**: Mainnet check + authorization check
✅ **Contract Enforced**: Uses `block.chainid` (cannot be bypassed)
✅ **Incoming OK**: Cross-chain incoming transfers still work
✅ **Clear Errors**: Descriptive error messages for debugging
✅ **Public Getter**: `isMainnetChain()` for chain validation

**Bottom Line**: The Wormhole Token Bridge is now a mainnet-only system. Testnet usage is not supported and will not work.
