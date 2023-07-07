// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// import "@openzeppelin/contracts@4.7.3/utils/cryptography/MerkleProof.sol";

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
            _setTokenURI(newItemId, "https://gateway.pinata.cloud/ipfs/QmeYJGC16JBj79B8PLCsHHJxhpsj8zQuzKKcq9VRq8eELa/1.json");
            
            
            return newItemId;
    }
     function burnNft(uint Id) public {
        _burn(Id); 
    }
    // function safeMint(address to,bytes32[] memory proof) public {
    //     _tokenIds.increment();
    //     uint newItemId = _tokenIds.current();
       
    //     _safeMint(to, newItemId);
    // }

    // function isValidWhitelistAddress(bytes32 leaf, bytes32[] memory proof) public view returns (bool) {
    //     return MerkleProof.verify(proof,root,leaf);
    // }

 
}




// pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts@4.7.3/utils/cryptography/MerkleProof.sol";


// contract Erc721 is ERC721, Ownable {
//     using Counters for Counters.Counter;

//     Counters.Counter private _tokenIdCounter;
//     // bytes32 public root;bytes32 _root
//     // mapping(address => bool) public whitelistClaimed;

//     constructor() ERC721("MyToken", "MTK") {
       
//     }



//     function publicMint(address recipient ) public payable returns(uint){
//         _tokenIdCounter.increment();
//         uint256 tokenId = _tokenIdCounter.current();
//         _mint(recipient, tokenId);
//         return tokenId;
//     }
    
//     function burnNft(uint Id) public {
//         _burn(Id); 
//     }

//     // function safeMint(address to, uint256 tokenId, bytes32[] memory proof) public {
//     //     require(!whitelistClaimed[msg.sender],"Whitelist spot already claimed byt his address");
//     //     require(isValidWhitelistAddress(keccak256(abi.encodePacked(msg.sender)),proof),"Not a valid whitelist address");
//     //     whitelistClaimed[msg.sender] = true;
//     //     _safeMint(to, tokenId);
//     // }

//     // function isValidWhitelistAddress(bytes32 leaf, bytes32[] memory proof) public view returns (bool) {
//     //     return MerkleProof.verify(proof,root,leaf);
//     // }


// }