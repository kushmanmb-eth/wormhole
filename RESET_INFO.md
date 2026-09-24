# Git Reset Performed

This repository has been reset to commit `d29462f7`:

**Commit:** d29462f75e1b9b790db7bf58f5eb3859d470b969  
**Message:** Add zero address checks and trusted deployer address documentation  
**Date:** Sat Mar 7 13:49:15 2026 +0000

## What was reset

The branch `copilot/reset-to-new-wormhole-address` has been reset from:
- **Previous HEAD:** `6c20f7dd` - Fix missing zero address checks in setGovernanceContract and update docs

To:
- **New HEAD:** `d29462f7` - Add zero address checks and trusted deployer address documentation

## This commit includes

This is the "new wormhole address commit" that:
- Adds documentation for trusted deployer addresses (`docs/deployment-addresses.md`)
- Implements zero address checks in multiple Solidity contracts
- Documents the trusted ENS addresses (kushmanmb.eth, yaketh.eth, kushmanmb.base.eth)
- Adds require/revert guards to prevent zero address assignments

## Note about force push

To update the remote branch, a force push is required:
```bash
git push --force-with-lease origin copilot/reset-to-new-wormhole-address
```

This will move the remote branch pointer back to commit d29462f7.
