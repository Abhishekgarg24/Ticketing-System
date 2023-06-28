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
  let wh1;
  let wh2;

 
  beforeEach(async () => {
    TokenErc721 = await ethers.getContractFactory("Erc721");

    tokenErc721 = await TokenErc721.deploy();


    Main = await ethers.getContractFactory("utility");


    main = await Main.deploy();
    [owner,buyer,wh1,wh2] =  await ethers.getSigners();

    

  });

  it("event id should increase after calling create event function ",async function () {
    var itemId = main.EventId();
    main.CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    var itemIdAfter = main.EventId();
    expect (itemId).not.to.equal(itemIdAfter);
    
  });
  it("owner shouldnot be calling buy ticket function", async function(){
    
    await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,["0x985e860DD7CAa49A473Fc900d7f26DB53b2E60C2","0xA162E70e26af2950a8Fb774a90eC95c317031842"],10,1000);

    await expect(main.connect(owner).BuyTicket(1,100,{ value: 100 })).to.be.revertedWith("owner can't buy ticket");
  });

  it("after calling buy ticket function successfully .contract balance should be increased", async function(){
    const contractBalance = await ethers.provider.getBalance(main);
    // console.log(contractBalance)
    await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    
    await main.connect(wh1).BuyTicket(1,10,{ value: 10 });

    const contractBalanceAfter = await ethers.provider.getBalance(main);
    // console.log(contractBalanceAfter)
    expect (contractBalance).not.to.equal(contractBalanceAfter);
  });

  it("buying of ticket is not possible at presale price by whitelisters after presale time ends", async function(){
    
    await main.connect(owner).CreateEvent("f2",100,30,0,100,10000,[wh1,wh2],10,1000);
    
    await expect(main.connect(wh1).BuyTicket(1,10,{ value: 10 })).to.be.revertedWith("please put money according to normal sale");

    
  });

  it("buying of ticket is not possible at normal price by whitelisters when presale time is going", async function(){
    
    await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    
    await expect(main.connect(wh1).BuyTicket(1,100,{ value: 100 })).to.be.revertedWith("please put money according to presale");

    
  });

  it("while buying put msg.value and price same only then it will move further", async function(){
    
    await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    
    await expect(main.connect(wh1).BuyTicket(1,100,{ value: 10 })).to.be.revertedWith("price and payment should be same");

    
  });
  it("A non whitelister can't get ticket at less price", async function(){
    
    await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    
    await expect(main.connect(buyer).BuyTicket(1,100,{ value: 100})).to.be.revertedWith("not an aligible condition satisfied for buying ticket");

    
  });

  it("A non whitelister can't partcipate in presale", async function(){
    
    await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    
    await expect(main.connect(buyer).BuyTicket(1,10,{ value: 10})).to.be.revertedWith("not an aligible condition satisfied for buying ticket");

    
  });

  it("A white Lister can't buy at ordinary price", async function(){
    await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    
    await expect(main.connect(wh1).BuyTicket(1,10000,{ value: 10000})).to.be.revertedWith("please put money according to presale");

  })

  it("owner should be calling refund function", async function(){
    
    main.CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    main.connect(wh1).BuyTicket(1,10,{ value: 10})
    await expect( main.connect(wh1).refund(1)).to .be. revertedWith("only owner can refund amount")
  });

  it("owner should be calling withdraw function", async function(){
    main.CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
    main.connect(wh1).BuyTicket(1,10,{ value: 10});
   
    await expect( main.connect(wh1).Withdraw(1)).to .be. revertedWith("only owner can withdraw amount");
  });


  // it("if presale is going and payment done accordingly so vip ticket should be genrated", async function(){
  //   [owner,buyer,wh1,wh2] = await ethers.getSigners();
  //   await main.connect(owner).CreateEvent("f2",100,30,120,100,10000,[wh1,wh2],10,1000);
  //   const mapping = await main.EventManagement(1)
  //   const add = mapping.nft_smartContract_Address;
  //   tokenErc721.address = add; 
  //   console.log(tokenErc721.address ,add)
  //   const balance = await tokenErc721.balanceOf(wh1)
  //   await main.connect(wh1).BuyTicket(1, 10, { value: 10 })
    
    
  //  const balanceAfter = await tokenErc721.balanceOf(wh1)

  //  await expect(balance).not.to.equal(balanceAfter);
  // });


  





});