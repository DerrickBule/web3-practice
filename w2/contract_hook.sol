// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 扩展的 ERC20 合约
contract ExtendedERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // 初始铸造 1000 个代币给合约部署者
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    /**
     * @dev 判断地址是否为合约地址
     * @param addr 要检查的地址
     * @return 是否为合约地址
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     * @dev 带有回调功能的转账函数
     * @param to 接收方地址
     * @param amount 转账金额
     * @return 转账是否成功
     */
    function transferWithCallback(address to, uint256 amount) public returns (bool) {
        // 先执行标准的转账操作
        bool success = super.transfer(to, amount);
        if (success && isContract(to)) {
            ITokenReceiver(to).tokensReceived(msg.sender, amount);
        }
        return success;
    }
}

// 定义 TokenReceiver 接口
interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}
// 假设 TokenBank 合约如下
contract TokenBank {
    // 记录每个用户在 TokenBank 中的每种 ERC20 代币的余额
    mapping(address => mapping(address => uint256)) public balances;

    // 存款事件
    event Deposit(address indexed user, address indexed token, uint256 amount);
    // 取款事件
    event Withdraw(address indexed user, address indexed token, uint256 amount);

    constructor() {}

    /**
     * @dev 存款函数，用户将 ERC20 代币存入 TokenBank
     * @param token 要存入的 ERC20 代币地址
     * @param amount 存入的代币数量
     */
    function deposit(address token, uint256 amount) external {
        // 从用户账户转移代币到 TokenBank 合约
        require(ERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        // 更新用户的存款余额
        balances[msg.sender][token] += amount;
        // 触发存款事件
        emit Deposit(msg.sender, token, amount);
    }

    /**
     * @dev 取款函数，用户从 TokenBank 取出 ERC20 代币
     * @param token 要取出的 ERC20 代币地址
     * @param amount 取出的代币数量
     */
    function withdraw(address token, uint256 amount) external {
        // 检查用户余额是否足够
        require(balances[msg.sender][token] >= amount, "Insufficient balance");
        // 更新用户的存款余额
        balances[msg.sender][token] -= amount;
        // 将代币从 TokenBank 合约转移到用户账户
        require(ERC20(token).transfer(msg.sender, amount), "Transfer failed");
        // 触发取款事件
        emit Withdraw(msg.sender, token, amount);
    }
}


// 继承 TokenBank 编写 TokenBankV2
contract TokenBankV2 is TokenBank, ITokenReceiver {
    // 记录用户存款余额
    mapping(address => uint256) public balances;

    /**
     * @dev 实现 tokensReceived 方法，记录存款
     * @param from 存款用户地址
     * @param amount 存款金额
     */
    function tokensReceived(address from, uint256 amount) external override {
        balances[from] += amount;
    }

    /**
     * @dev 用户提取存款
     * @param amount 提取的金额
     * @param token 要提取的 ERC20 代币地址
     */
    function withdraw(uint256 amount, address token) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        require(ExtendedERC20(token).transfer(msg.sender, amount), "Transfer failed");
    }
}