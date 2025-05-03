// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//完善合约，实现以下功能：
//
//设置 Token 名称（name）："BaseERC20"
//设置 Token 符号（symbol）："BERC20"
//设置 Token 小数位decimals：18
//设置 Token 总量（totalSupply）:100,000,000
//允许任何人查看任何地址的 Token 余额（balanceOf）
//允许 Token 的所有者将他们的 Token 发送给任何人（transfer）；转帐超出余额时抛出异常(require),并显示错误消息 “ERC20: transfer amount exceeds balance”。
//允许 Token 的所有者批准某个地址消费他们的一部分Token（approve）
//允许任何人查看一个地址可以从其它账户中转账的代币数量（allowance）
//允许被授权的地址消费他们被授权的 Token 数量（transferFrom）；
//转帐超出余额时抛出异常(require)，异常信息：“ERC20: transfer amount exceeds balance”
//转帐超出授权数量时抛出异常(require)，异常消息：“ERC20: transfer amount exceeds allowance”。


/**
 * @title BaseERC20
 * @dev 实现了 ERC20 标准的基础代币合约，包含代币的基本功能，如转账、授权等。
 */
contract BaseERC20 {
    // 代币的名称
    string public name;
    // 代币的符号
    string public symbol;
    // 代币的小数位数
    uint8 public decimals;
    // 代币的总供应量
    uint256 public totalSupply;

    // 记录每个地址的代币余额
    mapping (address => uint256) balances;
    // 记录授权信息，_owner 授权 _spender 可以花费的代币数量
    mapping (address => mapping (address => uint256)) allowances;

    // 转账事件，当发生代币转账时触发
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 授权事件，当设置授权额度时触发
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev 合约构造函数，在合约部署时初始化代币的基本信息，并将总供应量分配给部署者。
     */
    constructor()  {
     // 修改代币名称为预期值
        name = "BaseERC20";
        // 修改代币符号为预期值
        symbol = "BERC20";
        // 设置代币小数位数
        decimals = 18;
        // 计算代币总供应量，考虑小数位数
        totalSupply = 100000000 * 10 ** uint256(decimals);
        // 将总供应量分配给合约部署者
        balances[msg.sender] = totalSupply;
    }

    /**
     * @dev 查询指定地址的代币余额。
     * @param _owner 要查询余额的地址。
     * @return balance 指定地址的代币余额。
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        // 返回指定地址的余额
        balance = balances[_owner];
        return balance;
    }

    /**
     * @dev 将调用者的代币转账给指定地址。
     * @param _to 接收代币的地址。
     * @param _value 转账的代币数量。
     * @return success 转账是否成功。
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // 检查转账金额是否超出调用者的余额
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        // 减少调用者的余额
        balances[msg.sender] -= _value;
        // 增加接收者的余额
        balances[_to] += _value;
        // 触发转账事件
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev 授权指定地址可以花费调用者的部分代币。
     * @param _spender 被授权的地址。
     * @param _value 授权的代币数量。
     * @return success 授权是否成功。
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // 设置授权额度
        allowances[msg.sender][_spender] = _value;
        // 触发授权事件
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev 查询一个地址被授权可以从另一个地址转账的代币数量。
     * @param _owner 代币所有者的地址。
     * @param _spender 被授权的地址。
     * @return remaining 剩余的授权额度。
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        // 返回授权额度
        remaining = allowances[_owner][_spender];
        return remaining;
    }

    /**
     * @dev 被授权的地址从指定地址转账代币给另一个地址。
     * @param _from 转出代币的地址。
     * @param _to 接收代币的地址。
     * @param _value 转账的代币数量。
     * @return success 转账是否成功。
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // 检查转账金额是否超出转出地址的余额
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        // 检查转账金额是否超出授权额度
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        // 减少转出地址的余额
        balances[_from] -= _value;
        // 增加接收地址的余额
        balances[_to] += _value;
        // 减少授权额度
        allowances[_from][msg.sender] -= _value;
        // 触发转账事件
        emit Transfer(_from, _to, _value);
        return true;
    }
}