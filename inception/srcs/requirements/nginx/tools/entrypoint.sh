#!/bin/sh
set -e

envsubst '${INCEPTION_NGINX_PORT} ${INCEPTION_WP_PORT} ${INCEPTION_DOMAIN}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

exec nginx -c /etc/nginx/nginx.conf -g 'daemon off;'