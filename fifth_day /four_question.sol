// SPDX-License-Identifier: MIT


//题目#4
//encodeWithSignature、encodeWithSelector 和 encodeCall
//
//补充完整getDataByABI，对getData函数签名及参数进行编码，调用成功后解码并返回数据
//补充完整setDataByABI1，使用abi.encodeWithSignature()编码调用setData函数，确保调用能够成功
//补充完整setDataByABI2，使用abi.encodeWithSelector()编码调用setData函数，确保调用能够成功
//补充完整setDataByABI3，使用abi.encodeCall()编码调用setData函数，确保调用能够成功

pragma solidity ^0.8.0;

contract DataStorage {
    string private data;

    function setData(string memory newData) public {
        data = newData;
    }

    function getData() public view returns (string memory) {
        return data;
    }
}

contract DataConsumer {
    address private dataStorageAddress;

    constructor(address _dataStorageAddress) {
        dataStorageAddress = _dataStorageAddress;
    }
        // 对getData函数签名进行编码
    function getDataByABI() public returns (string memory) {
        bytes memory payload = abi.encodeWithSignature("getData()");
        (bool success, bytes memory data) = dataStorageAddress.call(payload);
        // 解码返回的数据
        require(success, "call function failed");
         return abi.decode(data, (string));
    }

    function setDataByABI1(string calldata newData) public returns (bool) {
        // 使用abi.encodeWithSignature()编码调用setData函数
         bytes memory payload = abi.encodeWithSignature("setData(string)", newData);
        (bool success, ) = dataStorageAddress.call(payload);
        return success;
    }

    function setDataByABI2(string calldata newData) public returns (bool) {
            // 获取setData函数的选择器
        bytes4 selector = bytes4(keccak256("setData(string)"));
        // 使用abi.encodeWithSelector()编码调用setData函数
        bytes memory payload = abi.encodeWithSelector(selector, newData);
        (bool success, ) = dataStorageAddress.call(payload);
        return success;
    }

    function setDataByABI3(string calldata newData) public returns (bool) {
           // 使用abi.encodeCall()编码调用setData函数
        bytes memory payload = abi.encodeCall(DataStorage.setData, (newData));
        (bool success, ) = dataStorageAddress.call(payload);
        return success;
    }
}
