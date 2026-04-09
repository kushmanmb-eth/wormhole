# Wormhole Bridge - Address Authorization for Outgoing Transfers

## Overview

This feature adds address-based authorization controls to the Wormhole Token Bridge, ensuring that only explicitly authorized addresses can initiate outgoing transfers. **ALL bridge operations are restricted to mainnet chains only** - the bridge will not operate on any testnet.

## Problem Addressed

**Requirement 1**: "Do not allow wormhole any outgoing unless explicit address true"
**Requirement 2**: "Operate on mainnets only"

The Token Bridge needed:
1. A mechanism to restrict who can initiate outgoing transfers (bridging tokens to other chains) to only a whitelist of approved addresses
2. Complete restriction of ALL bridge operations to mainnet chains only

## Solution

### Architecture

The solution adds:

1. **State Management**: A mapping of authorized addresses in the bridge state
2. **Authorization Modifier**: An `onlyAuthorized` modifier that checks authorization before allowing transfers
3. **Mainnet-Only Enforcement**: An `onlyMainnet` modifier that prevents ALL operations on testnet chains
4. **Governance Control**: A governance action (action 4) to add/remove authorized addresses
5. **Protected Functions**: All outgoing transfer and attestation functions require both mainnet AND authorization

### Modified Contracts

#### BridgeState.sol
Added to the `State` struct:
```solidity
// Mapping of authorized addresses for outgoing transfers
mapping(address => bool) authorizedAddresses;
```

#### BridgeGetters.sol
Added getter functions:
```solidity
function isAuthorizedAddress(address addr) public view returns (bool)
function isMainnetChain() public view returns (bool)
```

The `isMainnetChain()` function validates against 30+ mainnet chain IDs including:
- Ethereum (1), BSC (56), Polygon (137), Avalanche (43114)
- Arbitrum (42161), Optimism (10), Base (8453), and 23+ more

#### BridgeSetters.sol
Added setter function:
```solidity
function setAuthorizedAddress(address addr, bool authorized) internal
```

#### BridgeStructs.sol
Added new governance struct:
```solidity
struct SetAuthorizedAddress {
    bytes32 module;      // "TokenBridge" left-padded
    uint8 action;        // governance action: 4
    uint16 chainId;      // governance packet chain id
    address addr;        // Address to authorize/unauthorize
    bool authorized;     // Authorization status
}
```

#### BridgeGovernance.sol
Added:
- `setAuthorizedAddressFromGovernance(bytes memory encodedVM)`: Execute governance action to authorize/unauthorize addresses
- `parseSetAuthorizedAddress(bytes memory encoded)`: Parse the governance payload

#### Bridge.sol
Added:
- `onlyAuthorized` modifier: Checks if `msg.sender` is in the authorized addresses mapping
- `onlyMainnet` modifier: **Checks if current chain is a mainnet - rejects all testnet operations**
- Applied both modifiers to all outgoing transfer functions:
  - `attestToken()` - requires mainnet only
  - `transferTokens()` - requires mainnet AND authorization
  - `transferTokensWithPayload()` - requires mainnet AND authorization
  - `wrapAndTransferETH()` - requires mainnet AND authorization
  - `wrapAndTransferETHWithPayload()` - requires mainnet AND authorization

#### ITokenBridge.sol
Updated interface to include:
- `isAuthorizedAddress(address addr)` getter
- `isMainnetChain()` getter - **check if current chain is mainnet**
- `setAuthorizedAddressFromGovernance(bytes memory encodedVM)` function
- `parseSetAuthorizedAddress(bytes memory encoded)` function
- `SetAuthorizedAddress` struct definition

## Usage

### Checking If Chain Is Mainnet

```solidity
bool isMainnet = bridge.isMainnetChain();
// Returns true only on production mainnets, false on all testnets
```

### Checking Authorization Status

```solidity
bool isAuthorized = bridge.isAuthorizedAddress(userAddress);
```

### Authorizing an Address (via Governance)

Authorization must be done through Wormhole governance by submitting a VAA with action 4:

1. **Create Governance Payload**:
```
bytes32 module;         // "TokenBridge" left-padded (0x000000000000000000000000000000000000000000546f6b656e427269646765)
uint8 action;           // 4
uint16 chainId;         // Target chain ID (or 0 for all chains)
address addr;           // Address to authorize (bytes32, left-padded)
uint8 authorized;       // 1 for authorize, 0 for unauthorize
```

2. **Submit through Governance**:
```solidity
bridge.setAuthorizedAddressFromGovernance(encodedVM);
```

### Attempting Transfers

**On Mainnet with Authorized Address**:
```solidity
// This will succeed (mainnet + authorized)
bridge.transferTokens(tokenAddress, amount, recipientChain, recipient, fee, nonce);
```

**On Testnet (ANY address)**:
```solidity
// This will ALWAYS revert with "operation only allowed on mainnet"
// Even if the address is authorized!
bridge.transferTokens(tokenAddress, amount, recipientChain, recipient, fee, nonce);
```

