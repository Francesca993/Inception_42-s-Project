FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/init.sh /tmp/init.sh

RUN chmod +x /tmp/init.sh

EXPOSE 3306

CMD ["/tmp/init.sh"]