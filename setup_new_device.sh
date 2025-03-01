#!/bin/bash

# Variables
CONFIG_REPO="git@github.com:custm-es/update_script.git"
DEFAULT_CONFIG_PATH="default/config.xml"
REPO_PATH="/home/custm/tmp/config_repo"
SSH_KEY_DIR="$HOME/.ssh"
DEVICE_DIR="devices"

# Get ID device
MAC1=$(ifconfig | grep -m 1 ether | awk '{print $2}')
MAC2=$(ifconfig | grep -m 2 ether | tail -n1 | awk '{print $2}')
COMBINED_MAC="${MAC1}${MAC2}"
DEVICE_ID=$(echo -n "$COMBINED_MAC" | md5)

# Check if the SSH key exists
if [ ! -f "$SSH_KEY_DIR/$DEVICE_ID" ]; then
    echo "Error: La clave SSH no existe. Ejecuta el primer script para generar la clave SSH."
    exit 1
fi

echo "Configurando nuevo dispositivo: $DEVICE_ID"

# Clone repository
echo "Clonando repositorio de configuración..."
GIT_SSH_COMMAND="ssh -i $SSH_KEY_DIR/$DEVICE_ID -o StrictHostKeyChecking=no" git clone --depth=1 $CONFIG_REPO $REPO_PATH

# Verify if the repository was cloned successfully
if [ ! -d "$REPO_PATH" ]; then
    echo "Error: No se pudo clonar el repositorio. Verifica las credenciales SSH."
    exit 1
fi

cd $REPO_PATH

# Ask for Git credentials
read -p "Introduce tu nombre de usuario de Git: " GIT_USER_NAME
read -p "Introduce tu correo electrónico de Git: " GIT_USER_EMAIL

# Configure Git identity only for this repository
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

# Create and change to develop branch
git checkout -b develop

# Create ID device directory
DEVICE_PATH="$REPO_PATH/$DEVICE_DIR/$DEVICE_ID"
mkdir -p "$DEVICE_PATH/apply"
mkdir -p "$DEVICE_PATH/backup"

# Copy default configuration
echo "Aplicando configuración por defecto..."
cp "$REPO_PATH/$DEFAULT_CONFIG_PATH" "$DEVICE_PATH/apply/config.xml"
cp "$REPO_PATH/$DEFAULT_CONFIG_PATH" "$DEVICE_PATH/backup/config.xml"

# Push initial configuration
echo "Subiendo configuración inicial..."
GIT_SSH_COMMAND="ssh -i $SSH_KEY_DIR/$DEVICE_ID -o StrictHostKeyChecking=no" git add "$DEVICE_PATH"
GIT_SSH_COMMAND="ssh -i $SSH_KEY_DIR/$DEVICE_ID -o StrictHostKeyChecking=no" git commit -m "Añadido nuevo dispositivo: $DEVICE_ID"
GIT_SSH_COMMAND="ssh -i $SSH_KEY_DIR/$DEVICE_ID -o StrictHostKeyChecking=no" git push origin develop

# Remove temporary files
echo "Limpiando archivos temporales..."
rm -rf $REPO_PATH

echo "Configuración completada para $DEVICE_ID"
