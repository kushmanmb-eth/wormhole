# Token Distribution Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying and configuring the token distribution system with owner permissions for Kushmanmb, yaketh.eth, and kushmanmb.eth.

## Prerequisites

1. **Foundry Installation**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Node.js and Dependencies**
   ```bash
   cd ethereum
   npm ci
   make forge_dependencies
   ```

3. **Ethereum RPC Access**
   - Mainnet RPC URL (e.g., Infura, Alchemy)
   - Testnet RPC URL for testing (Goerli, Sepolia)

4. **Private Key/Wallet**
   - Hardware wallet (recommended for production)
   - Or private key of an authorized owner

## Step 1: Resolve ENS Names

Before deployment, resolve ENS names to Ethereum addresses:

```javascript
// Using ethers.js
const ethers = require('ethers');
const provider = new ethers.providers.JsonRpcProvider('YOUR_RPC_URL');

async function resolveENS() {
  const yakethAddress = await provider.resolveName('yaketh.eth');
  const kushmanmbEthAddress = await provider.resolveName('kushmanmb.eth');
  
  console.log('yaketh.eth:', yakethAddress);
  console.log('kushmanmb.eth:', kushmanmbEthAddress);
}

resolveENS();
```

Or use a web interface like [Etherscan ENS lookup](https://etherscan.io/enslookup).

## Step 2: Update Configuration Files

### 2.1 Update distribution-config.json

Edit `ethereum/config/distribution-config.json`:

```json
{
  "authorizedOwners": [
    {
      "name": "Kushmanmb",
      "address": "0xYOUR_ACTUAL_ADDRESS_HERE"
    },
    {
      "name": "yaketh.eth",
      "ensName": "yaketh.eth",
      "address": "0xRESOLVED_YAKETH_ADDRESS"
    },
    {
      "name": "kushmanmb.eth",
      "ensName": "kushmanmb.eth",
      "address": "0xRESOLVED_KUSHMANMB_ETH_ADDRESS"
    }
  ]
}
```

### 2.2 Update DistributeTokens.s.sol

Edit `ethereum/forge-scripts/DistributeTokens.s.sol`:

```solidity
address constant OWNER_KUSHMANMB = address(0xYOUR_ACTUAL_ADDRESS_HERE);
address constant OWNER_YAKETH = address(0xRESOLVED_YAKETH_ADDRESS);
address constant OWNER_KUSHMANMB_ETH = address(0xRESOLVED_KUSHMANMB_ETH_ADDRESS);
```

## Step 3: Test on Testnet

### 3.1 Deploy Test Token

```bash
cd ethereum

# Deploy a test token on Goerli/Sepolia
forge script forge-scripts/DeployTestToken.s.sol:DeployTestToken \
  --rpc-url $TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

Save the deployed token address.

### 3.2 Dry Run Distribution

```bash
# Test the distribution script (no broadcast)
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "dryRun(address,address[],uint256[])" \
  <TEST_TOKEN_ADDRESS> \
  "[0xRecipient1,0xRecipient2]" \
  "[1000000000000000000,2000000000000000000]"
```

### 3.3 Execute Test Distribution

```bash
# Execute on testnet
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "runSingle(address,address,uint256)" \
  <TEST_TOKEN_ADDRESS> \
  <RECIPIENT_ADDRESS> \
  1000000000000000000 \
  --rpc-url $TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

Verify the transaction on testnet block explorer.

## Step 4: Configure GitHub Secrets

For automated distribution via GitHub Actions:

1. Go to repository Settings → Secrets and variables → Actions
2. Add the following secrets:

   - **RPC_URL**: Your Ethereum RPC endpoint
     ```
     Name: RPC_URL
     Value: https://mainnet.infura.io/v3/YOUR_PROJECT_ID
     ```

   - **DEPLOYER_PRIVATE_KEY**: Private key of authorized owner
     ```
     Name: DEPLOYER_PRIVATE_KEY
     Value: 0x1234567890abcdef...
     ```

   ⚠️ **Security Warning**: For production, use a dedicated deployment wallet or hardware wallet integration.

## Step 5: Test GitHub Actions Workflow

### 5.1 Manual Trigger (Dry Run)

1. Go to Actions tab in GitHub
2. Select "Daily Token Distribution" workflow
3. Click "Run workflow"
4. Fill in:
   - Token Address: `<YOUR_TOKEN_ADDRESS>`
   - Recipients: `0xAddress1,0xAddress2`
   - Amounts: `1000000000000000000,2000000000000000000`
   - Dry Run: `true` ✓

### 5.2 Verify Workflow Execution

Check the workflow logs to ensure:
- Configuration loads correctly
- Script compiles successfully
- Dry run validates inputs

### 5.3 Execute Live Distribution (Manual)

Once verified, run with:
- Dry Run: `false`

Monitor the transaction on Etherscan.

## Step 6: Configure Scheduled Distribution

The workflow is configured to run daily at 00:00 UTC. To customize:

Edit `.github/workflows/token-distribution.yml`:

```yaml
schedule:
  - cron: '0 0 * * *'  # Daily at midnight UTC
  # - cron: '0 */12 * * *'  # Every 12 hours
  # - cron: '0 0 * * 1'  # Every Monday
```

## Step 7: Monitoring and Maintenance

### Daily Checks

1. **Verify Workflow Runs**
   - Check GitHub Actions for daily execution logs
   - Review transaction confirmations

2. **Monitor Token Supply**
   - Track total distributed tokens
   - Ensure within safety limits

3. **Review Recipients**
   - Verify distribution to correct addresses
   - Update recipient list as needed

### Troubleshooting

**Issue: "Caller is not an authorized owner"**
- Solution: Verify private key matches configured owner address

**Issue: "Amount exceeds maximum"**
- Solution: Reduce amount or adjust MAX_SINGLE_DISTRIBUTION

**Issue: RPC rate limiting**
- Solution: Upgrade RPC provider plan or use multiple endpoints

## Security Best Practices

1. **Multi-Signature Wallet**
   - Consider using Gnosis Safe for production
   - Require multiple owners to approve distributions

2. **Gradual Rollout**
   - Start with small amounts
   - Monitor for issues before increasing

3. **Audit Trail**
   - Keep logs of all distributions
   - Review GitHub Actions run history

4. **Emergency Procedures**
   - Document process to pause distributions
   - Have backup owner keys secured

5. **Regular Reviews**
   - Audit owner addresses quarterly
   - Review and update safety limits
   - Check for contract upgrades

## Production Checklist

Before going to production:

- [ ] ENS names resolved to addresses
- [ ] Addresses updated in config and script
- [ ] Tested on testnet successfully
- [ ] GitHub secrets configured
- [ ] Dry run executed without errors
- [ ] Manual distribution tested
- [ ] Scheduled cron verified
- [ ] Monitoring alerts set up
- [ ] Emergency pause procedure documented
- [ ] Backup owner keys secured
- [ ] Team members trained on system

## Support and Questions

For issues or questions:
1. Check the README in `ethereum/config/`
2. Review workflow logs in GitHub Actions
3. Open an issue in the repository

## Appendix: Useful Commands

```bash
# Check token owner
cast call <TOKEN_ADDRESS> "owner()(address)" --rpc-url $RPC_URL

# Check token balance
cast call <TOKEN_ADDRESS> "balanceOf(address)(uint256)" <ADDRESS> --rpc-url $RPC_URL

# Estimate gas for distribution
forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
  --sig "runSingle(address,address,uint256)" \
  <TOKEN> <RECIPIENT> <AMOUNT> \
  --rpc-url $RPC_URL \
  --estimate-gas

# Verify contract on Etherscan
forge verify-contract <ADDRESS> TokenImplementation \
  --chain-id 1 \
  --etherscan-api-key $ETHERSCAN_KEY
```

---

**Last Updated:** April 2026
**Version:** 1.0
