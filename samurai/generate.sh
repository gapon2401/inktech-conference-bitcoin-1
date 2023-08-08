#!/usr/bin/env sh

DIR_PATH="/home/bitcoin/.bitcoin/regtest"

# Check if the directory exists
if [ -d "$DIR_PATH" ]; then
    # Remove the directory and its contents
    rm -rf "$DIR_PATH"
    echo "Directory $DIR_PATH has been removed successfully."
else
    echo "Directory $DIR_PATH does not exist."
fi

bitcoind -regtest

bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass createwallet "side_wallet"
FIRST_ADDRESS=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet getnewaddress)
bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet generatetoaddress 101 "$FIRST_ADDRESS"

i=1
while [ $i -le 50 ]
do
  i=$((i + 1))
  RAND_FEE=$( awk -v min=0.0000014 -v max=0.001 'BEGIN{srand(); printf "%.5f\n", min+rand()*(max-min)}' )
  RAND_VALUE=$( awk -v min=0.001 -v max=0.1 'BEGIN{srand(); printf "%.5f\n", min+rand()*(max-min)}' )
  NEW_ADDRESS=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet getnewaddress)
  RAW_TX=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet createrawtransaction "[]" "[{\"$NEW_ADDRESS\":$RAND_VALUE}]")
  FUNDED_TX=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet fundrawtransaction "$RAW_TX" "{\"feeRate\": \"$RAND_FEE\"}" | awk -F'"' '/hex/{print $4}')
  SIGNED_TX=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet signrawtransactionwithwallet "$FUNDED_TX" | awk -F'"' '/hex/{print $4}')
  bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet sendrawtransaction "$SIGNED_TX"

  if [ $((i % 10)) -eq 0 ]
  then
      bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet generatetoaddress 1 "$FIRST_ADDRESS"
  fi
done

bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass createwallet "mywallet"
MY_ADDRESS=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=mywallet getnewaddress)
MY_ADDRESS2=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=mywallet getnewaddress)
MY_ADDRESS3=$(bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=mywallet getnewaddress)
bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet sendtoaddress "$MY_ADDRESS" 50
bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet sendtoaddress "$MY_ADDRESS2" 5
bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet sendtoaddress "$MY_ADDRESS2" 5
bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcwallet=side_wallet generatetoaddress 1 "$MY_ADDRESS"
echo "----------------------"
echo "Your address is $MY_ADDRESS with balance 50"
echo "Another address is $MY_ADDRESS2 with balance 10"
echo "Address $MY_ADDRESS3 with empty balance"
echo "Address from other wallet is $FIRST_ADDRESS"
echo "Start all commands with bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcport=18443 -rpcwallet=mywallet"
echo "----------------------"
echo "Wallet UTXOs: bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass -rpcport=18443 -rpcwallet=mywallet listunspent"
