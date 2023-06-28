const express = require('express');
const app = express();
const Web3 = require('web3');
const rpcUrl = "https://polygon-mumbai.g.alchemy.com/v2/fMUrbLjuZcVQFbEdAYkJ6CuRG7Qsfiz9";
const web3 = new Web3(rpcUrl);
app.use(express.json());
const privateKeys = ["562cdcc87e73682af22626a09946ad6f525e104143e73edc740ca98d1de2ac75",
    "5cf36f45127f5ae97efd3cdab095ca129e82f1ed190dea63c0af32fad83cfb27",
    "372f056a17fcf925cdbfeeb8ddf865fe505b194d6c950b7dd608a5db3e82eca9",
    "d87e4be1391d6c891ed20886f3b5b18adf8b4fe67a5924b8b77698f3d7abd5c8",
    "0b77112450b56c2eb2be95d624ed9bc205178b817ebba4afcbce3193da5fa51e",
    "8c10a65acc45adc14f77612a351964c38fdd85da185de229b36d6410f96f2f29"];

  
  const accounts = privateKeys.map(privateKey => web3.eth.accounts.privateKeyToAccount(privateKey));
  // console.log(accounts)
  web3.eth.accounts.wallet.add(...accounts);

  web3.eth.defaultAccount = accounts[0].address;

const contractABI = require('./abi.json');
const contractAddress = '0x4F3abD347e31710Cc06668c9A2018201E319b6b0';
var contract ;



contract = new web3.eth.Contract(contractABI, contractAddress);
//  console.log(contract)

const creat_event = async (_Event_Name, _NumberOfTypesOfTickets, TYPEsOfTickets, pricesOfTickets, SupplyOftickets) => {
	await contract.methods.CreateEvent(_Event_Name, _NumberOfTypesOfTickets, TYPEsOfTickets, pricesOfTickets, SupplyOftickets).send({from: web3.eth.defaultAccount, gas:"10000000"});
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

  const signedTx = await web3.eth.accounts.signTransaction(txObject,"5cf36f45127f5ae97efd3cdab095ca129e82f1ed190dea63c0af32fad83cfb27" );
  const rawTx = signedTx.rawTransaction;

  await web3.eth.sendSignedTransaction(rawTx);
}


const refund = async (id) => {
  await contract.methods.refund(id).send({from: web3.eth.defaultAccount, gas:"10000000"});
}

const withdraw = async () => {
  await contract.methods.Withdraw(2).send({from: web3.eth.defaultAccount, gas:"10000000"});
}

const getEventDetail = async () => {
  const detail =  await contract.methods.EventDetails(1).call();
  console.log(detail);
}




getEventDetail();

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
    res.status(500).json({ error: 'An error occurred' });
  }
});

app.post('/create-event', async (req, res) => {
  try {
    const _Event_Name = req.body.Event_Name;
    const _NumberOfTypesOfTickets = req.body.NumberOfTypesOfTickets;
    const TYPEsOfTickets = req.body.TYPEsOfTickets;
    const pricesOfTickets = req.body.pricesOfTickets;
    const SupplyOftickets = req.body.SupplyOftickets;

    await creat_event(_Event_Name, _NumberOfTypesOfTickets, TYPEsOfTickets, pricesOfTickets, SupplyOftickets);

    res.json({ message: 'Event created successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'An error occurred' });
  }
});
app.post('/Refund', async (req, res) => {
  try {
    const id = req.body.id;
      
    await refund(id);

    res.json({ message: 'rufund is successfully done' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'An error occurred' });
  }
});
app.post('/withdraw', async (req, res) => {
  try {
    const id = req.body.id;
    
    
    await withdraw(id);

    res.json({ message: 'withdraw is successfully done' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'An error occurred' });
  }
});


app.listen(3000, () => {
  console.log('Server started on port 3000');
});


