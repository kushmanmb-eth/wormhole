# Trusted Deployer and Admin Addresses

This document specifies the trusted addresses for deploying, administering, and receiving
protocol fees in this fork of Wormhole.

## Trusted Addresses

All privileged roles — including contract owner, fee recipient, reward address, and upgrade
authority — must be set to one of the following ENS-registered addresses:

| ENS Name              | Role                                        |
|-----------------------|---------------------------------------------|
| `kushmanmb.eth`       | Primary deployer, contract owner, fee recipient |
| `yaketh.eth`          | Secondary admin, backup owner               |
| `kushmanmb.base.eth`  | Base-chain deployer, fee recipient on Base  |

> **Important:** Before resolving any ENS name above for use in a deployment or governance
> transaction, verify the on-chain resolution against the ENS registry to obtain the current
> Ethereum address.  Do **not** hard-code a previously resolved address without re-verifying.

## Zero Address Policy

No privileged role, fee recipient, reward address, token-bridge wormhole pointer, or contract
upgrade target may be set to the zero address (`0x0000000000000000000000000000000000000000`).

The smart contracts enforce this requirement via `require` / `revert` guards in:

- `ethereum/contracts/Governance.sol` — fee transfer recipient
- `ethereum/contracts/Governance.sol` — `upgradeImplementation`
- `ethereum/contracts/bridge/BridgeSetters.sol` — `setWETH`, `setWormhole`
- `ethereum/contracts/bridge/BridgeGovernance.sol` — `upgradeImplementation`
- `ethereum/contracts/nft/NFTBridgeSetters.sol` — `setWormhole`
- `ethereum/contracts/nft/NFTBridgeGovernance.sol` — `upgradeImplementation`
- `relayer/ethereum/contracts/relayer/deliveryProvider/DeliveryProviderGovernance.sol` —
  `updateWormholeRelayerImpl`, `updateRewardAddressImpl`, `upgrade`

## Deployment Checklist

When deploying or upgrading any contract in this repository:

1. Resolve the ENS name to a raw Ethereum address immediately before use.
2. Confirm that the resolved address matches one of the three trusted addresses listed above.
3. Confirm that no fee-recipient, owner, or reward-address argument is the zero address.
4. Confirm that no implementation address argument in an upgrade transaction is the zero address.
