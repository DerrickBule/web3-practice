pragma solidity ^0.8.0;
//题目#6
//使用 delegatecall 调用函数
//
//补充完整 Caller 合约 的 delegateSetValue 方法，调用 Callee 的 setValue 方法用于设置 value 值。要求：
//
//使用 delegatecall
//如果发送失败，抛出“delegate call failed”异常并回滚交易。
contract Callee {
    uint256 public value;

    function setValue(uint256 _newValue) public {
        value = _newValue;
    }
}

contract Caller {
    uint256 public value;

    function delegateSetValue(address callee, uint256 _newValue) public {
        // 编码函数调用，生成调用数据
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", _newValue);
        // 使用 delegatecall 调用目标合约的函数
        (bool success, ) = callee.delegatecall(data);
        // 检查调用是否成功
        if (!success) {
            // 若调用失败，抛出异常并回滚交易
            revert("delegate call failed");
        }
    }
}