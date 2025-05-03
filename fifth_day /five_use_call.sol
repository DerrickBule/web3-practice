// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
//题目#5
//call 调用函数
//
//补充完整 Caller 合约的 callSetValue 方法，用于设置 Callee 合约的 value 值。要求：
//
//使用 call 方法调用用 Callee 的 setValue 方法，并附带 1 Ether
//如果发送失败，抛出“call function failed”异常并回滚交易。
//如果发送成功，则返回 true
pragma solidity ^0.8.0;

contract Callee {
    uint256 value;

    function getValue() public view returns (uint256) {
        return value;
    }

    function setValue(uint256 value_) public payable {
        require(msg.value > 0);
        value = value_;
    }
}

contract Caller {
    function callSetValue(address callee, uint256 value) public returns (bool) {
        // 编码函数调用，生成调用数据
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", value);
        // 使用 call 方法调用 Callee 的 setValue 方法，并附带 1 Ether
        (bool success, ) = callee.call{value: 1 ether}(data);
        // 检查调用是否成功
        require(success, "call function failed");
        return success;
    }
}