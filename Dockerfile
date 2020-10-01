FROM php:7.0-apache

RUN apt-get -y update && apt-get install -y wget gnupg

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get install -y \
zip \
unzip \
mcrypt \
zlib1g-dev \
libgmp-dev \
libpng-dev \
nodejs \
libfontconfig1 \
libxrender1 \
&& pecl install apcu \
&& docker-php-ext-install -j$(nproc) pdo_mysql \
&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
&& docker-php-ext-install -j$(nproc) gmp \
zip \
opcache

RUN docker-php-ext-install gd

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

RUN apt-get -y install libxrender1 libxtst6 libxi6;

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar vxf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN cp wkhtmltox/bin/wk* /usr/local/bin/

RUN mkdir -p /var/lib/php/sessions && chown -R www-data.www-data /var/lib/php/sessions

RUN mkdir -p /tmp/symfony && chown -R www-data.www-data /tmp/symfony

RUN npm install gulp bower -y -g

RUN a2enmod rewrite

RUN sed -i "s/DocumentRoot .*/DocumentRoot \/var\/www\/html\/web/" /etc/apache2/sites-available/000-default.conf

RUN wkhtmltopdf --version