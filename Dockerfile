FROM mhart/alpine-node:latest

WORKDIR /src

RUN apk --update add git

ADD node_modules/ ./node_modules/
ADD test/ ./test/
ADD rollcage .rollcage package.json build.sh_functions ./

RUN npm install

CMD ["./rollcage"]
