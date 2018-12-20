FROM php:7.2-fpm

RUN apt-get update && apt-get install -y imagemagick git nano libwebp-dev libjpeg-dev libfreetype6-dev libicu-dev \
libzzip-dev libpq-dev unzip \
&& yes '' | pecl install -f apcu \
&& docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include \
&& docker-php-ext-install gd mbstring opcache mysqli json intl zip pdo pdo_pgsql pgsql

RUN sed -i -e "s?listen = 127.0.0.1:9000?listen = 9000?g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -e "s?;chdir = /var/www?chdir = /var/www/html?g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -e "s?user = www-data?user = daemon?" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -e "s?group = www-data?group = daemon?" /usr/local/etc/php-fpm.d/www.conf

COPY install-composer.sh /app/install-composer.sh
RUN /app/install-composer.sh

# copy custom configurations
COPY php-configs /usr/local/etc/php/conf.d

# cleanup
RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
