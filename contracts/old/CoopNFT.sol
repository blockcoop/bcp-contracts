// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import { Base64 } from "../libraries/Base64.sol";

contract CoopNFT_Old is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address factoryAddress;
    address public coopInitiator;
    uint32 public votingPeriod;
    uint32 public quorum; // 1-100
    uint32 public supermajority;
    uint8 public status; // 1:PENDING, 2:ACTIVE, 3:CLOSED
    uint32 public created;
    uint public membershipFee;
    string public country;

    string internal constant svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base {font-family:Sans,Arial; font-weight: bold; }</style><rect x='5' y='5' rx='20' ry='20' width='340' height='340' style='fill:#FFFFFF;stroke:#EB3933;stroke-width:5;stroke-opacity:0.9' /><text x='50%' y='40' class='base' text-anchor='middle' fill='#8F8F8F' style='font-size: 11px;'>COOP NAME</text><text x='50%' y='70' class='base' fill='#000000' text-anchor='middle'>";
    string internal constant svgPartTwo = "</text><circle cx='50%' cy='190' r='80' stroke='#979797' stroke-width='1' fill='#D8D8D8' /><text x='50%' y='190' class='base' fill='#000000' dominant-baseline='middle' text-anchor='middle'>";

    event CoopJoined(address indexed member);

    constructor(string memory _name, string memory _symbol, address _coopInitiator, uint32 _votingPeriod, uint32 _quorum, uint32 _supermajority, uint _membershipFee, string memory _country) ERC721 (_name, _symbol) {
        factoryAddress = msg.sender;
        coopInitiator = _coopInitiator;
        votingPeriod = _votingPeriod;
        quorum = _quorum;
        supermajority = _supermajority;
        membershipFee = _membershipFee;
        country = _country;
        status = 2;

        MintNFT(_coopInitiator, "Creator");
    }

    function MintNFT(address member, string memory memberType) private {
        uint256 newItemId = _tokenIds.current();
        string memory _name = name();
        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo, memberType, "</text></svg>"));
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        _name,
                        ' membership", "description": "',
                        memberType,
                        ' Membership card for ',
                        _name,
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        _safeMint(member, newItemId);
        _setTokenURI(newItemId, finalTokenUri);
        _tokenIds.increment();
    }

    function joinCoop() public payable {
        require(balanceOf(msg.sender) == 0, "already a member");
        require(msg.value == membershipFee, "invalid membership fee");
        MintNFT(msg.sender, "Member");
        emit CoopJoined(msg.sender);
    }

    function tokenURI(uint256 tokenId) public override view returns (string memory) {
        string memory _name = name();
        string memory memberType = "";
        address owner = ownerOf(tokenId);
        if(owner == coopInitiator) {
            memberType = 'Creator';
        } else {
            memberType = 'Member';
        }
        string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, "(dynamically generated)", svgPartTwo, memberType, "</text></svg>"));
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        _name,
                        ' membership", "description": "',
                        memberType,
                        ' Membership card for ',
                        _name,
                        '", "Updated on":"',
                        "Just now.",
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return finalTokenUri;
    } 
}