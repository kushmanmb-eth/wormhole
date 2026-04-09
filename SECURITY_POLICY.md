# Security Policy

## Overview

The Wormhole bridge is a critical piece of cross-chain infrastructure that facilitates the transfer of billions of dollars in assets. Security is our highest priority. This document outlines our security practices, vulnerability disclosure process, and incident response procedures.

## Reporting Security Vulnerabilities

### DO NOT Create Public Issues

**CRITICAL**: Never create public GitHub issues for security vulnerabilities. Public disclosure before a fix is available puts all users at risk.

### Responsible Disclosure Process

If you discover a security vulnerability, please report it through one of these secure channels:

1. **Email**: security@wormhole.com (PGP key available on our website)
2. **Bug Bounty Program**: Visit our bug bounty program at https://wormhole.com/security/bug-bounty
3. **Emergency Hotline**: For critical vulnerabilities actively being exploited, contact emergency@wormhole.com

### What to Include in Your Report

* **Description**: Clear description of the vulnerability
* **Impact**: Potential impact and severity assessment
* **Reproduction**: Step-by-step instructions to reproduce the issue
* **Proof of Concept**: Code, scripts, or screenshots demonstrating the vulnerability
* **Suggested Fix**: If you have ideas for how to fix the issue (optional)
* **Your Contact Information**: So we can follow up with questions or provide updates

### What to Expect

* **Acknowledgment**: Within 24 hours of receipt
* **Initial Assessment**: Within 72 hours
* **Regular Updates**: At least weekly until the issue is resolved
* **Fix Timeline**: Depends on severity, but critical issues will be addressed immediately
* **Credit**: Public acknowledgment of your contribution (unless you prefer to remain anonymous)

## Bug Bounty Program

We operate a comprehensive bug bounty program to reward security researchers who help us maintain the security of the Wormhole bridge.

### Reward Tiers

* **Critical**: Up to $1,000,000 (complete bridge compromise, unlimited fund theft)
* **High**: $100,000 - $500,000 (significant fund theft, major security bypass)
* **Medium**: $10,000 - $50,000 (limited fund theft, authentication bypass)
* **Low**: $1,000 - $5,000 (information disclosure, minor security issues)
* **Informational**: Recognition and swag (no direct security impact)

### Scope

**In Scope:**
* Smart contracts in `/ethereum/contracts/bridge/`
* Core Wormhole protocol contracts
* Guardian network infrastructure (contact us for details)
* Bridge frontend and backend services
* Token implementations and wrapped assets

**Out of Scope:**
* Third-party integrations (unless they directly impact Wormhole)
* Social engineering attacks
* DDoS attacks
* Issues already reported or publicly known
* Attacks requiring physical access to infrastructure

### Rules of Engagement

* **Do not** exploit vulnerabilities beyond what is necessary to demonstrate the issue
* **Do not** access, modify, or delete user data
* **Do not** perform attacks against our infrastructure that could harm availability
* **Do not** publicly disclose vulnerabilities before we have issued a fix
* **Do** provide us a reasonable time to fix vulnerabilities before any disclosure
* **Do** comply with all applicable laws

## Security Best Practices

### For Smart Contract Developers

1. **Audits**: All contract changes undergo internal and external security audits
2. **Testing**: Comprehensive unit tests, integration tests, and fuzzing
3. **Formal Verification**: Critical functions verified using formal methods
4. **Upgradeability**: Only through governance with time-locks
5. **Access Control**: Strict permission management and authorization checks
6. **Input Validation**: Validate all inputs and state transitions
7. **Reentrancy Protection**: Use ReentrancyGuard for all state-changing functions
8. **Integer Overflow**: Use Solidity 0.8+ with built-in overflow checks

### For Users

1. **Verify Addresses**: Always verify contract addresses before interacting
2. **Check Transactions**: Review all transaction details before signing
3. **Use Hardware Wallets**: For large transfers, use hardware wallet signatures
4. **Beware of Phishing**: Only use official Wormhole websites and interfaces
5. **Check Approvals**: Review and revoke unnecessary token approvals
6. **Monitor Transactions**: Track your transactions using block explorers
7. **Report Suspicious Activity**: If something seems wrong, report it

### For Bridge Operators and Guardians

1. **Key Management**: Use hardware security modules (HSMs) for private keys
2. **Operational Security**: Follow strict OpSec procedures
3. **Monitoring**: Continuous monitoring of bridge activity and anomalies
4. **Incident Response**: Maintain 24/7 incident response capability
5. **Regular Updates**: Keep all software and dependencies current
6. **Backup Systems**: Maintain redundant systems and recovery procedures
7. **Communication**: Participate in governance and community discussions

## Token Recovery and Blacklist Policy

### Token Recovery Process

If tokens are stolen or become stuck due to a bug or user error, we have governance-controlled recovery mechanisms:

