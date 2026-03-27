#!/bin/sh

echo "==== Starting Wordpress set up ===="
echo "memory_limit = 512M" >> /etc/php83/php.ini

cd /var/www/html

echo "==== Downloading WordPress ===="
wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp || { echo "Failed to download ..."; exit 1; }

chmod +x /usr/local/bin/wp

echo "==== Checking if MariaDB is running before setup"
mariadb-admin ping --protocol=tcp --host=mariadb -u $WORDPRESS_DATABASE_USER --password=$WORDPRESS_DATABASE_USER_PASSWORD --wait=300

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "==== Starting WordPress configuration ===="
	wp core download --allow-root
	
	wp config create \
		--dbname=$WORDPRESS_DATABASE_NAME \
		--dbuser=$WORDPRESS_DATABASE_USER \
		--dbpass=$WORDPRESS_DATABASE_USER_PASSWORD \
		--dbhost=mariadb \
		--force

	wp core install --url="$DOMAIN_NAME" --title="$WORDPRESS_TITLE" \
		--admin_user="$WORDPRESS_ADMIN" \
		--admin_password="$WORDPRESS_ADMIN_PASSWORD" \
		--admin_email="$WORDPRESS_ADMIN_EMAIL" \
		--allow-root \
		--skip-email \
		--path=/var/www/html

	echo "Creating WordPress user"
	wp user create \
		--allow-root \
		$WORDPRESS_USER $WORDPRESS_USER_EMAIL \
		--user_pass=$WORDPRESS_USER_PASSWORD
else
	echo "=== WordPress is already configured"
fi

chown -R www-data:www-data /var/www/html

chmod -R 755 /var/www/html/

php-fpm83 -F #running php-fpm in foreground so container doesnt stop
