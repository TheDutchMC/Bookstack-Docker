FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y
RUN apt-get install -y \
        git \
        nginx \
        supervisor \
        zip \
        unzip \
        software-properties-common

#Add the PHP repository and update
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y

RUN apt-get install -y --no-install-recommends \
        php7.4 \
        php7.4-fpm \
        php7.4-pdo \
        php7.4-mbstring \
        php7.4-tokenizer \
        php7.4-gd \
        php7.4-mysql \
        php7.4-simplexml \
        php7.4-dom \
        php7.4-curl
        
#Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN mv composer.phar /usr/local/bin/composer
RUN rm composer-setup.php

#Clone and install Bookstack
RUN mkdir /tmp/bookstack/
RUN git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch /tmp/bookstack/
RUN composer install --no-dev -d /tmp/bookstack/

#Remove NGINX default configurations
RUN rm -rf /etc/nginx/sites-available/*
RUN rm -rf /etc/nginx/sites-enabled/*

#Put in the bookstack.conf file for NGINX
COPY ./bookstack.conf /etc/nginx/sites-available/bookstack.conf
RUN ln -s /etc/nginx/sites-available/bookstack.conf /etc/nginx/sites-enabled/bookstack.conf

COPY ./supervisord.conf /app/supervisord.conf
COPY ./run.sh /app/run.sh

EXPOSE 80

RUN chmod +x /app/run.sh
ENTRYPOINT ["sh", "-c", "/app/run.sh"]
