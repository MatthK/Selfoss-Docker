# Filename: Dockerfile
FROM php:7.4-apache

MAINTAINER Matthias Karl matthias.karl@gmail.com

# Set frontend mode as noninteractive (default answers to all questions)
ENV DEBIAN_FRONTEND noninteractive

RUN a2enmod headers rewrite \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
               unzip \
               libjpeg62-turbo-dev \
               libpng-dev \
               libpq-dev \
               cron \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd pdo_pgsql pdo_mysql mysqli \
    && docker-php-ext-enable mysqli

ADD https://github.com/SSilence/selfoss/releases/download/2.18/selfoss-2.18.zip /tmp/
RUN unzip /tmp/selfoss-*.zip -d /var/www/html && \
    rm /tmp/selfoss-*.zip && \
    ln -s /var/www/html/data/config.ini /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Extend maximum execution time, so /refresh does not time out
COPY ./docker/php.ini /usr/local/etc/php/
COPY ./docker/vhost.conf /etc/apache2/sites-enabled/000-default.conf

VOLUME /var/www/html/data

RUN echo "*/15 *  * * *  root  curl -s http://localhost:80/update\n" >> /etc/crontab

ENTRYPOINT /bin/bash -c "cron && apache2-foreground"