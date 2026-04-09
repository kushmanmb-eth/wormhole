#!/bin/bash

# Quick validation script for TokenBalanceAndTransfer.s.sol
# This performs basic checks without requiring forge installation

set -euo pipefail

echo "=== TokenBalanceAndTransfer Contract Validation ==="
echo ""

CONTRACT_FILE="forge-scripts/TokenBalanceAndTransfer.s.sol"
TEST_FILE="forge-test/TokenBalanceAndTransfer.t.sol"

# Check if files exist
echo "1. Checking file existence..."
if [ ! -f "$CONTRACT_FILE" ]; then
    echo "   ❌ Contract file not found: $CONTRACT_FILE"
    exit 1
fi
echo "   ✓ Contract file exists"

if [ ! -f "$TEST_FILE" ]; then
    echo "   ❌ Test file not found: $TEST_FILE"
    exit 1
fi
echo "   ✓ Test file exists"

# Check Solidity version
echo ""
echo "2. Checking Solidity version..."
if grep -q "pragma solidity \^0.8.4;" "$CONTRACT_FILE"; then
    echo "   ✓ Correct Solidity version: ^0.8.4"
else
    echo "   ❌ Incorrect or missing Solidity version pragma"
    exit 1
fi

# Check for required imports
echo ""
echo "3. Checking imports..."
imports_ok=true

if grep -q 'import "forge-std/Script.sol";' "$CONTRACT_FILE"; then
    echo "   ✓ Forge Script imported"
else
    echo "   ❌ Missing Forge Script import"
    imports_ok=false
fi

if grep -q 'import "@openzeppelin/contracts/token/ERC20/IERC20.sol";' "$CONTRACT_FILE"; then
    echo "   ✓ IERC20 imported"
else
    echo "   ❌ Missing IERC20 import"
    imports_ok=false
fi

if [ "$imports_ok" = false ]; then
    exit 1
fi

# Check contract declaration
echo ""
echo "4. Checking contract declaration..."
if grep -q "contract TokenBalanceAndTransfer is Script" "$CONTRACT_FILE"; then
    echo "   ✓ Contract properly declared"
else
    echo "   ❌ Contract declaration issue"
    exit 1
fi

# Check for required functions
echo ""
echo "5. Checking required functions..."
functions_ok=true

if grep -q "function setKushmanmbAuthorization" "$CONTRACT_FILE"; then
    echo "   ✓ setKushmanmbAuthorization function exists"
else
    echo "   ❌ Missing setKushmanmbAuthorization function"
    functions_ok=false
fi

if grep -q "function getTokenBalances" "$CONTRACT_FILE"; then
    echo "   ✓ getTokenBalances function exists"
else
    echo "   ❌ Missing getTokenBalances function"
    functions_ok=false
fi

if grep -q "function getTop5TokenBalances" "$CONTRACT_FILE"; then
    echo "   ✓ getTop5TokenBalances function exists"
else
    echo "   ❌ Missing getTop5TokenBalances function"
    functions_ok=false
fi

if grep -q "function transferTokens" "$CONTRACT_FILE"; then
    echo "   ✓ transferTokens function exists"
else
    echo "   ❌ Missing transferTokens function"
    functions_ok=false
fi

if grep -q "function run" "$CONTRACT_FILE"; then
    echo "   ✓ run function exists"
else
    echo "   ❌ Missing run function"
    functions_ok=false
fi

if grep -q "function dryRun" "$CONTRACT_FILE"; then
    echo "   ✓ dryRun function exists"
else
    echo "   ❌ Missing dryRun function"
    functions_ok=false
fi

if [ "$functions_ok" = false ]; then
    exit 1
fi

# Check for authorization requirement
echo ""
echo "6. Checking authorization controls..."
if grep -q 'require(kushmanmbAuthorized, "Distribution not authorized: Kushmanmb must be true");' "$CONTRACT_FILE"; then
    echo "   ✓ Authorization check (Kushmanmb) present"
else
    echo "   ❌ Missing or incorrect authorization check"
    exit 1
fi

# Check for safety requirements
echo ""
echo "7. Checking safety requirements..."
safety_ok=true

if grep -q 'require(to != address(0), "Cannot transfer to zero address");' "$CONTRACT_FILE"; then
    echo "   ✓ Zero address check present"
else
    echo "   ❌ Missing zero address check"
    safety_ok=false
fi

if grep -q 'require(amount > 0, "Amount must be greater than zero");' "$CONTRACT_FILE"; then
    echo "   ✓ Amount validation present"
else
    echo "   ❌ Missing amount validation"
    safety_ok=false
fi

if grep -q 'require(tokens.length <= 5, "Maximum 5 tokens allowed");' "$CONTRACT_FILE"; then
    echo "   ✓ Top 5 tokens limit check present"
else
    echo "   ❌ Missing top 5 tokens limit check"
    safety_ok=false
fi

if [ "$safety_ok" = false ]; then
    exit 1
fi

# Check for events
echo ""
echo "8. Checking events..."
events_ok=true

if grep -q "event BalanceChecked" "$CONTRACT_FILE"; then
    echo "   ✓ BalanceChecked event defined"
else
    echo "   ❌ Missing BalanceChecked event"
    events_ok=false
fi

if grep -q "event TokensTransferred" "$CONTRACT_FILE"; then
    echo "   ✓ TokensTransferred event defined"
else
    echo "   ❌ Missing TokensTransferred event"
    events_ok=false
fi

if [ "$events_ok" = false ]; then
    exit 1
fi

# Check for common vulnerabilities
echo ""
echo "9. Checking for common issues..."
issues_found=false

# Check for reentrancy (should use checks-effects-interactions pattern)
# In this case, we check balance, then transfer - this is safe for ERC20

# Check for unchecked return values
if grep -q "bool success = tokenContract.transfer" "$CONTRACT_FILE"; then
    if grep -q "require(success" "$CONTRACT_FILE"; then
        echo "   ✓ Transfer return value checked"
    else
        echo "   ⚠ Transfer return value might not be checked"
        issues_found=true
    fi
fi

# Count lines of code
echo ""
echo "10. Contract statistics..."
total_lines=$(wc -l < "$CONTRACT_FILE")
code_lines=$(grep -v "^\s*$\|^\s*//\|^\s*/\*\|^\s*\*" "$CONTRACT_FILE" | wc -l)
echo "    Total lines: $total_lines"
echo "    Code lines (excluding comments/blank): $code_lines"

# Check test file
echo ""
echo "11. Checking test file..."
if grep -q "contract TokenBalanceAndTransferTest is Test" "$TEST_FILE"; then
    echo "   ✓ Test contract properly declared"
else
    echo "   ❌ Test contract declaration issue"
    exit 1
fi

test_count=$(grep -c "function test" "$TEST_FILE" || true)
echo "   ✓ Found $test_count test functions"

if [ "$test_count" -lt 5 ]; then
    echo "   ⚠ Warning: Only $test_count tests found (recommended: at least 5)"
fi

# Final summary
echo ""
echo "=== Validation Summary ==="
if [ "$issues_found" = true ]; then
    echo "Status: ⚠ PASSED WITH WARNINGS"
    echo ""
    echo "The contract passed basic validation but has some warnings."
    echo "Please review the warnings above."
    exit 0
else
    echo "Status: ✅ PASSED"
    echo ""
    echo "The contract passed all basic validation checks!"
    echo ""
    echo "Next steps:"
    echo "1. Run 'make build' to compile with forge"
    echo "2. Run 'make test-forge' to run unit tests"
    echo "3. Review BUILD_AND_TEST.md for detailed build instructions"
    exit 0
fi
