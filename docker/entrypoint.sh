#!/usr/bin/env bash

while true; do
    sleep 15m
    /usr/local/bin/php -f /var/www/html/cliupdate.php
done &

exec apache2-foreground