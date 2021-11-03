//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenFarm is Ownable{

    string public name = "Dapp Token Farm";
    IERC20 public dappToken;
    address[] public stakers;


    //stakeTokens
    address[] public allowedTokens;
    mapping(address => mapping(address => uint256)) public stakingBalance;
    mapping(address => uint256) public uniqueTokensStaked;
    mapping(address => address) public tokenPriceFeedMapping;

    constructor(address _dappTokenAddress) public {
        dappToken = IERC20(_dappTokenAddress);
    }



    function addAllowedTokens(address token) public onlyOwner {
        allowedTokens.push(token);
    }   

    function stakeTokens(uint256 amount, address token) public {
        require(amount > 0, "Amount cannot be 0");
        require(tokenIsAllowed(token), "Token is not allowed");
        updateUniqueTokensStaked(msg.sender, token);

        // transfer the token from them to us
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        stakingBalance[token][msg.sender] = stakingBalance[token][msg.sender] + amount;
        if (uniqueTokensStaked[msg.sender] == 1) {
            stakers.push(msg.sender);
        }
    }

    


    function tokenIsAllowed(address token) public returns (bool){
        for(uint256 allowedTokensIndex =0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++)   
            {
            if (allowedTokens[allowedTokensIndex] == token) {
                return true;
                }
            return false;
            }        
    }

    //unstakeTokens
    function unstakeTokens(address token) public {
        // Fetch staking balance
        uint256 balance = stakingBalance[token][msg.sender];
        require(balance > 0, "staking balance cannot be 0");
        IERC20(token).transfer(msg.sender, balance);
        stakingBalance[token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
    }




    //issueTokens

    function issueTokens() public onlyOwner{
        for (
            uint256 stakersIndex=0;
            stakersIndex < stakers.length;
            stakersIndex++
        ) {
            address recipient = stakers[stakersIndex];
            dappToken.transfer(recipient, getUserTotalValue(recipient));
        }
    }


    //helper functions
    function updateUniqueTokensStaked(address user, address token) internal {
        if (stakingBalance[token][user] <= 0) {
            uniqueTokensStaked[user] = uniqueTokensStaked[user] + 1;
        }
    }

    function getUserTotalValue(address user) public view returns(uint256) {
        uint256 totalValue = 0;
        if (uniqueTokensStaked[user] > 0){
            for (
                uint256 allowedTokensIndex = 0;
                allowedTokensIndex < allowedTokens.length;
                allowedTokensIndex++
            ) {
                totalValue = totalValue + getUserTokenStakingBalanceEthValue(
                    user,
                    allowedTokens[allowedTokensIndex]
                );

            }
        }
        return totalValue;
    }

    function getUserTokenStakingBalanceEthValue(address user, address token) 
        public 
        view 
        returns(uint256) 
    {

        if (uniqueTokensStaked[user] <= 0) {
            return 0;
        }

        (uint256 price, uint8 decimals) = getTokenEthPrice(token);

        return (stakingBalance[token][user] * price) / (10**uint256(decimals));

    }

    function getTokenEthPrice(address token) public view returns(uint256, uint8){
        address priceFeedAddress = tokenPriceFeedMapping[token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return (uint256(price), priceFeed.decimals());
    }
    
    

    
}
