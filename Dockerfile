FROM php:7.4-fpm-buster

LABEL vendor="kronova.net"
LABEL maintainer="info@kronova.net"

RUN apt-get update && apt-get install -y imagemagick git nano libwebp-dev libjpeg-dev libfreetype6-dev libicu-dev \
libzzip-dev libpq-dev unzip libzip-dev libonig-dev && yes '' | pecl install -f apcu
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd mbstring opcache mysqli json intl zip pdo pdo_pgsql pdo_mysql pgsql bcmath exif

RUN sed -i -e "s?listen = 127.0.0.1:9000?listen = 9000?g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -e "s?;chdir = /var/www?chdir = /var/www/html?g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -e "s?user = www-data?user = typo3?" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -e "s?group = www-data?group = daemon?" /usr/local/etc/php-fpm.d/www.conf

COPY install-composer.sh /app/install-composer.sh
RUN /app/install-composer.sh

# copy custom configurations
COPY php-configs /usr/local/etc/php/conf.d

# add user typo3 to allow shell access
RUN useradd -g 1 -m -s "/bin/bash" typo3

# cleanup
RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
