# Docker bitcoin regtest node

## How to start?

1. Run `docker compose up`
2. Go to terminal and check, if everything is alright. Execute:

```
bitcoin-cli -rpcport=18443 -rpcuser=user -rpcpassword=pass getblockchaininfo
```

You will get something similar to:

```
{
  "chain": "regtest",
  "blocks": 0,
  "headers": 0,
  "bestblockhash": "0f9188f13cb7b2c71f2a335e3a4fc328bf5beb436012afca590b1a11466e2206",
  "difficulty": 4.656542373906925e-10,
  "time": 1296688602,
  "mediantime": 1296688602,
  "verificationprogress": 1,
  "initialblockdownload": true,
  "chainwork": "0000000000000000000000000000000000000000000000000000000000000002",
  "size_on_disk": 293,
  "pruned": false,
  "warnings": ""
}
```

3. Execute the command to fill the node:

```
sh -c "/generate.sh"
```

## Create the transactions

First of all, let's save the recipient and our address:

```
RECIPIENT=bcrt1qf9mjehng00lpf4rf5v22sgjl83qlnua2lfrzqx
MY_ADDRESS=bcrt1qewtu98ghmvm8hz5pmn3g20r7mkrjlnnfz6flu3
```

Check, that recipient is correct:

```
echo $RECIPIENT
```

And let's create the alias:

```
alias bitcoin-cli="bitcoin-cli -regtest -rpcport=18443 -rpcuser=user -rpcpassword=pass"
```

### Automatic way

```
bitcoin-cli -rpcwallet=mywallet sendtoaddress $RECIPIENT 1.12
```

You will get `txid`, but your transaction still in the mempool:

```
bitcoin-cli -rpcwallet=mywallet getrawmempool
```

Generate new block and make sure the transaction is in block:

```
bitcoin-cli -rpcwallet=mywallet generatetoaddress 1 $MY_ADDRESS
```

### Semi-automatic way

Create empty raw transaction

```
UNFINISHED_TX=$(bitcoin-cli -rpcwallet=mywallet -named createrawtransaction inputs='''[]''' outputs='''{ "'$RECIPIENT'": 0.0002 }''')
```

Ask node to select UTXO, calculate fee and create the change address

```
RAW_TX_HEX=$(bitcoin-cli -rpcwallet=mywallet -named fundrawtransaction hexstring=$UNFINISHED_TX | jq -r '.hex')
```

Sign the transaction by wallet

```
SIGNED_TX=$(bitcoin-cli -rpcwallet=mywallet -named signrawtransactionwithwallet hexstring=$RAW_TX_HEX | jq -r '.hex')
```

Send the transaction

```
bitcoin-cli -rpcwallet=mywallet -named sendrawtransaction hexstring=$SIGNED_TX
```

Generate new block and make sure the transaction is in block:

```
bitcoin-cli -rpcwallet=mywallet generatetoaddress 1 $MY_ADDRESS
```

### Manual way

Get available UTXOs

```
bitcoin-cli -rpcwallet=mywallet listunspent 1 9999
```

Save UTXOs to variables with their `vout` values (specify your values):

```
UTXO_TX=4b37e18...20649bd72bb9f1ba6a3709dbb6c6e7
UTXO_OUT=0
```

Create empty raw transaction with selected UTXOs, change address (specify your amount)

```
UNFINISHED_TX=$(bitcoin-cli -rpcwallet=mywallet -named createrawtransaction inputs='''[{ "txid": "'$UTXO_TX'", "vout": '$UTXO_OUT' }]''' outputs='''{ "'$RECIPIENT'": 0.0002, "'$MY_ADDRESS'": 48.87970151 }''')
```

Sign the transaction by wallet

```
SIGNED_TX=$(bitcoin-cli -rpcwallet=mywallet -named signrawtransactionwithwallet hexstring=$UNFINISHED_TX | jq -r '.hex')
```

Let's decode and inspect the transaction

```
bitcoin-cli -rpcwallet=mywallet decoderawtransaction $SIGNED_TX
```

Send the transaction

```
bitcoin-cli -rpcwallet=mywallet -named sendrawtransaction hexstring=$SIGNED_TX
```

Generate new block and make sure the transaction is in block:

```
bitcoin-cli -rpcwallet=mywallet generatetoaddress 1 $MY_ADDRESS
```
