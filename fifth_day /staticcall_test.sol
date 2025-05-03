// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
// 题目#3
// staticcall
// 补充完整 Caller 合约的 callGetData 方法，
// 使用 staticcall 调用 Callee 合约中 getData 函数，并返回值。
// 当调用失败时，抛出“staticcall function failed”异常
contract Callee {
    function getData() public pure returns (uint256) {
        return 42;
    }
}

contract Caller {
     // 映射，用于记录每个用户的存款余额
    mapping(address => uint256) public balances;
    receive() external payable {
        deposit();
    }
    fallback() external payable {
        deposit();
    }
    function deposit() public payable {
        // 存款逻辑
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;

    }

    function callGetData(address callee) public view returns (uint256 data) {
        // call by staticcall
         // 对getData 函数签名进行编码
        bytes memory payload = abi.encodeWithSignature("getData()");
        // 使用staticcall调用Callee合约的getData函数
        (bool success , bytes memory returnData) = callee.staticcall(payload);
        // 当调用失败时，抛出异常
        require(success, "staticcall function failed");
        // 解码返回的数据
        data = abi.decode(returnData, (uint256));
        return data;
    }
}
