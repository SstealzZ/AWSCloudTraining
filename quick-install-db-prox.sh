#!/bin/bash
# Script: quick-install-db-prox.sh
# Description: Installe et configure la base de données sur Proxmox

echo "Mise à jour des paquets..."
apt update && apt upgrade -y

echo "Installation de MariaDB..."
apt install -y mariadb-server mariadb-client

echo "Configuration de MariaDB pour écouter sur toutes les interfaces..."
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

echo "Création d'un utilisateur et d'une base de données..."
mysql -u root <<EOF
CREATE USER 'stealz'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON *.* TO 'stealz'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "Initialisation de la base de données..."
mysql -u stealz -p1234 < db/setup.sql
