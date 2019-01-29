# truffle compile
FROM node:carbon-alpine

WORKDIR /app

ADD . /app

RUN npm install -g truffle
RUN npm install

ENTRYPOINT truffle test test/EscrowTest.js --verbose-rpc --network=neutadv