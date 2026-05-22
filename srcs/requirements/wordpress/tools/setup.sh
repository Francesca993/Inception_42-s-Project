#!/bin/bash
set -e

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

mkdir -p /var/www/html
cd /var/www/html

echo "=== START WORDPRESS SETUP ==="

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Waiting for MariaDB..."

    until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
        sleep 2
    done

    echo "MariaDB reachable."

    echo "Testing DB connection..."
    until DB_ERROR="$(mysql -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1;" 2>&1 >/dev/null)"; do
        echo "Database not ready yet..."
        if [ -n "${DB_ERROR}" ]; then
            echo "MySQL error: ${DB_ERROR}"
        fi
        sleep 2
    done

    echo "Database connection OK."

    if [ ! -f wp-load.php ]; then
        wp core download --allow-root
    fi

    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306"

    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root || true

    chown -R www-data:www-data /var/www/html
fi

mkdir -p /run/php
exec /usr/sbin/php-fpm7.4 -F