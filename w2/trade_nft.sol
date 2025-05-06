// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 引入 OpenZeppelin 标准合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @title MyNFT - 简单的 ERC721 NFT 合约
contract MyNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyNFT", "MNFT") {}

    /// @notice 铸造一个新的 NFT，返回其 tokenId
    function mint(address to) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _mint(to, tokenId);
        _tokenIdCounter.increment();
        return tokenId;
    }
}

/// @title NFTMarket - 支持使用自定义 ERC20 Token 买卖 NFT 的市场合约
contract NFTMarket is IERC721Receiver {
    using SafeMath for uint256;

    struct Listing {
        address seller; // 卖家地址
        uint256 price;  // 要求的 ERC20 token 数量
    }

    mapping(uint256 => Listing) public listings; // NFT ID 到上架信息的映射

    MyNFT public nft;
    MyERC20 public token;

    constructor(MyNFT _nft, MyERC20 _token) {
        nft = _nft;
        token = _token;
    }

    /// @notice 上架 NFT 到市场，设定价格
    function list(uint256 tokenId, uint256 price) public {
        require(nft.ownerOf(tokenId) == msg.sender, "Not NFT owner");
        require(price > 0, "Price must be > 0");

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price
        });

        // 市场托管 NFT
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    /// @notice 购买 NFT（由 tokensReceived 回调或 buyNFT 手动调用）
    /// @param tokenId 要购买的 NFT ID
    /// @param amount 支付的 ERC20 Token 数量
    /// @param buyer 买家地址
    function buyNFT(uint256 tokenId, uint256 amount, address buyer) public {
        Listing memory listing = listings[tokenId];
        require(listing.price == amount, "Incorrect price");
        require(listing.seller != address(0), "NFT not listed");

        // 将 Token 从买家转给卖家
        require(token.transferFrom(buyer, listing.seller, amount), "Token transfer failed");

        // 将 NFT 转移给买家
        nft.safeTransferFrom(address(this), buyer, tokenId);

        // 移除 listing
        delete listings[tokenId];
    }

    /// @notice 实现 IERC721Receiver 接口，接收 NFT 时被调用
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

/// @title MyERC20 - 自定义 ERC20 Token，扩展支持 transferWithData 和 tokensReceived
contract MyERC20 is ERC20 {
    NFTMarket public market;

    constructor(uint256 initialSupply) ERC20("MyERC20", "MERC20") {
        _mint(msg.sender, initialSupply);
    }

    /// @notice 设置 NFTMarket 合约地址（只需设置一次）
    function setMarket(NFTMarket _market) external {
        market = _market;
    }

    /// @notice 扩展的转账函数，支持附带 NFT ID 数据用于购买
    /// @param to 接收者（一般为市场合约）
    /// @param amount Token 金额
    /// @param data 附带的 NFT tokenId 编码数据
    function transferWithData(address to, uint256 amount, bytes calldata data) external returns (bool) {
        _transfer(msg.sender, to, amount);

        // 调用 recipient 合约的 tokensReceived 回调
        require(to.code.length > 0, "Recipient must be contract");

        (bool success, ) = to.call(
            abi.encodeWithSignature(
                "tokensReceived(address,address,address,uint256,bytes)",
                msg.sender,   // operator
                msg.sender,   // from
                to,           // to
                amount,       // amount
                data          // data (encoded tokenId)
            )
        );
        require(success, "tokensReceived failed");
        return true;
    }

    /// @notice 由市场合约调用的回调函数，触发实际 NFT 购买逻辑
    /// @param from Token 来源地址（买家）
    /// @param amount 支付的金额
    /// @param data 附带的 NFT tokenId
    function tokensReceived(
        address /* operator */,
        address from,
        address /* to */,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4) {
        require(msg.sender == address(this), "Unauthorized token callback");
        require(address(market) != address(0), "Market not set");

        // 解码 data 获取 NFT tokenId
        uint256 tokenId = abi.decode(data, (uint256));

        // 由市场完成购买
        market.buyNFT(tokenId, amount, from);

        return this.tokensReceived.selector;
    }
}
