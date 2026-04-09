# Credential Security Guidelines

This document provides guidelines for handling credentials and secrets in the Wormhole repository.

## 🔒 Security Principles

1. **NEVER commit production credentials** to the repository
2. **NEVER commit API keys or tokens** that have access to real services
3. **ALWAYS use environment variables** for sensitive configuration
4. **ALWAYS review changes** before committing to ensure no secrets are included

## ✅ What CAN Be Committed

The following types of credentials are safe to commit because they are used only for local development and testing:

### Development/Test Keys
- Anvil/Hardhat default test account private keys
- Local devnet guardian keys (marked with "devnet" or "dev")
- Algorand sandbox default tokens
- Sui test network keys in test files
- Mock API keys in test files (e.g., UUIDs in `*.test.ts` files)

### Configuration Templates
- `.env.sample` or `.env.example` files (without actual values)
- `.env.template` files
- Network configuration templates in `ethereum/env/`

### Test Files
- Any credentials in files ending with `_test.go`, `.test.ts`, `.test.js`
- Mock credentials in `**/mock/**` directories

## ❌ What Should NEVER Be Committed

### Production Credentials
- Private keys for mainnet accounts
- API keys for external services (Infura, Alchemy, etc.)
- AWS access keys and secret keys
- GitHub personal access tokens
- Slack webhooks or tokens
- Database passwords
- Any credential that provides access to real funds or production systems

### Personal Information
- Personal wallet files
- Keystore files with real funds
- Your personal `.env` file

## 🛠️ Tools and Automation

### Pre-commit Hooks
Install pre-commit hooks to scan for secrets before committing:

```bash
# Install pre-commit
pip install pre-commit

# Install the hooks
pre-commit install

# Run manually on all files
pre-commit run --all-files
```

### Gitleaks
Scan the repository for leaked credentials:

```bash
# Install gitleaks (example for macOS)
brew install gitleaks

# Scan the current state
gitleaks detect --config .gitleaks.toml --verbose

# Scan before committing
gitleaks protect --staged --verbose
```

### TruffleHog
Alternative tool for finding secrets:

```bash
# Install TruffleHog
brew install trufflesecurity/trufflehog/trufflehog

# Scan repository
trufflehog git file://. --only-verified
```

## 📝 Best Practices

### Using Environment Variables

1. Create a `.env` file in your local directory (it's in `.gitignore`):
   ```bash
   cp .env.sample .env
   ```

2. Fill in your actual values:
   ```bash
   INFURA_KEY=your_actual_infura_key_here
   ETH_PRIVATE_KEY=your_actual_private_key_here
   ```

3. Load environment variables in your code:
   ```javascript
   // JavaScript/TypeScript
   require('dotenv').config();
   const infuraKey = process.env.INFURA_KEY;
   ```

   ```go
   // Go
   import "os"
   infuraKey := os.Getenv("INFURA_KEY")
   ```

### Handling Test Keys

When writing tests that need credentials:

1. Use well-known test keys (like Anvil's default accounts)
2. Mark them clearly as test keys in comments
3. Keep them in the test file, not in production code
4. Document why the key is safe to commit

Example:
```typescript
// This is Anvil's default test account #0 - safe for testing
const TEST_PRIVATE_KEY = "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d";
```

### Reviewing Before Commit

Before committing, always:

1. Run `git diff` to review your changes
2. Look for any strings that look like:
   - Long random strings (API keys, tokens)
   - Private keys (64 hex characters for Ethereum)
   - Passwords or credentials
3. Use the pre-commit hooks
4. When in doubt, ask for a review

## 🚨 What To Do If You Accidentally Commit A Secret

If you accidentally commit a credential:

1. **DO NOT just delete it in a new commit** - it will still be in git history
2. **Immediately rotate/revoke the credential** - assume it's compromised
3. **Remove it from git history** using one of these methods:
   - `git filter-branch` (for older Git versions)
   - `git filter-repo` (recommended, requires installation)
   - BFG Repo-Cleaner tool
4. **Force push** to update remote history (coordinate with team)
5. **Notify the team** about the incident

Example using BFG:
```bash
# Install BFG Repo-Cleaner
brew install bfg

# Remove passwords
bfg --replace-text passwords.txt

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (be careful!)
git push --force
```

## 🔍 Security Scanning in CI/CD

The repository has automated secret scanning configured:

- **GitHub Actions**: `.github/workflows/secret-scanning.yml`
  - Runs on every push and pull request
  - Uses Gitleaks and TruffleHog
  - Weekly scheduled scans

- **GitHub Secret Scanning**: Enable in repository settings
  - Provides push protection
  - Automatically detects known secret patterns

## 📚 Additional Resources

- [GitHub Secret Scanning Documentation](https://docs.github.com/en/code-security/secret-scanning)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog)
- [Pre-commit Framework](https://pre-commit.com/)
- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

## 📞 Questions?

If you're unsure whether something is safe to commit, please:
1. Check this guide
2. Ask in the development chat
3. Request a security review
4. When in doubt, don't commit it!

Remember: **It's always better to be cautious with credentials!**
