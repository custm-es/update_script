#!/bin/sh

# Variables
UUID=$(kenv smbios.system.uuid)  # Get the device's UUID
DEVICE_ID=$(echo -n "$UUID" | md5)  # Generate MD5 hash of the UUID
CONFIG_URL="https://raw.githubusercontent.com/custm-es/update_script/main/devices/${DEVICE_ID}/config.xml"
TEMP_FILE="/tmp/${DEVICE_ID}-config.xml"
CURRENT_CONFIG="/conf/config.xml"  # Updated to the correct path
LOG_FILE="/var/log/config_update.log"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Step 1: Download the configuration file for this device
/usr/bin/fetch -o $TEMP_FILE $CONFIG_URL
if [ $? -ne 0 ]; then
    log "Error: Failed to download configuration file from $CONFIG_URL"
    exit 1
fi
log "Downloaded configuration file for $DEVICE_ID from $CONFIG_URL"

# Step 2: Compare the current configuration with the new one
if cmp -s $CURRENT_CONFIG $TEMP_FILE; then
    log "The new configuration is identical to the current one. No changes applied."
    rm -f $TEMP_FILE
    exit 0
fi
log "The new configuration differs from the current one. Proceeding to apply it."

# Step 3: Apply the new configuration using pfSense PHP API
/usr/local/bin/php -q <<EOF
<?php
require_once("globals.inc");
require_once("config.inc");
require_once("functions.inc");
require_once("services.inc");

\$config_file = "/tmp/${DEVICE_ID}-config.xml";
\$config = parse_config(true, true, \$config_file);

if (\$config === false) {
    file_put_contents("/var/log/config_update.log", date('Y-m-d H:i:s') . " - Error: Invalid configuration file format.\n", FILE_APPEND);
    exit(1);
}

write_config("Updated configuration from GitHub for device ${DEVICE_ID}");
file_put_contents("/var/log/config_update.log", date('Y-m-d H:i:s') . " - Configuration applied successfully.\n", FILE_APPEND);
?>
EOF

# Step 4: Check for errors in the PHP execution
if [ $? -eq 0 ]; then
    log "Configuration applied successfully."
else
    log "Error: Failed to apply the configuration."
    exit 1
fi

# Step 5: Clean up the temporary file
rm -f $TEMP_FILE
log "Temporary configuration file removed."
