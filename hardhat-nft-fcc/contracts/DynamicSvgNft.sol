// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "base64-sol/base64.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error ERC721Metadata__URI_QueryFor_NonExistentToken();

contract DynamicSvgNft is ERC721 {
  // mint
  // store our svg information some where
  // some logic to say "show X image" or "show Y image"

  uint256 private s_tokenCounter;
  string private s_lowImageURI;
  string private s_highImageURI;
  string private constant base64EncodedSvgPrefix = "data:image/svg+xml;base64,";
  AggregatorV3Interface internal immutable i_priceFeed;
  mapping(uint256 => int256) private s_tokenIdToHighValues;

  event CreatedNFT(uint256 indexed tokenId, int256 highValue);

  constructor(
    address priceFeedAddress,
    string memory lowSvg,
    string memory highSvg
  ) ERC721("DYNAMIC SVG NFT", "DNF") {
    s_tokenCounter = 0;
    s_lowImageURI = svgToImageUrl(lowSvg);
    s_highImageURI = svgToImageUrl(highSvg);
    i_priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  function mintNft(int256 highValue) public {
    s_tokenIdToHighValues[s_tokenCounter] = highValue;
    _safeMint(msg.sender, s_tokenCounter);
    emit CreatedNFT(s_tokenCounter, highValue);
    s_tokenCounter = s_tokenCounter + 1;
  }

  // function mintNft(int256 highValue) public {
  //   s_tokenIdToHighValues[s_tokenCounter] = highValue;
  //   s_tokenCounter = s_tokenCounter + 1;
  //   _safeMint(msg.sender, s_tokenCounter);
  //   emit CreatedNFT(s_tokenCounter, highValue);
  // }

  // it returns base64 url
  function svgToImageUrl(string memory svg)
    public
    pure
    returns (string memory)
  {
    string memory svgBase64Encoded = Base64.encode(
      bytes(string(abi.encodePacked(svg)))
    );
    return string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));
  }

  function _baseURI() internal pure override returns (string memory) {
    return "data:application/json;base64,";
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    if (!_exists(tokenId)) {
      revert ERC721Metadata__URI_QueryFor_NonExistentToken();
    }
    (, int256 price, , , ) = i_priceFeed.latestRoundData();
    string memory imageURI = s_lowImageURI;
    if (price >= s_tokenIdToHighValues[tokenId]) {
      imageURI = s_highImageURI;
    }
    // string memory imageURI = "Hi";
    return
      string(
        abi.encodePacked(
          _baseURI(),
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                name(), // You can add whatever name here
                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                imageURI,
                '"}'
              )
            )
          )
        )
      );
  }
}
