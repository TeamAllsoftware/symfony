FROM php:8.0-apache-buster

RUN apt-get -y update && apt-get install -y wget gnupg

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash

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
libxslt-dev \
php-soap \
yarn \
gitlab-runner \
libz-dev libzip-dev \
nano \
libfontconfig1 \
libxrender1 \
libwebp-dev \
libjpeg62-turbo-dev \
libpng-dev \
zlib1g-dev \
libicu-dev \
g++

RUN docker-php-ext-configure gd
RUN docker-php-ext-configure xsl

RUN pecl install apcu zlib \
&& docker-php-ext-install -j$(nproc) pdo_mysql \
&& docker-php-ext-install soap zip gd xsl intl \
&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
&& docker-php-ext-install -j$(nproc) gmp opcache

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN yes | pecl install xdebug \
	&& echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

RUN mkdir -p /var/lib/php/sessions && chown -R www-data.www-data /var/lib/php/sessions

RUN mkdir -p /tmp/symfony && chown -R www-data.www-data /tmp/symfony

RUN a2enmod rewrite

RUN mkdir /root/.ssh

RUN sed -i "s/DocumentRoot .*/DocumentRoot \/var\/www\/html\/public/" /etc/apache2/sites-available/000-default.conf

COPY xdebug_state.sh /usr/bin/xdebug_state
RUN chmod +x /usr/bin/xdebug_state
ENV xdebugRemoteMachine=${xdebugRemoteMachine:-""}
ENV userPrefixPort=${userPrefixPort:-""}

RUN  wget https://get.symfony.com/cli/installer -O - | bash
RUN  mv /root/.symfony/bin/symfony /usr/local/bin/symfony

RUN apt install -y python3-pip python3-dev libffi-dev
ENV PATH=~/.local/bin:$PATH
RUN pip3 install awsebcli --upgrade --user

