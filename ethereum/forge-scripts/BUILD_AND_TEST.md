# Building and Testing the TokenBalanceAndTransfer Script

## Prerequisites

The TokenBalanceAndTransfer script requires Foundry (Forge) to build and test. Since you're working with the Wormhole repository, there are multiple ways to set up your build environment.

## Build Methods

### Method 1: Using Docker (Recommended)

The easiest way to build without installing dependencies is using Docker:

```bash
# From the root of the wormhole repository
cd ethereum

# Build using Docker (this will use the foundry image with all dependencies)
docker build -t wormhole-ethereum .

# Run the container
docker run -it --rm -v $(pwd):/home/node/app/ethereum wormhole-ethereum bash

# Inside the container, build the contracts
make build

# Run tests
make test-forge
```

### Method 2: Local Foundry Installation

If you want to install Foundry locally:

```bash
# Install foundryup
curl -L https://foundry.paradigm.xyz | bash

# Install Foundry
foundryup

# Navigate to ethereum directory
cd ethereum

# Install dependencies
make dependencies

# Build contracts
make build

# Run tests
make test-forge
```

### Method 3: Using the install script

The repository includes a custom install script:

```bash
cd ethereum
bash ../scripts/install-foundry

# Then build
make build
make test-forge
```

## Verification Steps

### 1. Verify Syntax

After installation, verify the contract syntax:

```bash
cd ethereum
forge build --contracts forge-scripts/TokenBalanceAndTransfer.s.sol
```

Expected output: No compilation errors

### 2. Run Unit Tests

Run the comprehensive test suite:

```bash
cd ethereum
forge test --match-contract TokenBalanceAndTransferTest -vvv
```

Expected output:
```
Running 8 tests for forge-test/TokenBalanceAndTransfer.t.sol:TokenBalanceAndTransferTest
[PASS] testGetTokenBalances() (gas: ...)
[PASS] testGetTop5TokenBalances() (gas: ...)
[PASS] testGetTop5TokenBalancesRevertsWithTooManyTokens() (gas: ...)
[PASS] testSetKushmanmbAuthorization() (gas: ...)
[PASS] testTransferTokensRevertsWhenNotAuthorized() (gas: ...)
[PASS] testTransferTokensRevertsWithZeroAddress() (gas: ...)
[PASS] testTransferTokensRevertsWithZeroAmount() (gas: ...)
[PASS] testAuthorizationFlagPreventsTransfer() (gas: ...)
Test result: ok. 8 passed; 0 failed; finished in ...
```

### 3. Check Code Coverage

```bash
forge coverage --match-contract TokenBalanceAndTransferTest
```

### 4. Dry Run the Script

Test without broadcasting transactions:

```bash
# Set up environment variables
export RPC_URL="https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY"
export TOKEN1="0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
export TOKEN2="0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
export TOKEN3="0xdAC17F958D2ee523a2206206994597C13D831ec7"
export TOKEN4="0x6B175474E89094C44Da98b954EedeAC495271d0F"
export TOKEN5="0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"

# Run dry run (no broadcast)
forge script forge-scripts/TokenBalanceAndTransfer.s.sol:TokenBalanceAndTransfer \
  --sig "dryRun(address[],address)" \
  "[$TOKEN1,$TOKEN2,$TOKEN3,$TOKEN4,$TOKEN5]" \
  "0xYourAddressHere" \
  --rpc-url $RPC_URL
```

## Troubleshooting Build Issues

### Issue: "forge: command not found"

**Solution**: Install Foundry using one of the methods above.

### Issue: Compilation errors with OpenZeppelin

**Solution**: Ensure dependencies are installed:
```bash
cd ethereum
make forge_dependencies
```

### Issue: RPC URL not responding

**Solution**: 
1. Check your internet connection
2. Verify your RPC URL is correct
3. Check if you need an API key
4. Try a different RPC provider

### Issue: Gas estimation errors

**Solution**: Add the `--legacy` flag:
```bash
forge script ... --legacy
```

## Continuous Integration

The contract can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: Test TokenBalanceAndTransfer
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
      
      - name: Build
        run: |
          cd ethereum
          forge build
      
      - name: Test
        run: |
          cd ethereum
          forge test --match-contract TokenBalanceAndTransferTest
```

## Pre-deployment Checklist

Before deploying to production:

- [ ] All tests pass
- [ ] Code coverage is acceptable
- [ ] Contract compiles without warnings
- [ ] Dry run completed successfully
- [ ] Environment variables are correctly set
- [ ] Authorization flag (KUSHMANMB_AUTHORIZED) is properly configured
- [ ] Token addresses are verified
- [ ] Recipient address is verified
- [ ] Transfer amount is correct
- [ ] RPC URL is working
- [ ] Gas price is acceptable

## Security Checks

Run additional security checks:

```bash
# Static analysis with Slither (if installed)
slither forge-scripts/TokenBalanceAndTransfer.s.sol

# Gas optimization check
forge test --gas-report
```

## Next Steps

After successful build and testing:

1. Review the [TokenBalanceAndTransfer.README.md](TokenBalanceAndTransfer.README.md) for usage instructions
2. Configure your `.env` file using `env/.env.token.transfer.example` as a template
3. Run the deployment script: `./sh/runTokenBalanceTransfer.sh`
4. Verify the transaction on a block explorer

## Support

If you encounter issues:

1. Check the Foundry documentation: https://book.getfoundry.sh/
2. Review Wormhole documentation: https://docs.wormhole.com/
3. Check the main README in the ethereum directory
