#!/bin/bash

# Usage: MNEMONIC=<your_mnemonic> ./sh/runTokenBalanceTransfer.sh
# Or: PRIVATE_KEY=<your_private_key> ./sh/runTokenBalanceTransfer.sh

# This script runs the TokenBalanceAndTransfer script to check token balances
# and optionally transfer tokens to a new address

set -euo pipefail

# Load environment variables if .env exists
if [ -f .env ]; then
    . .env
fi

# Required parameters
[[ -z ${RPC_URL:-} ]] && { echo "Missing RPC_URL"; exit 1; }

# Either MNEMONIC or PRIVATE_KEY is required
if [[ -z ${MNEMONIC:-} ]] && [[ -z ${PRIVATE_KEY:-} ]]; then
    echo "Missing MNEMONIC or PRIVATE_KEY"
    exit 1
fi

# Token addresses to check (up to 5)
# These should be set in your .env file or provided as environment variables
# Example:
# TOKEN1=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2  # WETH
# TOKEN2=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48  # USDC
# TOKEN3=0xdAC17F958D2ee523a2206206994597C13D831ec7  # USDT
# TOKEN4=0x6B175474E89094C44Da98b954EedeAC495271d0F  # DAI
# TOKEN5=0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599  # WBTC

[[ -z ${TOKEN1:-} ]] && { echo "Missing TOKEN1 address"; exit 1; }
[[ -z ${TOKEN2:-} ]] && { echo "Missing TOKEN2 address"; exit 1; }
[[ -z ${TOKEN3:-} ]] && { echo "Missing TOKEN3 address"; exit 1; }
[[ -z ${TOKEN4:-} ]] && { echo "Missing TOKEN4 address"; exit 1; }
[[ -z ${TOKEN5:-} ]] && { echo "Missing TOKEN5 address"; exit 1; }

# Token to transfer
[[ -z ${TOKEN_TO_TRANSFER:-} ]] && { echo "Missing TOKEN_TO_TRANSFER address"; exit 1; }

# Recipient address for the transfer
[[ -z ${RECIPIENT_ADDRESS:-} ]] && { echo "Missing RECIPIENT_ADDRESS"; exit 1; }

# Amount to transfer (in wei/smallest unit)
[[ -z ${TRANSFER_AMOUNT:-} ]] && { echo "Missing TRANSFER_AMOUNT"; exit 1; }

# Authorization flag - MUST be "true" to allow transfer
# This is the Kushmanmb authorization flag
KUSHMANMB_AUTHORIZED=${KUSHMANMB_AUTHORIZED:-false}

echo "=== Token Balance and Transfer Script ==="
echo "RPC URL: $RPC_URL"
echo "Tokens to check:"
echo "  1. $TOKEN1"
echo "  2. $TOKEN2"
echo "  3. $TOKEN3"
echo "  4. $TOKEN4"
echo "  5. $TOKEN5"
echo ""
echo "Token to transfer: $TOKEN_TO_TRANSFER"
echo "Recipient: $RECIPIENT_ADDRESS"
echo "Amount: $TRANSFER_AMOUNT"
echo "Authorization (Kushmanmb): $KUSHMANMB_AUTHORIZED"
echo "=========================================="
echo ""

# Prepare token array
TOKEN_ARRAY="[$TOKEN1,$TOKEN2,$TOKEN3,$TOKEN4,$TOKEN5]"

# Run the forge script
if [[ -n ${PRIVATE_KEY:-} ]]; then
    forge script ./forge-scripts/TokenBalanceAndTransfer.s.sol:TokenBalanceAndTransfer \
        --sig "run(address[],address,address,uint256,bool)" \
        "$TOKEN_ARRAY" \
        "$TOKEN_TO_TRANSFER" \
        "$RECIPIENT_ADDRESS" \
        "$TRANSFER_AMOUNT" \
        "$KUSHMANMB_AUTHORIZED" \
        --rpc-url "$RPC_URL" \
        --private-key "$PRIVATE_KEY" \
        --broadcast ${FORGE_ARGS:-}
else
    forge script ./forge-scripts/TokenBalanceAndTransfer.s.sol:TokenBalanceAndTransfer \
        --sig "run(address[],address,address,uint256,bool)" \
        "$TOKEN_ARRAY" \
        "$TOKEN_TO_TRANSFER" \
        "$RECIPIENT_ADDRESS" \
        "$TRANSFER_AMOUNT" \
        "$KUSHMANMB_AUTHORIZED" \
        --rpc-url "$RPC_URL" \
        --mnemonic "$MNEMONIC" \
        --broadcast ${FORGE_ARGS:-}
fi

echo ""
echo "=== Script Execution Complete ==="
if [[ "$KUSHMANMB_AUTHORIZED" == "true" ]]; then
    echo "Status: Transfer authorized and executed"
else
    echo "Status: Transfer NOT authorized (Kushmanmb = false)"
    echo "Note: Set KUSHMANMB_AUTHORIZED=true to enable transfers"
fi
