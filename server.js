const express = require('express');
const app = express();
require('dotenv').config();
const Web3 = require('web3');

const rpcUrl = process.env.API_URL;
const web3 = new Web3(rpcUrl);
const path = require('path');

app.use(express.json());
const privateKeys = JSON.parse(process.env.PRIVATE_KEY);
console.log(privateKeys);
  console.log(privateKeys[1])
  const accounts = privateKeys.map(privateKey => web3.eth.accounts.privateKeyToAccount(privateKey));
  // console.log(accounts)
  web3.eth.accounts.wallet.add(...accounts);

  web3.eth.defaultAccount = accounts[0].address;

const contractABI = require('./abi.json');
const contractAddress = process.env.CONTRACT_ADDRESS;
var contract ;



contract = new web3.eth.Contract(contractABI, contractAddress);
//  console.log(contract)

const creat_event = async (_Event_Name, _EventTime,_NumberOfTypesOfTickets, TYPEsOfTickets, pricesOfTickets, SupplyOftickets) => {
  
 //three lines are for frontend.html
  // const arrayOfprices= JSON.parse(pricesOfTickets);
  // const arrayOfcountTicket = JSON.parse(SupplyOftickets);
  // await contract.methods.CreateEvent(_Event_Name,_EventTime, _NumberOfTypesOfTickets, TYPEsOfTickets, arrayOfprices, arrayOfcountTicket).send({from: web3.eth.defaultAccount, gas:"10000000"});

  //this line is for hiting api from postman 
	await contract.methods.CreateEvent(_Event_Name,_EventTime, _NumberOfTypesOfTickets, TYPEsOfTickets, pricesOfTickets, SupplyOftickets).send({from: web3.eth.defaultAccount, gas:"10000000"});
}

const buy_Ticket = async (id,
  TypeOfTickets,
  amountOfTickets) => {
  const checksummedAddress3 = web3.utils.toChecksumAddress(accounts[3].address);
  const checksummedAddress1 = web3.utils.toChecksumAddress(accounts[1].address);
  
  const checksummedAddress2 = web3.utils.toChecksumAddress(accounts[2].address);
  const val = await contract.methods.getFundDetail(id, 
    TypeOfTickets,
    amountOfTickets).call();
    console.log(val);
  const data = contract.methods.BuyTicket(id,
    TypeOfTickets,
    amountOfTickets).encodeABI();

  const txObject = {
    // from: checksummedAddress3,
    // from: checksummedAddress3,
    from: checksummedAddress1,
    to: contract.options.address,
    value: val,
    gas: "10000000",
    data: data,
  };

  const signedTx = await web3.eth.accounts.signTransaction(txObject,privateKeys[1] );
  const rawTx = signedTx.rawTransaction;

  await web3.eth.sendSignedTransaction(rawTx);
}


const refund = async (id) => {
  await contract.methods.refund(id).send({from: web3.eth.defaultAccount, gas:"10000000"});
}

const withdraw = async (id) => {
  await contract.methods.Withdraw(id).send({from: web3.eth.defaultAccount, gas:"10000000"});
}

const getEventDetail = async (id) => {
 return await contract.methods.EventDetails(id).call();

}






app.post('/buy_Ticket', async (req, res) => {
  try {
    const id = req.body.id;
    const TypeOfTickets = req.body.TypeOfTickets;
    const amountOfTickets = req.body.amountOfTickets;
    
    await buy_Ticket(id,
      TypeOfTickets,
      amountOfTickets);

    res.json({ message: 'buying ticket is done successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(400).json({ error: 'An error occurred' });
  }
});

app.post('/create-event', async (req, res) => {
  try {
    console.log(req.body);
    const _Event_Name = req.body.Event_Name;
    const _EventTime = req.body.EventTime;
    const _NumberOfTypesOfTickets = req.body.NumberOfTypesOfTickets;
    const TYPEsOfTickets = req.body.TYPEsOfTickets;
    const pricesOfTickets = req.body.pricesOfTickets;
    const SupplyOftickets = req.body.SupplyOftickets;

    await creat_event(_Event_Name,_EventTime, _NumberOfTypesOfTickets, TYPEsOfTickets, pricesOfTickets, SupplyOftickets);

    res.json({ message: 'Event created successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(400).json({ error: 'An error occurred' });
  }
});
app.post('/Refund', async (req, res) => {
  try {
    const id = req.body.id;
      
    await refund(id);

    res.json({ message: 'rufund is successfully done' });
  } catch (error) {
    console.error('Error:', error);
    res.status(400).json({ error: 'An error occurred' });
  }
});
app.post('/withdraw', async (req, res) => {
  try {
    const id = req.body.id;
    
    
    await withdraw(id);

    res.json({ message: 'withdraw is successfully done' });
  } catch (error) {
    console.error('Error:', error);
    res.status(400).json({ error: 'An error occurred' });
  }
});
app.get('/eventDetail/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const detail = await getEventDetail(id);
    res.json(detail);
  } catch (error) {
    console.error(error);
    res.status(400).json({ error: 'Internal server error' });
  }
});
app.get("/",(req,res)=>{
  res.sendFile(path.join(__dirname,'/frontend.html'));
})



app.listen(3000, () => {
  console.log('Server started on port 3000');
});


