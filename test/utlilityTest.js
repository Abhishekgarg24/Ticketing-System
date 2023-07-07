const Web3 = require('web3');
const web3 = new Web3();
const { ethers } = require("hardhat");



const { expect } = require("chai");
const fs = require("fs");
describe("utility contract", () => {
  
  let TokenErc721;
  let tokenErc721;
  let Main;
  let main;
  let owner;
  let buyer;
  

 
  beforeEach(async () => {
    TokenErc721 = await ethers.getContractFactory("Erc721");

    tokenErc721 = await TokenErc721.deploy();


    Main = await ethers.getContractFactory("TicketingSystem");


    main = await Main.deploy();
    [owner,buyer] =  await ethers.getSigners();

    

  });

  it("event id should increase after calling create event function ",async function () {
    var itemId =await main.EventId();
    // console.log(itemId);
    await main.CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
    var itemIdAfter =await main.EventId();
    // console.log(itemIdAfter)
    expect (itemId).not.to.equal(itemIdAfter);
    
  });
  it("nft contract which genrate tickets should be differ with event", async function(){
    
    await main.CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
    const event = await main.EventDetails(1);
    const nft = await event.nft_smartContract_Address;
    // console.log(nft);
    await main.CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
    const event2 = await main.EventDetails(2);
    const nft2 = await event2.nft_smartContract_Address;
    // console.log(nft2);
    expect (nft).not.to.equal(nft2);
  });

  it("number of types of ticket should be equal to length of array of types ", async function(){
    await expect(main.CreateEvent("f2",100,3,["vip","ord"],[1000,100],[10,20])).to.be.revertedWith("exceeded the limit of Number Of Types Of Tickets ");
});

it("total supply of ticket should be eaqual to sum of elements inputed into suply of each type",async function(){
  var sum= 20+30;
  // console.log(sum);
  await main.CreateEvent("f2",100,2,["vip","ord"],[1000,100],[20,30]);
  const event = await main.EventDetails(1);
    const totalsupply = await event.totalsupply;
    // console.log(Number(totalsupply));
    expect (totalsupply).to.equal(sum);
});


it("Event which is named as EVENT should be emitted when calling CreateEvent function" , async function(){
  await expect(main.CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20])).to.emit(main, 'EVENT')
});


it("buying of ticket can be procedded by any one but not owner", async function(){
  await main.connect(owner).CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
  await expect( main.connect(owner).BuyTicket(1,"vip",2)).to.be.revertedWith("owner can't buy ticket");
});

it("buying of ticket can be procedded only time is not over", async function(){
  await main.connect(owner).CreateEvent("f2",1,2,["vip","ord"],[1000,100],[10,20]);
  await(2000);
  await expect( main.connect(buyer).BuyTicket(1,"vip",2)).to.be.revertedWith("event is over");
});

it("Ticket Type Should present in event for which we are buying", async function(){
  await main.connect(owner).CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
  await expect( main.connect(buyer).BuyTicket(1,"vvip",2)).to.be.revertedWith("Invalid ticket type");
});

it("payment should be done according to type of ticket and count  both" , async function(){
  await main.connect(owner).CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
  // const calculatedPayment = 1000*2;
  // console.log(calculatedPayment);
  const payment =  await main.getFundDetail(1,"vip",2);
  // console.log(payment);
  await expect(main.connect(buyer).BuyTicket(1,"vip",2,{
    value : 50
  })).to.be.revertedWith("not enough funds");
});

it("Event which is named as TICKET should be emitted when calling BuyTicket function" , async function(){
  await main.connect(owner).CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
  const payment =  await main.getFundDetail(1,"vip",2);
  await expect(main.connect(buyer).BuyTicket(1,"vip",2,{
    value : payment
  })).to.emit(main, 'TICKET')
});


it("getFundDetail function give exact information about payment in buyTicket", async function(){
  await main.connect(owner).CreateEvent("f2",100,2,["vip","ord"],[1000,100],[10,20]);
  const payment =  Number(await main.getFundDetail(1,"vip",2));
  await expect(main.connect(buyer).BuyTicket(1,"vip",2,{
    value : payment+50
  })).to.be.revertedWith("not enough funds");
});

it("withdraw function should be called by only owner", async function(){
  await main.connect(owner).CreateEvent("f2",5,2,["vip","ord"],[1000,100],[10,20]);
  const payment =  await main.getFundDetail(1,"vip",2);
  await main.connect(buyer).BuyTicket(1,"vip",2,{
    value : payment
  });
  await(5000);
  await expect(main.connect(buyer).Withdraw(1)).to.be.revertedWith("only owner can withadraw amount");
});

it("withdraw function should be called after event is over", async function(){
  await main.connect(owner).CreateEvent("f2",500,2,["vip","ord"],[1000,100],[10,20]);
  const payment =  await main.getFundDetail(1,"vip",2);
  await main.connect(buyer).BuyTicket(1,"vip",2,{
    value : payment
  });
  await expect(main.connect(owner).Withdraw(1)).to.be.revertedWith("Can't withdraw till event is ever");
});

it("refund function should be called by only owner", async function(){
  await main.connect(owner).CreateEvent("f2",500,2,["vip","ord"],[1000,100],[10,20]);
  const payment =  await main.getFundDetail(1,"vip",2);
  await main.connect(buyer).BuyTicket(1,"vip",2,{
    value : payment
  });
  await expect(main.connect(buyer).refund(1)).to.be.revertedWith("only owner can refund amount");
});

it("refund function should be called till event time is over", async function(){
  await main.connect(owner).CreateEvent("f2",2,2,["vip","ord"],[1000,100],[10,20]);
  const payment =  await main.getFundDetail(1,"vip",2);
  await main.connect(buyer).BuyTicket(1,"vip",2,{
    value : payment
  });
  await(2000);
  await expect(main.connect(owner).refund(1)).to.be.revertedWith("Can't refund when event is over");
});
});