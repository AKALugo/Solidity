// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Necesitamos que el identificador de cada nft sea unico.
import "@openzeppelin/contracts/utils/Counters.sol";
// Asociar imagen, archivo, dato al nft.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// Estandar para el nft
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ExampleNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Example721", "ENFT") {}

    function createToken(string memory tokenURI) public payable returns (uint) {
        require(msg.value >= 1000000000000000000, "The minimum amount is 1 ETH");
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}