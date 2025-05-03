// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract ABIEncoder {
//题目#2
//ABI 编码和解码
//完善ABIEncoder合约的encodeUint和encodeMultiple函数，使用abi.encode对参数进行编码并返回
//完善ABIDecoder合约的decodeUint和decodeMultiple函数，使用abi.decode将字节数组解码成对应类型的数据
    function encodeUint(uint256 value) public pure returns (bytes memory) {
        return abi.encode(value);
    }

    function encodeMultiple(
        uint num,
        string memory text
    ) public pure returns (bytes memory) {
        return abi.encode(num, text);
    }
}

contract ABIDecoder {
    function decodeUint(bytes memory data) public pure returns (uint) {
        return abi.decode(data, (uint));
    }

    function decodeMultiple(
        bytes memory data
    ) public pure returns (uint, string memory) {
        return abi.decode(data, (uint, string));
    }
}