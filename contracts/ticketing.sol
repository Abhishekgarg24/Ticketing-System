// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

// Importing the console library from Hardhat for debugging
import "hardhat/console.sol";
// Importing the ERC721 interface
import "./Erc721.sol";

contract TicketingSystem {
    uint256 public EventId;
    // Struct representing an event
    struct Event {
        string Event_Name;
        ticketType[] typesOfTickets;
        address owner;
        Erc721 nft_smartContract_Address;
        uint256 EventTime;
        uint256 NumberOfTypesOfTickets;
        TicketsOriganizer[] orgnizeTickets;
        uint256 totalsupply;
    }
    // Struct representing a ticket organizer
    struct TicketsOriganizer {
        address buyerOfTicket;
        string TypeOfTicket;
        uint256 Amount_Paid;
        uint256 NftGenrated;
    }

    // Event emitted when an event is created
    event EVENT(
        uint256 eventID,
        string EventName,
        uint256 eventTime,
        Erc721 nftAddress,
        address owner,
        uint256 totalSupply
    );
    // Event emitted when a ticket is bought
    event TICKET(
        uint256 eventId,
        string EventName,
        uint256 TicketId,
        string ticketType,
        address ticketOwner,
        Erc721 nftAddress
    );
    // Struct representing a type of ticket
    struct ticketType {
        string TypeOfTicket;
        uint256 priceOfType;
        uint256 supply;
    }
    // Mapping to store events
    mapping(uint256 => Event) public EventManagement;

    // Function to create an event
    function CreateEvent(
        string memory _Event_Name,
        uint256 _eventTime,
        uint256 _NumberOfTypesOfTickets,
        string[] memory TYPEsOfTickets,
        uint256[] memory pricesOfTickets,
        uint256[] memory SupplyOftickets
    ) public returns (string memory) {
        Erc721 nft = new Erc721();
        uint256 _totalSupply;
        EventId += 1;
        EventManagement[EventId].Event_Name = _Event_Name;
        EventManagement[EventId].owner = msg.sender;
        EventManagement[EventId]
            .NumberOfTypesOfTickets = _NumberOfTypesOfTickets;
        EventManagement[EventId].EventTime = block.timestamp + _eventTime;
        EventManagement[EventId].nft_smartContract_Address = Erc721(nft);
        require(
            TYPEsOfTickets.length ==
                EventManagement[EventId].NumberOfTypesOfTickets &&
                pricesOfTickets.length ==
                EventManagement[EventId].NumberOfTypesOfTickets,
            "exceeded the limit of Number Of Types Of Tickets "
        );
        for (uint256 i = 0; i < _NumberOfTypesOfTickets; i++) {
            EventManagement[EventId].typesOfTickets.push(
                ticketType(
                    TYPEsOfTickets[i],
                    pricesOfTickets[i],
                    SupplyOftickets[i]
                )
            );
            _totalSupply += SupplyOftickets[i];
        }
        EventManagement[EventId].totalsupply = _totalSupply;
        emit EVENT(
            EventId,
            EventManagement[EventId].Event_Name,
            EventManagement[EventId].EventTime,
            EventManagement[EventId].nft_smartContract_Address,
            EventManagement[EventId].owner,
            EventManagement[EventId].totalsupply
        );
        return "done";
    }

    // function CreateTicketType(uint id , string memory TicketType,uint _price) public returns(string memory){
    //     require(EventManagement[id].owner == msg.sender,"only owner can make types of tickets");
    //     require(EventManagement[id].typesOfTickets.length<EventManagement[id].NumberOfTypesOfTickets,"exceeded the limit of Number Of Types Of Tickets ");
    //     EventManagement[id].typesOfTickets.push(ticketType(TicketType,_price));
    //     return "new type of ticket is created";
    // }

    // Function to get details of an event
    function EventDetails(uint256 id) public view returns (Event memory) {
        return EventManagement[id];
    }

    // Function to buy a ticket
    function BuyTicket(
        uint256 id,
        string memory _TypeOfTickets,
        uint256 amountOfTickets
    ) public payable returns (string memory message) {
        require(
            EventManagement[id].owner != msg.sender,
            "owner can't buy ticket"
        );
        require(
            EventManagement[id].EventTime > block.timestamp,
            "event is over"
        );
        for (
            uint256 i = 0;
            i < EventManagement[id].typesOfTickets.length;
            i++
        ) {
            if (
                keccak256(
                    abi.encodePacked(
                        EventManagement[id].typesOfTickets[i].TypeOfTicket
                    )
                ) == keccak256(abi.encodePacked(_TypeOfTickets))
            ) {
                require(
                    msg.value ==
                        (EventManagement[id].typesOfTickets[i].priceOfType *
                            amountOfTickets),
                    "not enough funds"
                );
                for (uint256 j = 0; j < amountOfTickets; j++) {
                    uint256 nftID = (
                        EventManagement[id].nft_smartContract_Address
                    ).publicMint(msg.sender);
                    EventManagement[id].typesOfTickets[i].supply -= 1;
                    EventManagement[id].orgnizeTickets.push(
                        TicketsOriganizer(
                            msg.sender,
                            _TypeOfTickets,
                            EventManagement[id].typesOfTickets[i].priceOfType,
                            nftID
                        )
                    );
                    emit TICKET(
                        id,
                        EventManagement[id].Event_Name,
                        nftID,
                        _TypeOfTickets,
                        msg.sender,
                        EventManagement[id].nft_smartContract_Address
                    );
                }
                return ("ticket sold");
            }
        }
        revert("Invalid ticket type");
    }

    // Function to get the fund details for a ticket type
    function getFundDetail(
        uint256 id,
        string memory _TypeOfTickets,
        uint256 amountOfTickets
    ) public view returns (uint256 amount) {
        for (
            uint256 i = 0;
            i < EventManagement[id].typesOfTickets.length;
            i++
        ) {
            if (
                keccak256(
                    abi.encodePacked(
                        EventManagement[id].typesOfTickets[i].TypeOfTicket
                    )
                ) == keccak256(abi.encodePacked(_TypeOfTickets))
            ) {
                uint256 val = EventManagement[id]
                    .typesOfTickets[i]
                    .priceOfType * amountOfTickets;
                return (val);
            }
        }
    }

    // Function to withdraw the funds
    function Withdraw(uint256 Id) public payable returns (string memory) {
        require(
            msg.sender == EventManagement[Id].owner,
            "only owner can withadraw amount"
        );
        require(
            EventManagement[Id].EventTime < block.timestamp,
            "Can't withdraw till event is ever"
        );
        uint256 total_amount;
        for (
            uint256 i = 0;
            i < EventManagement[Id].orgnizeTickets.length;
            i++
        ) {
            total_amount += EventManagement[Id].orgnizeTickets[i].Amount_Paid;
        }
        require(
            address(this).balance >= total_amount,
            "not sufficient balance in contract"
        );
        payable(EventManagement[Id].owner).transfer(total_amount);
        delete EventManagement[Id];
        return ("owner successfully withdrawn the amount");
    }

    // Function to refund the funds and burn the NFTs
    function refund(uint256 Id) public payable returns (string memory) {
        require(
            EventManagement[Id].EventTime > block.timestamp,
            "Can't refund when event is over"
        );
        require(
            msg.sender == EventManagement[Id].owner,
            "only owner can refund amount"
        );
        uint256 total_amount;
        for (
            uint256 i = 0;
            i < EventManagement[Id].orgnizeTickets.length;
            i++
        ) {
            total_amount += EventManagement[Id].orgnizeTickets[i].Amount_Paid;
        }
        require(
            address(this).balance >= total_amount,
            "not sufficient balance in contract"
        );
        for (
            uint256 i = 0;
            i < EventManagement[Id].orgnizeTickets.length;
            i++
        ) {
            payable(EventManagement[Id].orgnizeTickets[i].buyerOfTicket)
                .transfer(EventManagement[Id].orgnizeTickets[i].Amount_Paid);
            EventManagement[Id].nft_smartContract_Address.burnNft(
                EventManagement[Id].orgnizeTickets[i].NftGenrated
            );
        }
        delete EventManagement[Id];

        return ("event cancelled so rufunded amount");
    }
}
//0x167c0466E6A8a397114e3d5036891BF64f6576F2        bnb test net
