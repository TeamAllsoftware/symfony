FROM php:8.1-apache-bookworm

# wget & gnupg
RUN apt -y update && apt install -y wget gnupg

# Node 20
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Gitlab-Runner
RUN curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash

RUN rm /etc/apt/preferences.d/no-debian-php && \
apt -y update && apt install -y \
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
jq \
gitlab-runner \
libz-dev libzip-dev \
nano \
libfontconfig1 \
libxrender1 \
libwebp-dev \
libjpeg62-turbo-dev \
libpng-dev \
libfreetype6-dev \
zlib1g-dev \
libicu-dev \
g++

# Exif - PHP
RUN docker-php-ext-configure exif --enable-exif
RUN docker-php-ext-install exif

# GD - PHP
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd

# XSL - PHP
RUN docker-php-ext-configure xsl

RUN pecl install apcu \
&& docker-php-ext-install -j$(nproc) pdo_mysql \
&& docker-php-ext-install soap zip xsl intl \
&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
&& docker-php-ext-install -j$(nproc) gmp opcache

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# WeasyPrint
# https://doc.courtbouillon.org/weasyprint/stable/first_steps.html#debian-11
RUN apt install -y weasyprint

# Libreoffice
RUN apt install -y libreoffice

# XDebug
RUN yes | pecl install xdebug \
	&& echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

# xdebug_state
COPY xdebug_state.sh /usr/bin/xdebug_state
RUN chmod +x /usr/bin/xdebug_state
ENV xdebugRemoteMachine=${xdebugRemoteMachine:-""}
ENV userPrefixPort=${userPrefixPort:-""}

# Python3 => Python
RUN apt install -y python3-virtualenv python-is-python3

# Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli -y

# AWS eb-cli
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git \
    && python ./aws-elastic-beanstalk-cli-setup/scripts/ebcli_installer.py
ENV PATH="/root/.ebcli-virtual-env/executables:$PATH"

# AWS cli
RUN apt install -y awscli

# Creation dossier sessions
RUN mkdir -p /var/lib/php/sessions && chown -R www-data.www-data /var/lib/php/sessions
# Creation dossier symfony
RUN mkdir -p /tmp/symfony && chown -R www-data.www-data /tmp/symfony

RUN a2enmod rewrite

# Geckodriver
ENV GECKODRIVER_VERSION=0.28.0
RUN wget -q https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VERSION/geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz && \
    tar -zxf geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz -C /usr/bin && \
    rm geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz

# Navigateur Firefox
RUN apt install -y firefox-esr

## PHPUnit
# RUN wget -O phpunit https://phar.phpunit.de/phpunit-9.phar && \
#    chmod +x phpunit && \
#    mv phpunit /usr/local/bin/phpunit

RUN sed -i "s/DocumentRoot .*/DocumentRoot \/var\/www\/html\/public/" /etc/apache2/sites-available/000-default.conf
