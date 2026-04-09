// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {TokenImplementation} from "../contracts/bridge/token/TokenImplementation.sol";
import "forge-std/Script.sol";

/**
 * @title DistributeTokens
 * @notice Script for distributing tokens with owner permission checks
 * @dev This script allows authorized owners to distribute tokens daily
 * 
 * Configuration:
 * - Authorized owners: Kushmanmb, yaketh.eth, kushmanmb.eth
 * - See ethereum/config/distribution-config.json for configuration details
 * 
 * Usage:
 *   forge script forge-scripts/DistributeTokens.s.sol:DistributeTokens \
 *     --sig "run(address,address[],uint256[])" \
 *     <tokenAddress> <recipients> <amounts> \
 *     --rpc-url <rpc> --broadcast
 */
contract DistributeTokens is Script {
    // ⚠️ SECURITY WARNING: THESE ARE PLACEHOLDER ADDRESSES - MUST BE UPDATED BEFORE DEPLOYMENT
    // Authorized owner addresses (replace with actual addresses)
    // These should match the addresses in distribution-config.json
    // DO NOT DEPLOY WITH THESE TEST ADDRESSES - THEY ARE NOT SECURE
    address constant OWNER_KUSHMANMB = address(0xDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF);
    address constant OWNER_YAKETH = address(0xCAFEBABECAFEBABECAFEBABECAFEBABECAFEBABE);
    address constant OWNER_KUSHMANMB_ETH = address(0xFEEDFACEFEEDFACEFEEDFACEFEEDFACEFEEDFACE);
    
    // Safety limits
    uint256 constant MAX_SINGLE_DISTRIBUTION = 100 ether;
    uint256 constant MAX_RECIPIENTS_PER_BATCH = 100;
    
    event TokensDistributed(
        address indexed token,
        address indexed recipient,
        uint256 amount,
        address indexed distributor
    );
    
    event DistributionBatchCompleted(
        address indexed token,
        uint256 totalAmount,
        uint256 recipientCount,
        address indexed distributor
    );
    
    /**
     * @notice Check if placeholder addresses are still in use (MUST be false for production)
     */
    function _hasPlaceholderAddresses() internal pure returns (bool) {
        // Check if any owner address appears to be a placeholder
        if (OWNER_KUSHMANMB == address(0xDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF)) return true;
        if (OWNER_YAKETH == address(0xCAFEBABECAFEBABECAFEBABECAFEBABECAFEBABE)) return true;
        if (OWNER_KUSHMANMB_ETH == address(0xFEEDFACEFEEDFACEFEEDFACEFEEDFACEFEEDFACE)) return true;
        
        // Also check for zero addresses
        if (OWNER_KUSHMANMB == address(0)) return true;
        if (OWNER_YAKETH == address(0)) return true;
        if (OWNER_KUSHMANMB_ETH == address(0)) return true;
        
        return false;
    }
    
    /**
     * @notice Dry run for testing without broadcasting
     */
    function dryRun(
        address tokenAddress,
        address[] memory recipients,
        uint256[] memory amounts
    ) public view {
        // Security check: warn if placeholder addresses detected
        if (_hasPlaceholderAddresses()) {
            console.log("⚠️  WARNING: PLACEHOLDER ADDRESSES DETECTED!");
            console.log("⚠️  DO NOT USE IN PRODUCTION - UPDATE OWNER ADDRESSES FIRST!");
        }
        
        _validateInputs(tokenAddress, recipients, amounts);
        console.log("Dry run successful - validation passed");
        console.log("Token address:", tokenAddress);
        console.log("Number of recipients:", recipients.length);
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        console.log("Total amount to distribute:", totalAmount);
    }
    
    /**
     * @notice Main execution function for token distribution
     * @param tokenAddress Address of the token contract
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts to distribute (must match recipients length)
     */
    function run(
        address tokenAddress,
        address[] memory recipients,
        uint256[] memory amounts
    ) public returns (uint256 totalDistributed) {
        // Security check: prevent deployment with placeholder addresses
        require(!_hasPlaceholderAddresses(), 
            "DistributeTokens: SECURITY ERROR - Placeholder addresses detected! Update owner addresses before deployment.");
        
        _validateInputs(tokenAddress, recipients, amounts);
        
        vm.startBroadcast();
        totalDistributed = _distribute(tokenAddress, recipients, amounts);
        vm.stopBroadcast();
        
        console.log("Distribution completed successfully");
        console.log("Total amount distributed:", totalDistributed);
    }
    
    /**
     * @notice Simplified distribution for a single recipient
     * @param tokenAddress Address of the token contract
     * @param recipient Recipient address
     * @param amount Amount to distribute
     */
    function runSingle(
        address tokenAddress,
        address recipient,
        uint256 amount
    ) public returns (uint256) {
        address[] memory recipients = new address[](1);
        recipients[0] = recipient;
        
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        
        return run(tokenAddress, recipients, amounts);
    }
    
    /**
     * @notice Internal distribution logic
     */
    function _distribute(
        address tokenAddress,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal returns (uint256 totalDistributed) {
        TokenImplementation token = TokenImplementation(tokenAddress);
        
        // Verify the caller is an authorized owner
        address tokenOwner = token.owner();
        address caller = msg.sender;
        
        require(
            caller == tokenOwner || 
            caller == OWNER_KUSHMANMB || 
            caller == OWNER_YAKETH || 
            caller == OWNER_KUSHMANMB_ETH,
            "DistributeTokens: Caller is not an authorized owner"
        );
        
        console.log("Distributing tokens as:", caller);
        console.log("Token owner:", tokenOwner);
        
        // Distribute tokens to each recipient
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "DistributeTokens: Invalid recipient address");
            require(amounts[i] > 0, "DistributeTokens: Amount must be greater than zero");
            require(amounts[i] <= MAX_SINGLE_DISTRIBUTION, "DistributeTokens: Amount exceeds maximum");
            
            // Mint tokens to the recipient
            // Note: This requires the caller to be the token owner or have owner permissions
            token.mint(recipients[i], amounts[i]);
            
            emit TokensDistributed(tokenAddress, recipients[i], amounts[i], caller);
            
            totalDistributed += amounts[i];
            
            console.log("Distributed", amounts[i], "tokens to", recipients[i]);
        }
        
        emit DistributionBatchCompleted(tokenAddress, totalDistributed, recipients.length, caller);
    }
    
    /**
     * @notice Validate input parameters
     */
    function _validateInputs(
        address tokenAddress,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal pure {
        require(tokenAddress != address(0), "DistributeTokens: Invalid token address");
        require(recipients.length > 0, "DistributeTokens: No recipients provided");
        require(recipients.length == amounts.length, "DistributeTokens: Recipients and amounts length mismatch");
        require(recipients.length <= MAX_RECIPIENTS_PER_BATCH, "DistributeTokens: Too many recipients in batch");
    }
    
    /**
     * @notice Check if an address is an authorized owner
     */
    function isAuthorizedOwner(address addr) public pure returns (bool) {
        return addr == OWNER_KUSHMANMB || 
               addr == OWNER_YAKETH || 
               addr == OWNER_KUSHMANMB_ETH;
    }
    
    /**
     * @notice Get the list of authorized owners
     */
    function getAuthorizedOwners() public pure returns (address[] memory) {
        address[] memory owners = new address[](3);
        owners[0] = OWNER_KUSHMANMB;
        owners[1] = OWNER_YAKETH;
        owners[2] = OWNER_KUSHMANMB_ETH;
        return owners;
    }
}
