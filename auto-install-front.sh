#!/bin/bash
# Script: auto-install-front.sh
# Description: Télécharge, configure et lance automatiquement le service front-end

REPO_URL="https://github.com/SstealzZ/AWSCloudTraining"
SCRIPT_NAME="quick-install-front.sh"
SERVICE_NAME="quick-install-front"

# Étape 1 : Mise à jour des paquets
echo "1. Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

# Étape 2 : Installation de Git
echo "2. Installation de Git..."
sudo apt install -y git

# Étape 3 : Clonage du dépôt
echo "3. Clonage du dépôt depuis GitHub..."
git clone "$REPO_URL" || { echo "Le dépôt existe déjà, suppression et reclonage..."; rm -rf AWSCloudTraining && git clone "$REPO_URL"; }

# Étape 4 : Rendre le script exécutable
echo "4. Rendre le script $SCRIPT_NAME exécutable..."
chmod +x "AWSCloudTraining/$SCRIPT_NAME"

# Étape 5 : Créer le fichier de service systemd
echo "5. Création du service $SERVICE_NAME.service..."
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Quick Install and Start Front-End Service
After=network.target

[Service]
ExecStart=/bin/bash $(pwd)/AWSCloudTraining/$SCRIPT_NAME
WorkingDirectory=$(pwd)/AWSCloudTraining
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

# Étape 6 : Recharger systemd
echo "6. Rechargement de systemd..."
sudo systemctl daemon-reload

# Étape 7 : Activer le service
echo "7. Activation du service $SERVICE_NAME..."
sudo systemctl enable "$SERVICE_NAME"

# Étape 8 : Démarrer le service
echo "8. Démarrage du service $SERVICE_NAME..."
sudo systemctl start "$SERVICE_NAME"

# Étape 9 : Vérification du statut du service
echo "9. Vérification du statut du service..."
sudo systemctl status "$SERVICE_NAME"
