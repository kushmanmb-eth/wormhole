# Token Balance and Transfer Script

## Overview

This Forge script provides functionality to:
1. Get an inventory of current token balances for up to 5 tokens (top 5)
2. Ensure distribution only occurs when explicitly authorized (Kushmanmb = true)
3. Transfer tokens to a new address with authorization checks
4. Ensure build correctness through Forge testing

## Features

- **Balance Inventory**: Check balances for up to 5 ERC20 tokens
- **Authorization Control**: Only allows distribution when `kushmanmbAuthorized` is set to `true`
- **Safe Transfers**: Includes validation checks (non-zero address, non-zero amount)
- **Event Logging**: Emits events for balance checks and transfers
- **Dry Run Mode**: Test without broadcasting transactions

## Prerequisites

- Foundry (Forge) installed
- Ethereum node access or RPC URL
- Private key or mnemonic for transaction signing

## Installation

```bash
cd ethereum
make dependencies
```

## Usage

### 1. Check Token Balances (Dry Run)

To check balances without broadcasting transactions:

```bash
forge script forge-scripts/TokenBalanceAndTransfer.s.sol:TokenBalanceAndTransfer \
  --sig "dryRun(address[],address)" \
  "[0xTokenAddress1,0xTokenAddress2,0xTokenAddress3,0xTokenAddress4,0xTokenAddress5]" \
  "0xHolderAddress" \
  --rpc-url $RPC_URL
```

### 2. Run Full Script (Balance Check + Transfer)

To check balances and transfer tokens with authorization:

```bash
forge script forge-scripts/TokenBalanceAndTransfer.s.sol:TokenBalanceAndTransfer \
  --sig "run(address[],address,address,uint256,bool)" \
  "[0xTokenAddress1,0xTokenAddress2,0xTokenAddress3,0xTokenAddress4,0xTokenAddress5]" \
  "0xTokenToTransfer" \
  "0xRecipientAddress" \
  "1000000000000000000" \
  "true" \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

#### Parameters:
- `address[]`: Array of up to 5 token addresses to check balances
- `address tokenToTransfer`: Address of the token to transfer
- `address recipient`: Address to receive the tokens
- `uint256 amount`: Amount of tokens to transfer (in wei for 18 decimal tokens)
- `bool authorized`: Set to `true` to authorize transfer (Kushmanmb flag)

### 3. Transfer Without Authorization

If you set `authorized` to `false`, the script will:
- Check and display token balances
- Skip the transfer step
- Log: "Transfer skipped: Not authorized (Kushmanmb must be true)"

```bash
forge script forge-scripts/TokenBalanceAndTransfer.s.sol:TokenBalanceAndTransfer \
  --sig "run(address[],address,address,uint256,bool)" \
  "[0xToken1,0xToken2,0xToken3,0xToken4,0xToken5]" \
  "0xTokenToTransfer" \
  "0xRecipient" \
  "1000000000000000000" \
  "false" \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Example

### Check balances and transfer 1 ETH worth of tokens:

```bash
# Define your variables
export RPC_URL="https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
export PRIVATE_KEY="your_private_key"

# Token addresses (example - use actual addresses)
export TOKEN1="0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2" # WETH
export TOKEN2="0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48" # USDC
export TOKEN3="0xdAC17F958D2ee523a2206206994597C13D831ec7" # USDT
export TOKEN4="0x6B175474E89094C44Da98b954EedeAC495271d0F" # DAI
export TOKEN5="0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599" # WBTC

export RECIPIENT="0xNewWormholeAddress"

# Run the script
forge script forge-scripts/TokenBalanceAndTransfer.s.sol:TokenBalanceAndTransfer \
  --sig "run(address[],address,address,uint256,bool)" \
  "[$TOKEN1,$TOKEN2,$TOKEN3,$TOKEN4,$TOKEN5]" \
  "$TOKEN1" \
  "$RECIPIENT" \
  "1000000000000000000" \
  "true" \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Security Features

1. **Authorization Check**: Transfers only execute when `kushmanmbAuthorized == true`
2. **Zero Address Protection**: Prevents transfers to zero address
3. **Amount Validation**: Ensures transfer amount is greater than zero
4. **Event Emission**: All balance checks and transfers emit events for tracking

## Events

- `BalanceChecked(address indexed token, uint256 balance)`: Emitted when a token balance is checked
- `TokensTransferred(address indexed token, address indexed to, uint256 amount)`: Emitted on successful transfer

## Testing

Build and test the contract:

```bash
cd ethereum
make build
make test-forge
```

## Important Notes

1. **Authorization**: The `kushmanmbAuthorized` flag MUST be set to `true` to allow transfers
2. **Token Approval**: Ensure the contract/sender has approval to transfer tokens
3. **Gas Costs**: Running on mainnet will incur gas costs
4. **Top 5 Limit**: Maximum of 5 tokens can be checked at once

## Error Messages

- `"Distribution not authorized: Kushmanmb must be true"`: Authorization flag is false
- `"Cannot transfer to zero address"`: Invalid recipient address
- `"Amount must be greater than zero"`: Transfer amount is zero
- `"Token transfer failed"`: ERC20 transfer failed
- `"Maximum 5 tokens allowed"`: More than 5 tokens provided

## Integration with Wormhole

This script is designed to work with Wormhole token bridges. It can be used to:
- Check balances before bridging tokens
- Transfer tokens to new Wormhole bridge addresses
- Ensure proper authorization before distribution

## License

Apache-2.0 (same as parent project)
