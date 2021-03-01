#!/bin/bash

set_env_variables() {
    if [[ ! -z "${APP_URL}" ]]
    then
        echo "Setting APP_URL..."
        sed -i "s|APP_URL=.*|APP_URL="$APP_URL"|g" /var/www/bookstack/.env
    else 
        echo "Environmental variable APP_URL not set. Cannot continue!"
        exit 1;
    fi

    if [[ ! -z "${DB_HOST}" ]]
    then
        echo "Setting DB_HOST..."
        sed -i "s|DB_HOST=.*|DB_HOST="$DB_HOST"|g" /var/www/bookstack/.env
    else 
        echo "Environmental variable DB_HOST not set. Cannot continue!"
        exit 1;
    fi

    if [[ ! -z "${DB_DATABASE}" ]]
    then
        echo "Setting DB_DATABASE..."
        sed -i "s|DB_DATABASE=.*|DB_DATABASE="$DB_DATABASE"|g" /var/www/bookstack/.env
    else 
        echo "Environmental variable DB_DATABASE not set. Cannot continue!"
        exit 1;
    fi

    if [[ ! -z "${DB_USERNAME}" ]]
    then
        echo "Setting DB_USERNAME..."
        sed -i "s|DB_USERNAME=.*|DB_USERNAME="$DB_USERNAME"|g" /var/www/bookstack/.env
    else 
        echo "Environmental variable DB_USERNAME not set. Cannot continue!"
        exit 1;
    fi

    if [[ ! -z "${DB_PASSWORD}" ]]
    then
        echo "Setting DB_PASSWORD..."
        sed -i "s|DB_PASSWORD=.*|DB_PASSWORD="$DB_PASSWORD"|g" /var/www/bookstack/.env
    else 
        echo "Environmental variable DB_PASSWORD not set. Cannot continue!"
        exit 1;
    fi
}

if [[ -z "$(ls -A /var/www/bookstack/public)" ]]
then
    echo "Bookstack data folder is empty. Fixing..."
    cp -r /tmp/bookstack/ /var/www/
else
    echo "Bookstack data folder is not empty. Continueing"
fi

if [[ ! -f /var/www/bookstack/.env ]]
then
    echo "Bookstack is not set up. Setting up..."
    cp /var/www/bookstack/.env.example /var/www/bookstack/.env
    
    set_env_variables

    cd /var/www/bookstack
    php artisan key:generate --no-interaction --force
    php artisan migrate --no-interaction --force
else
    echo "Bookstack is already set up. Continueing"
fi

echo "Performing preflight configuration..."

set_env_variables

#Create the files and folders required for PHP FPM
mkdir -p /run/php/
touch /run/php/php7.4-fpm.sock

#Logging directories
mkdir -p /var/log/php-fpm
mkdir -p /var/log/nginx

#Webdirectory permissions
chown -R www-data:www-data /var/www/bookstack
chmod -R u+rw /var/www/bookstack/storage
chmod -R u+rw /var/www/bookstack/bootstrap/cache
chmod -R u+rw /var/www/bookstack/public/uploads

echo "Preflight configuration complete. Starting Bookstack app."

/usr/bin/supervisord -n -c /app/supervisord.conf