#!/bin/sh
set -e

echo "==== Substituting config template ===="
envsubst '${INCEPTION_MARIADB_PORT}' \
    < /etc/my.cnf.d/mariadb_config \
    > /etc/my.cnf.d/mariadb_config.tmp \
    && mv /etc/my.cnf.d/mariadb_config.tmp /etc/my.cnf.d/mariadb_config

echo "==== Set up of MariaDB directory ===="
chmod -R 755 /var/lib/mysql

mkdir -p /run/mysqld

chown -R mysql:mysql /var/lib/mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "---- Init of MariaDB system tables"
	mariadb-install-db --basedir=/usr --user=mysql --datadir=/var/lib/mysql >/dev/null
	
	echo "---- Creating WordPress DB & User"
	mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY "$INCEPTION_MYSQL_ROOT_PASSWORD";
CREATE DATABASE $INCEPTION_WP_DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER $INCEPTION_WP_DB_USER@'%' IDENTIFIED BY "$INCEPTION_WP_DB_PASSWORD";
CREATE USER $INCEPTION_WP_DB_USER@'localhost' IDENTIFIED BY "$INCEPTION_WP_DB_PASSWORD";
GRANT ALL PRIVILEGES ON $INCEPTION_WP_DB_NAME.* TO $INCEPTION_WP_DB_USER@'%';
GRANT ALL PRIVILEGES ON $INCEPTION_WP_DB_NAME.* TO $INCEPTION_WP_DB_USER@'localhost';
FLUSH PRIVILEGES;
EOF

else
	echo "==== MariaDB is already installed. Users & DB configured"
fi

echo "==== Starting the MariaDB Server Now! ===="
exec mysqld --defaults-file=/etc/my.cnf.d/mariadb_config
