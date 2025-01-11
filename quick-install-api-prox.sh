#!/bin/bash
# Script: quick-install-api-prox.sh
# Description: Installe et configure l'API sur Proxmox

echo "Mise à jour des paquets..."
apt update && apt upgrade -y

echo "Installation de Python..."
apt install -y python3.11-venv

echo "Création d'un environnement virtuel pour l'API..."
cd api || exit
python3.11 -m venv venv
source venv/bin/activate

echo "Installation des dépendances..."
pip install -r requirements.txt

echo "Lancement de l'API..."
uvicorn app:app --host 0.0.0.0 --reload
