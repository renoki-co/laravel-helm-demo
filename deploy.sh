#!/bin/bash

composer install --ignore-platform-reqs --optimize-autoloader --no-dev

php artisan config:cache
php artisan route:cache
php artisan view:cache
