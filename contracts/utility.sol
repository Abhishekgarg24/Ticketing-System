// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;




import "./Erc721.sol";

contract utility{

    uint public EventId;
   struct Event{
       string  Event_Name;
       uint TotalSupply_of_Tickets;
       uint  Number_of_VIP;
       uint ordinary_tickets;
       address owner;
       Erc721 nft_smartContract_Address;
       uint saleTime;
       Whitelist whiteListers;
       uint VipSalePrice;
       uint ordinarySalePrice;
       TicketsOriganizer[] orgnizeTickets;      
   }

   struct TicketsOriganizer{
       address buyerOfTicket;
       string TypeOfTicket;
       uint Amount_Paid;
       uint NftGenrated;


   }

   

   struct Whitelist{
       address[] whiteListedAddresses;
       uint whiteListedPreSalePrice;
       uint whiteListedSalePrice;

   }

 mapping (uint => Event) public EventManagement;


   function CreateEvent(string memory _Event_Name,uint TotalSupply, uint VipTickets,uint TimePreSale,uint _whiteListedSalePrice, uint _VipSalePrice, address[] memory _whiteListers,uint _whiteListedPreSalePrice,uint _ordinarySalePrice) public returns(string memory){
       Erc721 nft = new Erc721();
       EventId+=1;
           EventManagement[EventId].Event_Name = _Event_Name;
           EventManagement[EventId].TotalSupply_of_Tickets = TotalSupply;
           EventManagement[EventId].Number_of_VIP =VipTickets;
           EventManagement[EventId].ordinary_tickets =TotalSupply -  VipTickets;
           EventManagement[EventId].owner=msg.sender;
           EventManagement[EventId].nft_smartContract_Address= Erc721(nft);
        
            EventManagement[EventId].whiteListers = Whitelist(_whiteListers,_whiteListedPreSalePrice,_whiteListedSalePrice);
           EventManagement[EventId].saleTime=block.timestamp + TimePreSale;
        //    EventManagement[EventId].VipPreSalePrice= _VipPreSalePrice;
           EventManagement[EventId].VipSalePrice= _VipSalePrice;
        //    EventManagement[EventId].OrdinaryPreSalePrice = _OrdinaryPreSalePrice;
           EventManagement[EventId].ordinarySalePrice = _ordinarySalePrice; 
       return "done";
    }

    // function makeWhiteListers(uint id, address[] Adressses , uint presale,uint sale) internal {


    // }


    function Whitelisting (address _whitelister,uint Id) internal view returns(bool ItsVip)
    {   
        for(uint i=0 ; i<EventManagement[Id].whiteListers.whiteListedAddresses.length; i++){
            if(_whitelister == EventManagement[Id].whiteListers.whiteListedAddresses[i]){
                ItsVip = true;
            }
        }
        return ItsVip;

    }
   
   function BuyTicket(uint Id ,uint price) public payable returns(string memory genrated){
       require(EventManagement[Id].owner != msg.sender ,"owner can't buy ticket");
         require(price == msg.value, "price and payment should be same" );
       if(block.timestamp < EventManagement[Id].saleTime && Whitelisting(msg.sender,Id) ){
           require(msg.value ==EventManagement[Id].whiteListers.whiteListedPreSalePrice ,"please put money according to presale");
           //    payable(address(this)).transfer(EventManagement[Id].VipPreSalePrice);
            uint nftID = (EventManagement[Id].nft_smartContract_Address).publicMint(msg.sender);
            EventManagement[Id].Number_of_VIP-=1;
            EventManagement[Id].orgnizeTickets.push(TicketsOriganizer(msg.sender,"vipPreSale",EventManagement[Id].whiteListers.whiteListedPreSalePrice,nftID));
            return "genrated a vip ticket in presale";
        }
        else if(block.timestamp >= EventManagement[Id].saleTime && Whitelisting(msg.sender,Id) ){
            require(msg.value ==EventManagement[Id].whiteListers.whiteListedSalePrice ,"please put money according to normal sale");
           //    payable(address(this)).transfer(EventManagement[Id].VipPreSalePrice);
            uint nftID = (EventManagement[Id].nft_smartContract_Address).publicMint(msg.sender);
            EventManagement[Id].Number_of_VIP-=1;
            EventManagement[Id].orgnizeTickets.push(TicketsOriganizer(msg.sender,"vipSale",EventManagement[Id].whiteListers.whiteListedPreSalePrice,nftID));
            return "genrated a vip ticket in sale";
        }
       else if(msg.value ==EventManagement[Id].VipSalePrice ){
            //    payable(address(this)).transfer(EventManagement[Id].VipSalePrice);
                uint nftID = (EventManagement[Id].nft_smartContract_Address).publicMint(msg.sender);
                EventManagement[Id].Number_of_VIP-=1;
                EventManagement[Id].orgnizeTickets.push(TicketsOriganizer(msg.sender,"vip Sale",EventManagement[Id].VipSalePrice,nftID));
                return("genrated a vip ticket in public sale");

           }
        else  if (msg.value ==EventManagement[Id].ordinarySalePrice ){
            //    payable(address(this)).transfer(EventManagement[Id].ordinarySalePrice);
                uint nftID = (EventManagement[Id].nft_smartContract_Address).publicMint(msg.sender);
                EventManagement[Id].ordinary_tickets -=1;
                EventManagement[Id].orgnizeTickets.push(TicketsOriganizer(msg.sender,"ordinary sale",EventManagement[Id].ordinarySalePrice,nftID));
                return("genrated a ordinary ticket in public sale");
       }


       else{
           revert("not an aligible condition satisfied for buying ticket");
       }
   }

//    function getEventDetail(uint Id) public view returns(Event memory){
//     return EventManagement[Id];
//    }

   function Withdraw(uint Id) public payable returns(string memory){
       require(msg.sender == EventManagement[Id].owner,"only owner can withdraw amount");
       uint total_amount;
       for(uint i = 0 ; i < EventManagement[Id].orgnizeTickets.length ; i++ ){
            total_amount += EventManagement[Id].orgnizeTickets[i].Amount_Paid;
       }

       require(address(this).balance >= total_amount,"not sufficient balance in contract");
       payable(EventManagement[Id].owner).transfer(total_amount);

       return ("owner successfully withdrawn the amount");
       
   }



   function refund(uint Id) public payable returns(string memory){
        require(msg.sender == EventManagement[Id].owner,"only owner can refund amount");
        for(uint i = 0 ; i < EventManagement[Id].orgnizeTickets.length ; i++ ){
            payable(EventManagement[Id].orgnizeTickets[i].buyerOfTicket).transfer(EventManagement[Id].orgnizeTickets[i].Amount_Paid);
            EventManagement[Id].nft_smartContract_Address.burnNft(EventManagement[Id].orgnizeTickets[i].NftGenrated);
            }
        delete EventManagement[Id];

        return ("event cancelled so rufunded amount");
   }



}