# https://github.com/renoki-co/laravel-docker-base
FROM quay.io/renokico/laravel-base:1.1.0-8.0-fpm-alpine

COPY . /var/www/html

RUN mkdir -p /var/www/html/storage/logs/ && \
    chown -R www-data:www-data /var/www/html && \
    rm -rf tests/ .git/ .github/ *.md && \
    rm -rf vendor/*/test/ vendor/*/tests/*

WORKDIR /var/www/html
