#!/bin/bash

# Variables
SSH_KEY_DIR="$HOME/.ssh"

# Obtener identificador único del dispositivo
MAC1=$(ifconfig | grep -m 1 ether | awk '{print $2}')
MAC2=$(ifconfig | grep -m 2 ether | tail -n1 | awk '{print $2}')
COMBINED_MAC="${MAC1}${MAC2}"
DEVICE_ID=$(echo -n "$COMBINED_MAC" | md5)

# Generar clave SSH para el dispositivo
echo "Generando clave SSH..."
ssh-keygen -t ed25519 -C "$DEVICE_ID" -f "$SSH_KEY_DIR/$DEVICE_ID" -N ""

# Mostrar la clave pública
echo "Clave pública generada:"
cat "$SSH_KEY_DIR/$DEVICE_ID.pub"

echo "Añade esta clave pública a tu cuenta de GitHub en Settings > SSH and GPG keys."