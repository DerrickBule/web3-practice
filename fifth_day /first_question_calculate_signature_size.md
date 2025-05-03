### 题目#1
    计算以下函数签名的 ABI 编码后的字节大小：
    function transfer(address recipient, uint256 amount)

ABI：Application Binary Interface 应用程序二进制接口
• ABI 接口描述： 定义如何与合约交互
• ABI 编码
• 函数选择器：对函数签名计算Keccak-256哈希，取前 4 个字节
• 参数编码：

function transfer(address recipient, uint256 amount)
1. 函数选择器：Keccak-256(transfer(address,uint256)) = 0xa9059cbb
2. 参数编码：
• address：20 填充到32字节
• uint256：类型暂用32 字节
• 总大小： 32 + 32 = 64 字节
3. 加上ABI前置的4个 总大小： 4 + 64 = 68 字节
