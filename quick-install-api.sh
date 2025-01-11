#!/bin/bash
# Script: quick-install-api.sh
# Description: Installe et configure l'API

echo "Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

echo "Installation de Python..."
sudo apt install -y python3.11-venv

echo "Création d'un environnement virtuel pour l'API..."
cd api || exit
python3.11 -m venv venv
source venv/bin/activate

echo "Installation des dépendances..."
pip install -r requirements.txt

echo "Lancement de l'API..."
uvicorn app:app --host 0.0.0.0 --reload
