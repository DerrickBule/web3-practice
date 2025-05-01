// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义 IBank 接口
interface IBank {
    function deposit() external payable;
    function withdraw(uint amount) external;
    function getContractBalance() external view returns (uint);
    function transferOwnership(address newOwner) external;
}
// Bank 实现 IBank
contract Bank {
    address public owner;
    mapping(address => uint) public balances;
    address[3] public topDepositors;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }

    // 添加 virtual 关键字，允许函数被重写
    function deposit() public payable virtual {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
        _updateTopDepositors(msg.sender);
    }

    // 添加 virtual 关键字，允许函数被重写
    function withdraw(uint amount) public virtual onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance in contract");
        payable(owner).transfer(amount);
    }

    function _updateTopDepositors(address user) internal {
        uint amount = balances[user];
        for (uint i = 0; i < 3; i++) {
            if (topDepositors[i] == user) {
                _sortTopDepositors();
                return;
            }
        }

        for (uint i = 0; i < 3; i++) {
            if (amount > balances[topDepositors[i]]) {
                for (uint j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = user;
                break;
            }
        }
    }

    function _sortTopDepositors() internal {
        for (uint i = 0; i < 2; i++) {
            for (uint j = i + 1; j < 3; j++) {
                if (balances[topDepositors[j]] > balances[topDepositors[i]]) {
                    address temp = topDepositors[i];
                    topDepositors[i] = topDepositors[j];
                    topDepositors[j] = temp;
                }
            }
        }
    }

    // 添加 virtual 关键字，允许函数被重写
    function getContractBalance() public view virtual returns (uint) {
        return address(this).balance;
    }

    // 添加 virtual 关键字，允许函数被重写
    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;
    }
}


// BigBank 合约继承自 Bank
contract BigBank is Bank, IBank {
    // 定义存款金额限制修饰器
    modifier minDeposit() {
        require(msg.value > 0.001 ether, "Deposit must be greater than 0.001 ether");
        _;
    }

    // 重写 deposit 函数，添加金额限制，显式指定要重写的合约
    function deposit() public payable override(IBank, Bank) minDeposit {
        super.deposit();
    }

    // 重写 getContractBalance 函数
    function getContractBalance() public view override(IBank, Bank) returns (uint) {
        return super.getContractBalance();
    }

    // 重写 transferOwnership 函数 变更 Owner
    function transferOwnership(address newOwner) public override(IBank, Bank) onlyOwner {
        super.transferOwnership(newOwner);
    }

    // 重写 withdraw 函数
    function withdraw(uint amount) public override(IBank, Bank) onlyOwner {
        super.withdraw(amount);
    }
}


// Admin 合约
contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    // 取款函数
    function adminWithdraw(IBank bank) public onlyOwner {
        uint balance = bank.getContractBalance();
        // 调用 bank 合约的 withdraw 函数，由于 BigBank 的 owner 是 Admin 合约地址，资金会直接到 Admin 合约
        bank.withdraw(balance);

    }
}
