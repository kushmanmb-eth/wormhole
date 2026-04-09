# Token Distribution System

This directory contains the configuration and documentation for the automated token distribution system.

## Overview

The token distribution system allows authorized owners to distribute tokens through:
1. Manual execution using Foundry scripts
2. Automated daily execution via GitHub Actions
3. Manual triggering through GitHub Actions UI

## Authorized Owners

The following addresses are authorized to distribute tokens:
- **Kushmanmb**: Address to be configured
- **yaketh.eth**: ENS name to be resolved to Ethereum address
- **kushmanmb.eth**: ENS name to be resolved to Ethereum address

## Configuration

### distribution-config.json

This file contains:
- Authorized owner addresses
- Distribution parameters (daily amounts, limits)
- Safety limits (max supply, max single distribution)

**Important:** Before deployment, update the placeholder addresses with actual Ethereum addresses. For ENS names, resolve them to their corresponding addresses.

### Updating Addresses

1. Resolve ENS names to addresses:
   ```bash
   # Using ethers.js or web3.js
   const address = await provider.resolveName("yaketh.eth");
   ```

2. Update `distribution-config.json` with the resolved addresses

3. Update the constants in `ethereum/forge-scripts/DistributeTokens.s.sol`:
   ```solidity
   address constant OWNER_KUSHMANMB = address(0x...);
   address constant OWNER_YAKETH = address(0x...);
   address constant OWNER_KUSHMANMB_ETH = address(0x...);
   ```

## Usage

### Manual Distribution (Command Line)

```bash
cd ethereum

# Dry run (test without broadcasting)
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "dryRun(address,address[],uint256[])" \
  <TOKEN_ADDRESS> \
  "[<RECIPIENT1>,<RECIPIENT2>]" \
  "[<AMOUNT1>,<AMOUNT2>]"

# Actual distribution
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "run(address,address[],uint256[])" \
  <TOKEN_ADDRESS> \
  "[<RECIPIENT1>,<RECIPIENT2>]" \
  "[<AMOUNT1>,<AMOUNT2>]" \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast

# Single recipient distribution
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "runSingle(address,address,uint256)" \
  <TOKEN_ADDRESS> \
  <RECIPIENT_ADDRESS> \
  <AMOUNT> \
  --rpc-url <RPC_URL> \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

### Automated Distribution (GitHub Actions)

#### Daily Scheduled Distribution

The workflow runs automatically every day at 00:00 UTC. To enable:

1. Configure repository secrets:
   - `RPC_URL`: Ethereum RPC endpoint
   - `DEPLOYER_PRIVATE_KEY`: Private key of authorized owner

2. Update token address and recipients in the workflow file or config

#### Manual Trigger

1. Go to GitHub Actions tab
2. Select "Daily Token Distribution" workflow
3. Click "Run workflow"
4. Fill in parameters:
   - Token contract address
   - Recipients (comma-separated)
   - Amounts in wei (comma-separated)
   - Dry run option (recommended for testing)

## Security Considerations

1. **Private Key Management**: 
   - Never commit private keys to the repository
   - Use GitHub Secrets for sensitive data
   - Consider using a hardware wallet or multi-sig for production

2. **Owner Verification**:
   - The script verifies the caller is an authorized owner
   - Only addresses listed in the constants can distribute tokens

3. **Safety Limits**:
   - Maximum single distribution: 100 tokens
   - Maximum recipients per batch: 100
   - These can be adjusted in the script

4. **Testing**:
   - Always run dry-run first
   - Test on testnet before mainnet deployment
   - Verify all addresses before distribution

## Example Scenarios

### Example 1: Single Recipient

```bash
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "runSingle(address,address,uint256)" \
  0x1234567890123456789012345678901234567890 \
  0xabcdefabcdefabcdefabcdefabcdefabcdefabcd \
  1000000000000000000 \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Example 2: Multiple Recipients

```bash
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "run(address,address[],uint256[])" \
  0x1234567890123456789012345678901234567890 \
  "[0xaaaa,0xbbbb,0xcccc]" \
  "[1000000000000000000,2000000000000000000,3000000000000000000]" \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Troubleshooting

### Common Issues

1. **"Caller is not an authorized owner"**
   - Verify the private key corresponds to an authorized address
   - Check that addresses are correctly updated in the script

2. **"Amount exceeds maximum"**
   - Reduce distribution amount
   - Adjust MAX_SINGLE_DISTRIBUTION constant if needed

3. **"Recipients and amounts length mismatch"**
   - Ensure arrays have the same length
   - Check for extra commas or formatting issues

4. **ENS Resolution**
   - ENS names must be resolved to addresses before use
   - Update config with resolved addresses

## Maintenance

### Adding New Owners

1. Update `distribution-config.json`
2. Add constant in `DistributeTokens.s.sol`
3. Update `isAuthorizedOwner()` function
4. Update `getAuthorizedOwners()` function
5. Update this README

### Adjusting Limits

Edit the constants in `DistributeTokens.s.sol`:
```solidity
uint256 constant MAX_SINGLE_DISTRIBUTION = 100 ether;
uint256 constant MAX_RECIPIENTS_PER_BATCH = 100;
```

## Support

For issues or questions, please open an issue in the repository.