**On Mainnet with Unauthorized Address**:
```solidity
// This will revert with "sender not authorized for outgoing transfers"
bridge.transferTokens(tokenAddress, amount, recipientChain, recipient, fee, nonce);
```

## Security Considerations

### Benefits

1. **Mainnet Only**: The bridge CANNOT operate on any testnet - all operations are blocked at contract level
2. **Access Control**: Only pre-approved addresses can initiate outgoing transfers
3. **Governance-Based**: Authorization changes require governance consensus
4. **Transparent**: Both authorization and mainnet status are publicly queryable
5. **Granular**: Can authorize/unauthorize individual addresses
6. **Chain Validation**: Uses `block.chainid` which cannot be spoofed

### Important Notes

1. **Testnet Blocked**: The bridge will NOT work on ANY testnet - all operations will revert
2. **Initial State**: By default, NO addresses are authorized. They must be explicitly added via governance
3. **Zero Address Protection**: The zero address cannot be authorized
4. **Governance Required**: Only governance VAAs can modify authorization status
5. **Chain-Specific**: Authorization can be set per-chain or globally (chainId = 0)
6. **Incoming Transfers**: This does NOT affect incoming transfers (completing transfers from other chains)
7. **Mainnet List**: Currently supports 30+ mainnet chains (Ethereum, BSC, Polygon, etc.)

## Migration

### For Existing Deployments

If this feature is deployed as an upgrade to an existing Token Bridge:

1. **Breaking Change**: Existing users will lose the ability to transfer until authorized
2. **Migration Path**: 
   - Submit governance VAAs to authorize legitimate users/contracts
   - Consider authorizing known integration contracts first
   - Monitor for unauthorized transfer attempts

### Recommended Deployment Strategy

1. Deploy the upgrade
2. Immediately submit governance VAAs to authorize:
   - Known legitimate users
   - Integration contracts
   - Relayer addresses
3. Monitor for failed transfer attempts
4. Authorize additional addresses as needed

## Testing

Test coverage includes:

1. ✅ Unauthorized addresses cannot call `transferTokens()`
2. ✅ Unauthorized addresses cannot call `transferTokensWithPayload()`
3. ✅ Unauthorized addresses cannot call `wrapAndTransferETH()`
4. ✅ Unauthorized addresses cannot call `wrapAndTransferETHWithPayload()`
5. ✅ Authorized addresses CAN successfully transfer
6. ✅ Governance can authorize addresses
7. ✅ Governance can unauthorize addresses
8. ✅ `isAuthorizedAddress()` returns correct status
9. ✅ Zero address cannot be authorized
10. ✅ `parseSetAuthorizedAddress()` correctly parses governance payloads

## Governance Action Format

**Action Number**: 4

**Payload Structure** (69 bytes total):
```
Offset | Size | Field
-------|------|-------
0      | 32   | module (bytes32) - "TokenBridge" left-padded
32     | 1    | action (uint8) - 4
33     | 2    | chainId (uint16) - target chain or 0 for all
35     | 32   | address (bytes32) - address to authorize, left-padded
67     | 1    | authorized (uint8) - 1 = authorize, 0 = unauthorize
```

## Example Governance Payload

To authorize address `0x1234567890123456789012345678901234567890` on chain 2:

```
0x000000000000000000000000000000000000000000546f6b656e427269646765  // module
04                                                                  // action
0002                                                                // chainId
0000000000000000000000001234567890123456789012345678901234567890  // address
01                                                                  // authorized
```

## API Reference

### State

```solidity
mapping(address => bool) authorizedAddresses;
```

### Functions

```solidity
// Check if an address is authorized
function isAuthorizedAddress(address addr) public view returns (bool);

// Authorize/unauthorize an address (governance only)
function setAuthorizedAddressFromGovernance(bytes memory encodedVM) public;

// Parse governance payload
function parseSetAuthorizedAddress(bytes memory encoded) public pure 
    returns (SetAuthorizedAddress memory authAddr);
```

### Modifier

```solidity
modifier onlyAuthorized() {
    require(isAuthorizedAddress(msg.sender), "sender not authorized for outgoing transfers");
    _;
}
```

## Compatibility

- ✅ Compatible with existing Token Bridge architecture
- ✅ Uses standard governance mechanism
- ✅ No changes to incoming transfer logic
- ✅ No changes to token wrapping/unwrapping logic
- ⚠️ Breaking change for outgoing transfers (requires migration)

## Future Enhancements

Potential improvements:

1. **Role-Based Access**: Introduce different authorization levels
2. **Time-Limited Authorization**: Temporary authorization with expiration
3. **Per-Token Authorization**: Authorize addresses for specific tokens only
4. **Rate Limiting**: Add transfer limits for authorized addresses
5. **Emergency Pause**: Quick disable of all outgoing transfers

## Support

For questions or issues:
- Review the test suite in `forge-test/BridgeAuthorization.t.sol`
- Check authorization status with `isAuthorizedAddress()`
- Contact governance to request address authorization
