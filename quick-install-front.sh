#!/bin/bash
# Script: quick-install-front.sh
# Description: Installe et configure le front-end

echo "Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

echo "Installation de Git et Node.js..."
sudo apt install -y git curl
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

echo "Installation des dépendances dans le front..."
cd front || exit
npm install http-server

echo "Démarrage du serveur HTTP..."
npx http-server -p 8080
