// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleTransferContract {
    // Bank 合约地址
    address payable public bankAddress;

    constructor(address _bankAddress) {
        // 将传入的地址转换为 payable 类型并赋值给 bankAddress
        bankAddress = payable(_bankAddress);
    }

    // 向 Bank 合约转账的函数
    function transferToBank() external payable {
        require(msg.value > 0, "Transfer amount must be greater than 0");
        // 向 Bank 合约地址转账
        bankAddress.transfer(msg.value);
    }
}