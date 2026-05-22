FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	php-fpm \
	php-mysql \
	mariadb-client \
	curl \
	less \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/setup.sh /tmp/setup.sh

RUN chmod +x /tmp/setup.sh

EXPOSE 9000

CMD ["/tmp/setup.sh"]