# Wormhole Bridge - Address Authorization for Outgoing Transfers

## Overview

This feature adds address-based authorization controls to the Wormhole Token Bridge, ensuring that only explicitly authorized addresses can initiate outgoing transfers. This prevents unauthorized token transfers and provides an additional security layer.

## Problem Addressed

**Requirement**: "Do not allow wormhole any outgoing unless explicit address true"

The Token Bridge needed a mechanism to restrict who can initiate outgoing transfers (bridging tokens to other chains) to only a whitelist of approved addresses.

## Solution

### Architecture

The solution adds:

1. **State Management**: A mapping of authorized addresses in the bridge state
2. **Authorization Modifier**: An `onlyAuthorized` modifier that checks authorization before allowing transfers
3. **Governance Control**: A governance action (action 4) to add/remove authorized addresses
4. **Protected Functions**: All outgoing transfer functions now require authorization

### Modified Contracts

#### BridgeState.sol
Added to the `State` struct:
```solidity
// Mapping of authorized addresses for outgoing transfers
mapping(address => bool) authorizedAddresses;
```

#### BridgeGetters.sol
Added getter function:
```solidity
function isAuthorizedAddress(address addr) public view returns (bool)
```

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
- Applied modifier to all outgoing transfer functions:
  - `transferTokens()`
  - `transferTokensWithPayload()`
  - `wrapAndTransferETH()`
  - `wrapAndTransferETHWithPayload()`

#### ITokenBridge.sol
Updated interface to include:
- `isAuthorizedAddress(address addr)` getter
- `setAuthorizedAddressFromGovernance(bytes memory encodedVM)` function
- `parseSetAuthorizedAddress(bytes memory encoded)` function
- `SetAuthorizedAddress` struct definition

## Usage

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

**Authorized Address**:
```solidity
// This will succeed
bridge.transferTokens(tokenAddress, amount, recipientChain, recipient, fee, nonce);
```

**Unauthorized Address**:
```solidity
// This will revert with "sender not authorized for outgoing transfers"
bridge.transferTokens(tokenAddress, amount, recipientChain, recipient, fee, nonce);
```

## Security Considerations

### Benefits

1. **Access Control**: Only pre-approved addresses can initiate outgoing transfers
2. **Governance-Based**: Authorization changes require governance consensus
3. **Transparent**: Authorization status is publicly queryable
4. **Granular**: Can authorize/unauthorize individual addresses

### Important Notes

1. **Initial State**: By default, NO addresses are authorized. They must be explicitly added via governance.
2. **Zero Address Protection**: The zero address cannot be authorized
3. **Governance Required**: Only governance VAAs can modify authorization status
4. **Chain-Specific**: Authorization can be set per-chain or globally (chainId = 0)
5. **Incoming Transfers**: This does NOT affect incoming transfers (completing transfers from other chains)

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
