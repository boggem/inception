#!/bin/sh
set -e

echo "==== Substituting www.conf template ===="
envsubst '${INCEPTION_WP_PORT}' \
    < /etc/php83/php-fpm.d/www.conf \
    > /etc/php83/php-fpm.d/www.conf.tmp \
    && mv /etc/php83/php-fpm.d/www.conf.tmp /etc/php83/php-fpm.d/www.conf

echo "==== Setting up Wordpress starts ===="
echo "memory_limit = 512M" >> /etc/php83/php.ini

cd /var/www/html

echo "==== Downloading WordPress ===="
wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp || { echo "Failed to download ..."; exit 1; }

chmod +x /usr/local/bin/wp

echo "==== Checking if MariaDB is running ===="
mariadb-admin ping --protocol=tcp --host=mariadb -u $INCEPTION_WP_DB_USER --password=$INCEPTION_WP_DB_USER_PASSWORD --wait=300

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "==== Starting WordPress Config ===="
	wp core download --allow-root
	
	wp config create \
		--dbname=$INCEPTION_WP_DB_NAME \
		--dbuser=$INCEPTION_WP_DB_USER \
		--dbpass=$INCEPTION_WP_DB_USER_PASSWORD \
		--dbhost=mariadb:$INCEPTION_MARIADB_PORT \
		--force

	wp core install --url="$INCEPTION_DOMAIN" --title="$INCEPTION_WP_TITLE" \
		--admin_user="$INCEPTION_WP_ADMIN" \
		--admin_password="$INCEPTION_WP_ADMIN_PASSWORD" \
		--admin_email="$INCEPTION_WP_ADMIN_EMAIL" \
		--allow-root \
		--skip-email \
		--path=/var/www/html

	echo "Creating WordPress user"
	wp user create \
		--allow-root \
		$INCEPTION_WP_USER $INCEPTION_WP_USER_EMAIL \
		--user_pass=$INCEPTION_WP_USER_PASSWORD
else
	echo "=== WordPress is already configured ==="
fi

chown -R www-data:www-data /var/www/html

chmod -R 755 /var/www/html/

php-fpm83 -F #running php-fpm in foreground so container doesnt stop
