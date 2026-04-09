// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TokenBalanceAndTransfer
 * @notice Script to check token balances and transfer tokens to a new address
 * @dev Only allows distribution when explicitly authorized (Kushmanmb = true)
 */
contract TokenBalanceAndTransfer is Script {
    // State variable to control distribution authorization
    bool public kushmanmbAuthorized = false;
    
    // Event for logging balance checks
    event BalanceChecked(address indexed token, uint256 balance);
    
    // Event for logging transfers
    event TokensTransferred(address indexed token, address indexed to, uint256 amount);
    
    struct TokenBalance {
        address tokenAddress;
        uint256 balance;
    }
    
    /**
     * @notice Set authorization flag
     * @param authorized Whether distribution is authorized
     */
    function setKushmanmbAuthorization(bool authorized) public {
        kushmanmbAuthorized = authorized;
    }
    
    /**
     * @notice Get inventory of current token balances
     * @param tokens Array of token addresses to check
     * @param holderAddress Address to check balances for
     * @return balances Array of token balances
     */
    function getTokenBalances(
        address[] memory tokens,
        address holderAddress
    ) public view returns (TokenBalance[] memory balances) {
        balances = new TokenBalance[](tokens.length);
        
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            balances[i] = TokenBalance({
                tokenAddress: tokens[i],
                balance: token.balanceOf(holderAddress)
            });
        }
        
        return balances;
    }
    
    /**
     * @notice Get top 5 token balances and log them
     * @param tokens Array of up to 5 token addresses
     * @param holderAddress Address to check balances for
     */
    function getTop5TokenBalances(
        address[] memory tokens,
        address holderAddress
    ) public {
        require(tokens.length <= 5, "Maximum 5 tokens allowed");
        
        console.log("=== Token Balance Inventory (Top 5) ===");
        console.log("Holder Address:", holderAddress);
        console.log("");
        
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 balance = token.balanceOf(holderAddress);
            
            console.log("Token", i + 1, "Address:", tokens[i]);
            console.log("Balance:", balance);
            console.log("");
            
            emit BalanceChecked(tokens[i], balance);
        }
    }
    
    /**
     * @notice Transfer tokens to a new address (only if authorized)
     * @param token Token address to transfer
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function transferTokens(
        address token,
        address to,
        uint256 amount
    ) public {
        require(kushmanmbAuthorized, "Distribution not authorized: Kushmanmb must be true");
        require(to != address(0), "Cannot transfer to zero address");
        require(amount > 0, "Amount must be greater than zero");
        
        IERC20 tokenContract = IERC20(token);
        
        console.log("=== Token Transfer ===");
        console.log("Token:", token);
        console.log("Recipient:", to);
        console.log("Amount:", amount);
        
        // Transfer tokens
        bool success = tokenContract.transfer(to, amount);
        require(success, "Token transfer failed");
        
        emit TokensTransferred(token, to, amount);
        
        console.log("Transfer completed successfully");
    }
    
    /**
     * @notice Main execution function - combines balance check and transfer
     * @param tokens Array of up to 5 token addresses to check
     * @param tokenToTransfer Token to transfer (can be one of the checked tokens)
     * @param recipient Address to receive tokens
     * @param amount Amount to transfer
     * @param authorized Whether to authorize the transfer
     */
    function run(
        address[] memory tokens,
        address tokenToTransfer,
        address recipient,
        uint256 amount,
        bool authorized
    ) public {
        vm.startBroadcast();
        
        // Set authorization
        setKushmanmbAuthorization(authorized);
        
        console.log("=== Wormhole Token Balance and Transfer Script ===");
        console.log("Authorization (Kushmanmb):", authorized);
        console.log("");
        
        // Get and display top 5 token balances
        getTop5TokenBalances(tokens, msg.sender);
        
        // Only transfer if authorized
        if (authorized) {
            transferTokens(tokenToTransfer, recipient, amount);
        } else {
            console.log("Transfer skipped: Not authorized (Kushmanmb must be true)");
        }
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Dry run function for testing without broadcasting
     */
    function dryRun(
        address[] memory tokens,
        address holderAddress
    ) public view {
        console.log("=== Dry Run: Token Balance Check ===");
        console.log("Holder Address:", holderAddress);
        console.log("");
        
        TokenBalance[] memory balances = getTokenBalances(tokens, holderAddress);
        
        for (uint256 i = 0; i < balances.length; i++) {
            console.log("Token", i + 1, ":", balances[i].tokenAddress);
            console.log("Balance:", balances[i].balance);
            console.log("");
        }
    }
}
