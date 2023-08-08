# Docker bitcoin regtest node

## How to start a node?

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

3. Create a wallet

```
bitcoin-cli -rpcport=18443 -rpcuser=user -rpcpassword=pass createwallet "mywallet"
```

4. Create new address and save it to variable:

```
MY_ADDRESS=$(bitcoin-cli -rpcport=18443 -rpcuser=user -rpcpassword=pass -rpcwallet=mywallet getnewaddress)
```

Let's check it:

```
echo $MY_ADDRESS
```

5. Mine 50 BTC to your address:

```
bitcoin-cli -rpcport=18443 -rpcuser=user -rpcpassword=pass -rpcwallet=mywallet generatetoaddress 101 $MY_ADDRESS
```

6. Check the balance:

```
bitcoin-cli -rpcport=18443 -rpcuser=user -rpcpassword=pass -rpcwallet=mywallet getbalance
```
