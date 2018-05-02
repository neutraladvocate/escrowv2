FROM node:carbon-alpine

WORKDIR /app

ADD . /app

RUN npm install -g truffle
RUN npm install

EXPOSE 8545 80

ENTRYPOINT truffle test test/EscrowTest.js --verbose-rpc