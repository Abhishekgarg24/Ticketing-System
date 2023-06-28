// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Erc721 is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;


    Counters.Counter private _tokenIds;

    constructor() ERC721("utility", "utl") {}
    string baseURI = "https://gateway.pinata.cloud/ipfs/QmeYJGC16JBj79B8PLCsHHJxhpsj8zQuzKKcq9VRq8eELa/";


    function publicMint(address recipient) public  returns(uint nftId)
    {
            _tokenIds.increment();
            uint newItemId = _tokenIds.current();
            _mint(recipient, newItemId);
            _setTokenURI(newItemId, string(abi.encodePacked(baseURI,Strings.toString(newItemId),".json")));
            
            
            return newItemId;
    }
     function burnNft(uint Id) public {
        _burn(Id); 
    }
 
}