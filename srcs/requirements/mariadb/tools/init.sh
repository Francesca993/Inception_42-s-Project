#!/bin/bash
set -euo pipefail

: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE}"
: "${MYSQL_USER:?Missing MYSQL_USER}"

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

SOCKET_PATH="/run/mysqld/mysqld.sock"
PID_PATH="/run/mysqld/mysqld.pid"
MYSQL_AUTH_ARGS=()

echo "=== STARTING MARIADB INIT ==="

install -d -m 0755 -o mysql -g mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "=== INITIALIZING DATABASE DIRECTORY ==="
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

echo "=== STARTING TEMPORARY MARIADB ==="
mysqld_safe \
    --datadir=/var/lib/mysql \
    --socket="${SOCKET_PATH}" \
    --pid-file="${PID_PATH}" \
    --skip-networking &
pid="$!"

echo "=== WAITING FOR MARIADB SOCKET ==="
until mysqladmin --protocol=socket --socket="${SOCKET_PATH}" ping --silent; do
    sleep 1
done

if mysql --protocol=socket --socket="${SOCKET_PATH}" -u root -e "SELECT 1" >/dev/null 2>&1; then
    MYSQL_AUTH_ARGS=(-u root)
elif mysql --protocol=socket --socket="${SOCKET_PATH}" -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
    MYSQL_AUTH_ARGS=(-u root -p"${MYSQL_ROOT_PASSWORD}")
else
    echo "ERROR: Unable to authenticate as root for MariaDB bootstrap."
    exit 1
fi

echo "=== ENSURING DATABASE AND USERS ==="
mysql --protocol=socket --socket="${SOCKET_PATH}" "${MYSQL_AUTH_ARGS[@]}" << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "=== SHUTTING DOWN TEMPORARY MARIADB ==="
mysqladmin --protocol=socket --socket="${SOCKET_PATH}" -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

wait "$pid" || true

echo "=== STARTING FINAL MARIADB ==="
exec mysqld_safe \
    --datadir=/var/lib/mysql \
    --socket="${SOCKET_PATH}" \
    --pid-file="${PID_PATH}"