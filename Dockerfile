FROM ubuntu:latest

MAINTAINER Pedro Cavalheiro <pedro.cavalheiro@mesalva.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu trusty-updates multiverse" >> /etc/apt/sources.list

RUN apt-get install -y wget software-properties-common

RUN apt-add-repository ppa:phalcon/stable

RUN apt-get update && apt-get install -y nginx && \
apt-get install -y php5 \
php5-fpm \
php5-mysqlnd \
php5-gd \
php-pear \
php-apc \
php5-curl \
php5-mcrypt \
php5-dev \
php-pear \
php5-common \
php5-cli \
php5-cgi \
gcc \
g++ \
git \
php5-phalcon \
php5-xdebug

# install mongo client for php
RUN no | pecl install mongo

# espera para os logs
RUN mkdir -p /var/log/php-fpm

RUN sed -i "s/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

ADD common/20-mcrypt.ini /etc/php5/fpm/conf.d/20-mcrypt.ini
ADD common/20-mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
ADD common/20-mongo.ini /etc/php5/fpm/conf.d/20-mongo.ini
ADD common/www.conf /etc/php5/fpm/pool.d/www.conf

ADD nginx.conf /etc/nginx/nginx.conf
ADD default /etc/nginx/sites-available/default

# para corrigir problemas com CRLF
RUN apt-get update && apt-get install -y dos2unix --fix-missing

ADD reporting.sh /docker/reporting.sh
RUN dos2unix /docker/reporting.sh
RUN . ./docker/reporting.sh

# fix dos caracteres ^M do windows, enquanto não encontramos alguma solução
RUN dos2unix /etc/php5/fpm/pool.d/www.conf

ENV TERM=xterm

EXPOSE 80 443

# TODO separar processos por containers
CMD service php5-fpm start && service nginx start
