// SPDX-License-Identifier: UNLICENSED
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    // 记录每个用户存入的 Token 数量
    mapping(address => uint256) public balances;
    // 存储 Token 合约地址
    IERC20 public token;

    /**
     * @dev 构造函数，初始化 Token 合约地址。
     * @param _token 要操作的 Token 合约地址。
     */
    constructor(IERC20 _token) {
        token = _token;
    }

    /**
     * @dev 用户将 Token 存入 TokenBank。
     * @param _amount 要存入的 Token 数量。
     */
    function deposit(uint256 _amount) public {
        // 从用户账户转移 Token 到合约账户
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        // 增加用户的存款余额
        balances[msg.sender] += _amount;
    }

    /**
     * @dev 用户从 TokenBank 取出之前存入的 Token。
     * @param _amount 要取出的 Token 数量。
     */
    function withdraw(uint256 _amount) public {
        // 检查用户的存款余额是否足够
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        // 减少用户的存款余额
        balances[msg.sender] -= _amount;
        // 从合约账户转移 Token 到用户账户
        require(token.transfer(msg.sender, _amount), "Transfer failed");
    }
}