1. **Investigation**: Thorough investigation of the incident
2. **Governance Proposal**: Submit recovery proposal to governance
3. **Community Vote**: Token holders vote on the recovery action
4. **Execution**: If approved, execute recovery via governance VAA
5. **Post-Mortem**: Public post-mortem report (respecting victim privacy)

### Blacklist Enforcement

After recovering stolen tokens, hacker addresses are **permanently blacklisted**:

1. **Identification**: Identify all addresses involved in the theft
2. **Governance Action**: Submit blacklist proposal to governance  
3. **Smart Contract Enforcement**: Blacklisted addresses are blocked at the contract level
4. **Cross-Chain Coordination**: Share blacklist with other bridges and protocols
5. **Law Enforcement**: Report to relevant authorities and pursue legal action
6. **Permanent Ban**: Blacklisting is permanent and cannot be easily reversed

**Note**: The blacklist is enforced by the `notBlacklisted` modifier on all bridge functions. Once blacklisted, an address cannot:
* Transfer tokens through the bridge
* Attest new tokens
* Interact with bridge contracts in any way
* Receive tokens from other users through the bridge

## Incident Response

### Severity Levels

**Critical**: Complete bridge compromise, active exploitation, massive fund theft
* **Response Time**: Immediate (within minutes)
* **Actions**: Emergency pause if available, immediate patch deployment, public alert

**High**: Significant vulnerability discovered, potential for major impact
* **Response Time**: Within hours
* **Actions**: Expedited patch development, security advisory preparation

**Medium**: Security issue with limited impact or difficult exploitation
* **Response Time**: Within days
* **Actions**: Standard patch process, included in next release

**Low**: Minor security concern, mostly theoretical
* **Response Time**: Within weeks
* **Actions**: Fixed in regular development cycle

### Incident Response Team

Our incident response team consists of:
* Security engineers (24/7 on-call rotation)
* Core protocol developers
* Guardian operators
* Legal counsel
* Communications team

### Communication During Incidents

* **Internal**: Secure communication channels for coordination
* **Public**: Timely updates through official channels (Twitter, Discord, website)
* **Media**: Coordinated media response through official spokesperson
* **Users**: Direct communication with affected users when possible
* **Transparency**: Post-mortem reports published after incidents are resolved

## Audit Reports

All Wormhole smart contracts undergo regular security audits by leading firms:

* [Trail of Bits](https://github.com/wormhole-foundation/wormhole/tree/main/audits)
* [Neodyme](https://github.com/wormhole-foundation/wormhole/tree/main/audits)
* [Kudelski Security](https://github.com/wormhole-foundation/wormhole/tree/main/audits)
* [OtterSec](https://github.com/wormhole-foundation/wormhole/tree/main/audits)

Audit reports are publicly available in the `/audits` directory.

## Security Updates

Security updates are distributed through:
* **GitHub Security Advisories**: For repository watchers
* **Email Notifications**: For registered bridge operators
* **Social Media**: [@WormholeCrypto](https://twitter.com/WormholeCrypto)
* **Discord**: Official Wormhole Discord server
* **Blog**: https://wormhole.com/blog

## Compliance and Legal

### Regulatory Compliance

We comply with applicable laws and regulations in all jurisdictions where we operate, including:
* Anti-Money Laundering (AML) regulations
* Know Your Customer (KYC) requirements for certain services
* Sanctions screening (OFAC, EU, UN)
* Data protection regulations (GDPR, CCPA)

### Legal Actions

For security incidents involving theft or fraud:
* We cooperate fully with law enforcement
* We pursue civil remedies to recover stolen funds
* We may publicize incidents to protect the community (respecting victim privacy)
* We share threat intelligence with other projects and industry groups

### Blacklist Appeals

While blacklists are intended to be permanent, we recognize that errors can occur:

* Appeals can be submitted to appeals@wormhole.com
* Appeals require substantial evidence that the blacklisting was in error
* Appeals are reviewed by governance
* Successful appeals require a governance vote to remove the blacklist
* The burden of proof is on the appellant

## Security Contacts

* **General Security**: security@wormhole.com
* **Emergency Incidents**: emergency@wormhole.com  
* **Bug Bounty**: bugbounty@wormhole.com
* **Blacklist Appeals**: appeals@wormhole.com
* **Guardian Operators**: guardians@wormhole.com

## PGP Public Key

Our PGP public key for encrypted communications is available at:
https://wormhole.com/security/pgp-key.asc

Fingerprint: `[To be added]`

---

## Acknowledgments

We thank the security researchers and community members who have helped make Wormhole more secure:

* [List of security researchers who have contributed]
* [Bug bounty recipients]
* [Community members who reported issues]

Your contributions help protect billions of dollars in user funds and maintain trust in cross-chain infrastructure.

---

*Last updated: April 2026*

*For the latest version of this security policy, visit: https://github.com/wormhole-foundation/wormhole/blob/main/SECURITY_POLICY.md*
