// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    address public owner;

    struct TopDepositor {
        address user;
        uint amount;
    }

    mapping(address => uint) public balances;
    TopDepositor[3] public topDepositors;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // 允许直接发送ETH到合约
    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;

        _updateTopDepositors(msg.sender, balances[msg.sender]);
    }

    function withdraw(uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance in contract");
        payable(owner).transfer(amount);
    }

    function _updateTopDepositors(address user, uint amount) internal {
        // 检查用户是否已经在前3名中
        for (uint i = 0; i < 3; i++) {
            if (topDepositors[i].user == user) {
                topDepositors[i].amount = amount;
                _sortTopDepositors();
                return;
            }
        }

        // 如果不是，检查是否应插入前3
        for (uint i = 0; i < 3; i++) {
            if (amount > topDepositors[i].amount) {
                // 将第3名后移，插入当前用户
                for (uint j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = TopDepositor(user, amount);
                break;
            }
        }
    }

    function _sortTopDepositors() internal {
        // 简单冒泡排序前三
        for (uint i = 0; i < 2; i++) {
            for (uint j = i + 1; j < 3; j++) {
                if (topDepositors[j].amount > topDepositors[i].amount) {
                    TopDepositor memory temp = topDepositors[i];
                    topDepositors[i] = topDepositors[j];
                    topDepositors[j] = temp;
                }
            }
        }
    }

    // 查看当前合约余额
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
