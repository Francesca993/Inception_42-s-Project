#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=IT/ST=Rome/L=Rome/O=42/OU=student/CN=${DOMAIN_NAME}"

exec nginx -g "daemon off;"