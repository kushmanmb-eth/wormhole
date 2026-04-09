#!/bin/bash

# Script to authorize addresses on mainnet only using Etherscan/BSCScan RPCs
# This ensures owner addresses are only active on mainnet chains

set -euo pipefail

echo "=== Wormhole Mainnet Address Authorization ==="
echo ""

# Load environment
if [ -f .env ]; then
    source .env
fi

# Required: Must be on mainnet
MAINNET_ONLY=${MAINNET_ONLY:-true}
if [ "$MAINNET_ONLY" != "true" ]; then
    echo "ERROR: This script only works on mainnet. Set MAINNET_ONLY=true"
    exit 1
fi

# Required: RPC URL
if [ -z "${RPC_URL:-}" ]; then
    echo "ERROR: RPC_URL not set"
    echo "Please configure RPC_URL in your .env file"
    echo "For Ethereum mainnet (chain ID 1): Use Etherscan or Infura RPC"
    echo "For BSC mainnet (chain ID 56): Use BSCScan RPC"
    exit 1
fi

# Required: Contract addresses
if [ -z "${BRIDGE_ADDRESS:-}" ]; then
    echo "ERROR: BRIDGE_ADDRESS not set"
    exit 1
fi

# Verify we're on mainnet by checking chain ID
echo "1. Verifying chain is mainnet..."
CHAIN_ID=$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || echo "0")

MAINNET_CHAINS=(1 56 137 43114 250 42161 10 8453)
IS_MAINNET=false

for mainnet_id in "${MAINNET_CHAINS[@]}"; do
    if [ "$CHAIN_ID" == "$mainnet_id" ]; then
        IS_MAINNET=true
        break
    fi
done

if [ "$IS_MAINNET" != "true" ]; then
    echo "ERROR: Chain ID $CHAIN_ID is not a mainnet chain"
    echo "Authorized addresses are only allowed on mainnet"
    echo "Mainnet chain IDs: ${MAINNET_CHAINS[*]}"
    exit 1
fi

echo "   ✓ Verified mainnet chain ID: $CHAIN_ID"

# Display RPC configuration
echo ""
echo "2. RPC Configuration:"
if [ "$CHAIN_ID" == "1" ]; then
    echo "   Network: Ethereum Mainnet"
    echo "   RPC URL: ${ETHERSCAN_RPC_URL:-$RPC_URL}"
    echo "   Explorer: https://etherscan.io"
elif [ "$CHAIN_ID" == "56" ]; then
    echo "   Network: BSC Mainnet"
    echo "   RPC URL: ${BSCSCAN_RPC_URL:-$RPC_URL}"
    echo "   Explorer: https://bscscan.com"
else
    echo "   Network: Chain ID $CHAIN_ID"
    echo "   RPC URL: $RPC_URL"
fi

# Check if address is provided
if [ -z "${ADDRESS_TO_AUTHORIZE:-}" ]; then
    echo ""
    echo "ERROR: ADDRESS_TO_AUTHORIZE not set"
    echo "Usage: ADDRESS_TO_AUTHORIZE=0x... AUTHORIZE=true ./sh/authorizeMainnetAddress.sh"
    exit 1
fi

# Check authorization flag
AUTHORIZE=${AUTHORIZE:-false}
if [ "$AUTHORIZE" != "true" ] && [ "$AUTHORIZE" != "false" ]; then
    echo "ERROR: AUTHORIZE must be 'true' or 'false'"
    exit 1
fi

echo ""
echo "3. Authorization Request:"
echo "   Address: $ADDRESS_TO_AUTHORIZE"
echo "   Action: $([ "$AUTHORIZE" == "true" ] && echo "AUTHORIZE" || echo "REVOKE")"
echo "   Bridge: $BRIDGE_ADDRESS"

# Constants
TOKEN_BRIDGE_MODULE="0x000000000000000000000000000000000000000000546f6b656e427269646765"
ACTION_SET_AUTHORIZED_ADDRESS="04"

# Prepare governance payload
# Action 4 = SetAuthorizedAddress
MODULE="$TOKEN_BRIDGE_MODULE"
ACTION="$ACTION_SET_AUTHORIZED_ADDRESS"
CHAIN_ID_HEX=$(printf "%04x" $CHAIN_ID)
ADDRESS_PADDED=$(printf "000000000000000000000000%s" "${ADDRESS_TO_AUTHORIZE#0x}")
AUTHORIZED=$([ "$AUTHORIZE" == "true" ] && echo "01" || echo "00")

PAYLOAD="${MODULE}${ACTION}${CHAIN_ID_HEX}${ADDRESS_PADDED}${AUTHORIZED}"

echo ""
echo "4. Governance Payload:"
echo "   Module: $MODULE"
echo "   Action: $ACTION (SetAuthorizedAddress)"
echo "   ChainId: $CHAIN_ID_HEX"
echo "   Address: $ADDRESS_PADDED"
echo "   Authorized: $AUTHORIZED"
echo ""
echo "   Full Payload: $PAYLOAD"

# Check current authorization status
echo ""
echo "5. Checking current authorization status..."

CURRENT_STATUS=$(cast call "$BRIDGE_ADDRESS" "isAuthorizedAddress(address)(bool)" "$ADDRESS_TO_AUTHORIZE" --rpc-url "$RPC_URL" 2>/dev/null || echo "unknown")

if [ "$CURRENT_STATUS" == "unknown" ]; then
    echo "   ⚠ Could not check current status"
else
    echo "   Current status: $([ "$CURRENT_STATUS" == "true" ] && echo "AUTHORIZED ✓" || echo "NOT AUTHORIZED ✗")"
fi

# Confirmation
echo ""
echo "6. Summary:"
echo "   =================================="
echo "   Network: Chain ID $CHAIN_ID (MAINNET ONLY)"
echo "   Address: $ADDRESS_TO_AUTHORIZE"
echo "   Action: $([ "$AUTHORIZE" == "true" ] && echo "AUTHORIZE" || echo "REVOKE")"
echo "   =================================="
echo ""

# Generate governance VAA creation instructions
echo "7. Next Steps:"
echo ""
echo "   To complete this authorization, you need to:"
echo ""
echo "   a) Create a governance VAA with the payload above"
echo "   b) Submit it using the governance process"
echo "   c) Execute: cast send $BRIDGE_ADDRESS \"setAuthorizedAddressFromGovernance(bytes)\" <VAA> --rpc-url $RPC_URL"
echo ""
echo "   Or use the Wormhole governance tools to submit the proposal."
echo ""

# Save payload to file for reference
PAYLOAD_FILE="/tmp/authorize_payload_${ADDRESS_TO_AUTHORIZE}_${CHAIN_ID}.txt"
echo "$PAYLOAD" > "$PAYLOAD_FILE"
echo "   Payload saved to: $PAYLOAD_FILE"
echo ""

echo "=== Authorization Script Complete ==="
