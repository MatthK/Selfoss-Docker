FROM node:19-bullseye as client

WORKDIR /app
RUN git clone https://github.com/fossar/selfoss . && rm -rf .git
RUN npm install --prefix assets/
RUN npm run --prefix assets/ build

FROM php:8.1-apache
LABEL org.opencontainers.image.authors="matthias.karl@gmail.com"

# Set frontend mode as noninteractive (default answers to all questions)
ENV DEBIAN_FRONTEND noninteractive

RUN a2enmod headers rewrite \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
               unzip \
               libjpeg62-turbo-dev \
               libpng-dev \
               libpq-dev \
               libtidy-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd pdo_pgsql pdo_mysql mysqli tidy \
    && docker-php-ext-enable mysqli

COPY --from=composer /usr/bin/composer /usr/local/bin/composer


# Extend maximum execution time, so /refresh does not time out
COPY ./docker/php.ini /usr/local/etc/php/
COPY ./docker/vhost.conf /etc/apache2/sites-enabled/000-default.conf
COPY ./docker/entrypoint.sh /entrypoint.sh

VOLUME /var/www/html/data
HEALTHCHECK --interval=1m --timeout=3s CMD curl -f http://localhost/ || exit 1

COPY --from=client /app /var/www/html
WORKDIR /var/www/html
RUN composer install
RUN ln -s /var/www/html/data/config.ini /var/www/html
RUN ln -s /proc/1/fd/1 /var/www/html/data/logs/default.log
RUN chown -R www-data:www-data /var/www/html

ENTRYPOINT /entrypoint.sh