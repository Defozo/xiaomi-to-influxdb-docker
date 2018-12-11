FROM arm32v6/node:alpine

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash curl jq \
    && npm install -g miio

ENTRYPOINT ["/entrypoint.sh"]
