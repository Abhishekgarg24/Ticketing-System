// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;


import "hardhat/console.sol";

import "./Erc721.sol";

contract TicketingSystem{

    uint public EventId;
   struct Event                        
   {
       string  Event_Name;              
        ticketType[] typesOfTickets;          
       address owner;
       Erc721 nft_smartContract_Address;        
       uint EventTime; 
       uint NumberOfTypesOfTickets;            
       TicketsOriganizer[] orgnizeTickets;     
       uint totalsupply;                       
   }

   struct TicketsOriganizer
   {
       address buyerOfTicket;
       string TypeOfTicket;
       uint Amount_Paid;
       uint NftGenrated;
       
   }


   event EVENT(uint eventID,string EventName,uint eventTime,Erc721 nftAddress,address owner,uint totalSupply);
   event TICKET(uint eventId,string EventName,uint TicketId,string ticketType,address ticketOwner,Erc721  nftAddress); 
   struct ticketType{
       string TypeOfTicket;
       uint priceOfType;
       uint supply;
   }

 mapping (uint => Event) public EventManagement;
 


   function CreateEvent(string memory _Event_Name, uint _eventTime, uint _NumberOfTypesOfTickets , string[] memory TYPEsOfTickets, uint[] memory pricesOfTickets,uint[] memory SupplyOftickets ) public returns(string memory)
   {
       Erc721 nft = new Erc721();
       uint _totalSupply;
       EventId+=1;
           EventManagement[EventId].Event_Name = _Event_Name;
           EventManagement[EventId].owner=msg.sender;
           EventManagement[EventId].NumberOfTypesOfTickets=_NumberOfTypesOfTickets;
           EventManagement[EventId].EventTime = block.timestamp +  _eventTime;
           EventManagement[EventId].nft_smartContract_Address= Erc721(nft);           
           require(TYPEsOfTickets.length==EventManagement[EventId].NumberOfTypesOfTickets &&  pricesOfTickets.length == EventManagement[EventId].NumberOfTypesOfTickets,"exceeded the limit of Number Of Types Of Tickets ");
           for(uint i = 0 ; i<_NumberOfTypesOfTickets ; i++){
               EventManagement[EventId].typesOfTickets.push(ticketType(TYPEsOfTickets[i],pricesOfTickets[i],SupplyOftickets[i]));
               _totalSupply += SupplyOftickets[i];
           }
           EventManagement[EventId].totalsupply = _totalSupply;
           emit EVENT(EventId,EventManagement[EventId].Event_Name,EventManagement[EventId].EventTime,EventManagement[EventId].nft_smartContract_Address,EventManagement[EventId].owner,EventManagement[EventId].totalsupply);
        return "done";
    }

    


    // function CreateTicketType(uint id , string memory TicketType,uint _price) public returns(string memory){
    //     require(EventManagement[id].owner == msg.sender,"only owner can make types of tickets");
    //     require(EventManagement[id].typesOfTickets.length<EventManagement[id].NumberOfTypesOfTickets,"exceeded the limit of Number Of Types Of Tickets ");
    //     EventManagement[id].typesOfTickets.push(ticketType(TicketType,_price));
    //     return "new type of ticket is created";
    // }


    function EventDetails(uint id) public view returns(Event memory){
        return EventManagement[id];
    }

    function BuyTicket(uint id , string memory _TypeOfTickets,  uint amountOfTickets)public payable returns(string memory message){
        require(EventManagement[id].owner != msg.sender ,"owner can't buy ticket");
        require(EventManagement[id].EventTime > block.timestamp,"event is over");
        for(uint i=0 ; i<EventManagement[id].typesOfTickets.length;i++){
            if(keccak256(abi.encodePacked(EventManagement[id].typesOfTickets[i].TypeOfTicket)) ==  keccak256(abi.encodePacked(_TypeOfTickets ))){
                require(msg.value == (EventManagement[id].typesOfTickets[i].priceOfType * amountOfTickets),"not enough funds");
                for(uint j=0 ; j<amountOfTickets;j++){
                    uint nftID = (EventManagement[id].nft_smartContract_Address).publicMint(msg.sender);
                    EventManagement[id].typesOfTickets[i].supply -= 1;
                    EventManagement[id].orgnizeTickets.push(TicketsOriganizer(msg.sender,_TypeOfTickets,EventManagement[id].typesOfTickets[i].priceOfType,nftID));
                 emit TICKET(id,EventManagement[id].Event_Name,nftID,_TypeOfTickets,msg.sender,EventManagement[id].nft_smartContract_Address); 
   
                }
            return("ticket sold");
            }
        }
        revert("Invalid ticket type");
        
    }

    function getFundDetail(uint id , string memory _TypeOfTickets,  uint amountOfTickets)view public returns(uint amount  ){
        for(uint i=0 ; i<EventManagement[id].typesOfTickets.length;i++){
            if(keccak256(abi.encodePacked(EventManagement[id].typesOfTickets[i].TypeOfTicket)) ==  keccak256(abi.encodePacked(_TypeOfTickets ))){
                uint val = EventManagement[id].typesOfTickets[i].priceOfType * amountOfTickets;
                return (val);
            }
        }revert("Invalid ticket type");
    }



   function Withdraw(uint Id) public payable returns(string memory){
       require(msg.sender == EventManagement[Id].owner,"only owner can withadraw amount");
       require(EventManagement[Id].EventTime < block.timestamp,"Can't withdraw till event is ever");
       uint total_amount;
       for(uint i = 0 ; i < EventManagement[Id].orgnizeTickets.length ; i++ ){
            total_amount += EventManagement[Id].orgnizeTickets[i].Amount_Paid;
       }
       require(address(this).balance >= total_amount,"not sufficient balance in contract");
       payable(EventManagement[Id].owner).transfer(total_amount);
       delete EventManagement[Id]; 
       return ("owner successfully withdrawn the amount");
       
    }



   function refund(uint Id) public payable returns(string memory){
        
        require(EventManagement[Id].EventTime > block.timestamp,"Can't refund when event is over");
        require(msg.sender == EventManagement[Id].owner,"only owner can refund amount");
        uint total_amount;
       for(uint i = 0 ; i < EventManagement[Id].orgnizeTickets.length ; i++ ){
            total_amount += EventManagement[Id].orgnizeTickets[i].Amount_Paid;
       }
       require(address(this).balance >= total_amount,"not sufficient balance in contract");
        for(uint i = 0 ; i < EventManagement[Id].orgnizeTickets.length ; i++ ){
            payable(EventManagement[Id].orgnizeTickets[i].buyerOfTicket).transfer(EventManagement[Id].orgnizeTickets[i].Amount_Paid);
            EventManagement[Id].nft_smartContract_Address.burnNft(EventManagement[Id].orgnizeTickets[i].NftGenrated);
            }
        delete EventManagement[Id];

        return ("event cancelled so rufunded amount");
   }
}
//0x167c0466E6A8a397114e3d5036891BF64f6576F2        bnb test net