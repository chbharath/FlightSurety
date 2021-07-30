# FlightSurety

FlightSurety is a sample application project for Udacity's Blockchain course.

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`

## Develop Client

To run truffle tests:

`truffle test ./test/flightSurety.js`
`truffle test ./test/oracles.js`

To use the dapp:

`truffle migrate`
`npm run dapp`

To view dapp:

`http://localhost:8000`

## Develop Server

`npm run server`
`truffle test ./test/oracles.js`

## Deploy

To build dapp for prod:
`npm run dapp:prod`

Deploy the contents of the ./dapp folder


## Resources

* [How does Ethereum work anyway?](https://medium.com/@preethikasireddy/how-does-ethereum-work-anyway-22d1df506369)
* [BIP39 Mnemonic Generator](https://iancoleman.io/bip39/)
* [Truffle Framework](http://truffleframework.com/)
* [Ganache Local Blockchain](http://truffleframework.com/ganache/)
* [Remix Solidity IDE](https://remix.ethereum.org/)
* [Solidity Language Reference](http://solidity.readthedocs.io/en/v0.4.24/)
* [Ethereum Blockchain Explorer](https://etherscan.io/)
* [Web3Js Reference](https://github.com/ethereum/wiki/wiki/JavaScript-API)


Mounikas-MacBook-Air:Untiltled mounikabachu$ npm test
(node:14294) ExperimentalWarning: The fs.promises API is experimental

> flightsurety@1.0.0 test
> truffle test ./test/flightSurety.js

Using network 'development'.


Compiling your contracts...
===========================
> Compiling ./contracts/FlightSuretyApp.sol
> Compiling ./contracts/FlightSuretyData.sol
> Compilation warnings encountered:

    project:/contracts/FlightSuretyData.sol:62:37: Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
                                    address firstAirline
                                    ^------------------^

> Artifacts written to /var/folders/gp/pptyv1rd1zn4bmjr2j72m5zc0000gn/T/test--14295-OiNLEIYg34YZ
> Compiled successfully using:
   - solc: 0.5.16+commit.9c3226ce.Emscripten.clang



  Contract: Flight Surety Tests
    ✓ (multiparty) has correct initial isOperational() value (49ms)
    ✓ (multiparty) can block access to setOperatingStatus() for non-Contract Owner account (1823ms)
    ✓ (multiparty) can allow access to setOperatingStatus() for Contract Owner account (433ms)
    ✓ (multiparty) can block access to functions using requireIsOperational when operating status is false (714ms)
    ✓ (airline) cannot register an Airline using registerAirline() if it is not funded (1210ms)
true
true
    ✓ (multiparty) can register an Airline using registerAirline() if it is funded (1501ms)
true
true
    ✓ (multiparty) fifth airline can be registered with multiparty concensus (2281ms)


  7 passing (10s)