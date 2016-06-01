FROM mhart/alpine-node:latest

WORKDIR /src

RUN apk --update add git

ADD . .

RUN npm install

ENTRYPOINT ["./rollcage"]
