FROM node:carbon-alpine

EXPOSE 7676

RUN apk update
RUN apk add --no-cache git python bash alpine-sdk pwgen

COPY * /app/

RUN chown -R 1000:1000 /app

USER node

ENV NODE_ENV production

WORKDIR /app

RUN npm install 

RUN git clone https://github.com/noia-network/noia-node-terminal.git --depth=1

RUN cd noia-node-terminal && npm install

USER root

RUN apk del git bash alpine-sdk

USER node

RUN  printf '#!/bin/sh\n\
cd noia-node-terminal\n\
if [ ! -f settings.json ]; then\n\
[ -z $WALLET_ADDRESS ] && WALLET_ADDRESS=0x4adc7773bceedf7b4c687f9bfdd1598378b7d5e1;\n\
[ -z $MASTER_ADDRESS ] && MASTER_ADDRESS=ws://csl-masters.noia.network:5565;\n\
printf \x27{\n\
  "isHeadless": false,\n\
  "skipBlockchain": true,\n\
  "storage.dir": "/app/noia-node-terminal/storage",\n\
  "storage.size": "104857600",\n\
  "domain": "",\n\
  "ssl": false,\n\
  "ssl.privateKeyPath": "",\n\
  "ssl.crtPath": "",\n\
  "ssl.crtBundlePath": "",\n\
  "publicIp": "",\n\
  "sockets.http": false,\n\
  "sockets.http.ip": "0.0.0.0",\n\
  "sockets.http.port": "6767",\n\
  "sockets.ws": true,\n\
  "sockets.ws.ip": "0.0.0.0",\n\
  "sockets.ws.port": "7676",\n\
  "wallet.address": "\x27$WALLET_ADDRESS\x27",\n\
  "wallet.mnemonic": "\x27`pwgen 20`\x27",\n\
  "masterAddress": "\x27$MASTER_ADDRESS\x27",\n\
  "whitelist.masters": [],\n\
  "controller": false,\n\
  "controller.ip": "127.0.0.1",\n\
  "controller.port": "9000",\n\
  "nodeId": "\x27`pwgen 40`\x27"\n\
}\x27 >> settings.json;\n\
fi;\n\
node index.js\n' >> run.sh && chmod +x run.sh && cat run.sh

CMD ["/app/run.sh"]
