# Docker bitcoin regtest node

There are 2 projects:

- Easy
- Samurai

Inside `easy` project you will find `docker-compose.yml` with `regtest` Bitcoin node. 

Inside `samurai` project you will find `docker-compose.yml` with the same `regtest` Bitcoin node, but with some additional features:
- Custom `Dockerfile` with preinstalled `jq` package (command-line JSON processor).
- `generate.sh`. This is a small shell file, that will help you to fill the node with wallets and transactions.
- Readme with 3 different ways of creating and sending Bitcoin transactions 
 

