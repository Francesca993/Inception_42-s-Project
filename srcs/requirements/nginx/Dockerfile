FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/default.conf /etc/nginx/sites-available/default
COPY ./tools/setup.sh /tmp/setup.sh

RUN chmod +x /tmp/setup.sh

EXPOSE 443

CMD ["/tmp/setup.sh"]