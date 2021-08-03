# Defi Warriror V2

[![Actions Status](https://github.com/Uniswap/uniswap-v2-core/workflows/CI/badge.svg)](https://github.com/Uniswap/uniswap-v2-core/actions)
[![Version](https://img.shields.io/npm/v/@uniswap/v2-core)](https://www.npmjs.com/package/@uniswap/v2-core)

In-depth documentation on Defi Warrior V2 is available at [defiwarrior.io/](https://defiwarrior.io/).

The built contract artifacts can be browsed via [unpkg.com](https://unpkg.com/browse/@uniswap/v2-core@latest/).

# Local Development

The following assumes the use of `node@>=10`.

## Install Dependencies

`yarn`

## Compile Contracts

`yarn compile`

## Run Tests

`yarn test`


# BUILD LIB FOR JAVA

## Install library

- Install solc
- Install web3j

## Version solidity complie
Version solidity: 0.5.16

## Compile sol to java lib

Compile file sol to abi and bin file
`solc contracts/DefiWarrior.sol --bin --abi -o compile`

Compile to java lib from abi and bin file
`web3j generate solidity -a ./bin/contracts/DefiWarrior.abi -b ./bin/contracts/DefiWarrior.bin -o java -p bap.jp`