FROM php:5.4.35-apache

ENV DEBIAN_FRONTEND noninteractive
RUN mkdir -p /var/www/html && mkdir -p /var/db && mkdir -p /var/composer
VOLUME ["/var/www/html"]
VOLUME ["/var/db"]
VOLUME ["/var/composer"]

EXPOSE 3306

RUN 	cp /usr/src/php/php.ini-development /usr/local/etc/php/php.ini && \	
	apt-get -o 'Acquire::CompressionTypes::Order::="gz"' update && \
	apt-get install -y --no-install-recommends \
 	libmcrypt-dev \
	libbz2-dev \
	libpng12-dev \
	mysql-server \
	git \
	nano \
	supervisor && \
	docker-php-ext-install mcrypt bz2 gd mbstring zip pdo_mysql && \
	rm -r /usr/src/php && \
	apt-get purge --auto-remove -y libmcrypt-dev libbz2-dev libpng12-dev && \
	apt-get install -y --no-install-recommends libmcrypt4 libbz2-1.0 libpng12-0 && \
	a2enmod rewrite && \
	a2enmod expires && \
	curl -o /root/node.tar.gz http://nodejs.org/dist/v0.10.33/node-v0.10.33-linux-x64.tar.gz && \
	cd /usr/local && \
	tar --strip-components 1 -xzf /root/node.tar.gz && \
	rm /root/node.tar.gz && \
	npm install -g grunt-cli bower && \
	curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin && \
	/usr/bin/composer self-update && \
	echo "source ~/.aliases" >> /root/.bashrc && \
	sed 's/bind-address/#bind-address/g' /etc/mysql/my.cnf > /etc/mysql/my.cnf

ENV COMPOSER_HOME /var/composer
COPY config/apache.conf /etc/apache2/apache2.conf
COPY config/supervisor.conf  /etc/supervisor/conf.d/supervisord.conf
COPY config/aliases /root/.aliases

CMD ["/usr/bin/supervisord"]
