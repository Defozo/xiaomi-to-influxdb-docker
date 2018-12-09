FROM defozo/miio-cli-docker-armv71

RUN apt-get update -y && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]