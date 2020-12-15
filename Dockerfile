FROM php:7.2-apache

RUN apt-get -y update && apt-get install -y wget gnupg npm \
        libmagickwand-dev --no-install-recommends

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN rm /etc/apt/preferences.d/no-debian-php && \
apt-get -y update && apt-get install -y \
git \
zip \
unzip \
mcrypt \
zlib1g-dev \
libgmp-dev \
nodejs \
libfontconfig1 \
libxrender1 \
libxml2-dev \
php-soap \
yarn \
&& pecl install apcu \
&& pecl install imagick \
&& docker-php-ext-install -j$(nproc) pdo_mysql \
&& docker-php-ext-install soap \
&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
&& docker-php-ext-install -j$(nproc) gmp \
zip \
opcache \
&& docker-php-ext-enable imagick

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_log='/tmp/xdebug.log'" >> /usr/local/etc/php/conf.d/xdebug.ini \
	&& echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

RUN mkdir -p /var/lib/php/sessions && chown -R www-data.www-data /var/lib/php/sessions

RUN mkdir -p /tmp/symfony && chown -R www-data.www-data /tmp/symfony

RUN a2enmod rewrite

RUN mkdir /root/.ssh

RUN sed -i "s/DocumentRoot .*/DocumentRoot \/var\/www\/html\/public/" /etc/apache2/sites-available/000-default.conf

COPY xdebug_state.sh /usr/bin/xdebug_state
RUN chmod +x /usr/bin/xdebug_state
