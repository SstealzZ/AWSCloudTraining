#!/bin/bash
# Script: quick-install-front-prox.sh
# Description: Installe et configure le front-end sur Proxmox

echo "Mise à jour des paquets..."
apt update && apt upgrade -y

echo "Installation de Git et Node.js..."
apt install -y git curl
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

echo "Installation des dépendances dans le front..."
cd front || exit
npm install http-server

echo "Démarrage du serveur HTTP..."
npx http-server -p 8080
