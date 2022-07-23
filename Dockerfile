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
               git \
               npm \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd pdo_pgsql pdo_mysql mysqli \
    && docker-php-ext-enable mysqli

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN git clone https://github.com/fossar/selfoss /var/www/html
RUN ln -s /var/www/html/data/config.ini /var/www/html && \
    chown -R www-data:www-data /var/www/html

RUN cd /var/www/html/assets && npm install --global --unsafe-perm exp && npm audit fix

# Extend maximum execution time, so /refresh does not time out
COPY ./docker/php.ini /usr/local/etc/php/
COPY ./docker/vhost.conf /etc/apache2/sites-enabled/000-default.conf

VOLUME /var/www/html/data

RUN echo "*/15 *  * * *  root  curl -s http://localhost:8080/update\n" >> /etc/crontab

ENTRYPOINT HEALTHCHECK --interval=5m --timeout=3s /bin/bash -c "cron && composer install && cd /var/www/html/assets && npm run build && cd .. && apache2-foreground"