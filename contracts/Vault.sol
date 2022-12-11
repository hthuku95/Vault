// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

contract Vault is Ownable {

    uint256 private balance;
    uint256 private unlockingDate;
    mapping(address=>uint256) private tokenToBalance;
    address[] private allowedTokens;
    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);

    constructor(uint256 _unlockingDate){
        unlockingDate = _unlockingDate;
    }

    function deposit(address _token,uint256 _amount) public onlyOwner {
        require(verifyToken(_token),"Token is not allowed");
        require(_amount > 0,"Cannot deposit 0");
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        tokenToBalance[_token] += _amount;
        emit Deposit(_amount);
    }

    function withdraw(address _token,uint256 _amount) public onlyOwner {
        require(verifyToken(_token),"Token is not allowed");
        require(_amount > 0,"Cannot withdraw 0");
        require(unlockingDate > block.timestamp,"Can only withdraw after UnlockingDate");
        require(getTokenBalance(_token) > 0,"Vault is empty. Please deposit some funds");
        IERC20(_token).transfer(msg.sender,_amount);
        emit Withdraw(_amount);
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function verifyToken(address _token) public view returns(bool) {
        for (uint256 allowedTokenIndex = 0; allowedTokenIndex < allowedTokens.length; allowedTokenIndex++) {
            if(allowedTokens[allowedTokenIndex] == _token){
                return true;
            }
        }
        return false;
    }

    function getTokenBalance(address _token) public view returns(uint256) {
        return tokenToBalance[_token];
    }
}

