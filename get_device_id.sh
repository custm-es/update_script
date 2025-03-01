#!/bin/sh

# Obtener las direcciones MAC de las dos primeras interfaces de red
MAC1=$(ifconfig | grep -m 1 ether | sed 's/.*ether //;s/ .*//')
MAC2=$(ifconfig | grep -m 2 ether | tail -n 1 | sed 's/.*ether //;s/ .*//')

# Combinar las dos direcciones MAC
COMBINED_MAC="${MAC1}${MAC2}"

# Generar el hash MD5 de la combinación
DEVICE_ID=$(echo -n "$COMBINED_MAC" | md5)

# Imprimir el DEVICE_ID
echo "El DEVICE_ID generado es: $DEVICE_ID"
