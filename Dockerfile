FROM node:carbon-alpine

WORKDIR /app

ADD . /app

RUN npm install

EXPOSE 80

ENTRYPOINT [ "sh", "/app/test.sh" ]
