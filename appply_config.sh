# Remote URL of the configuration file
CONFIG_URL="https://custm.es/config1.xml"

# Temporary location to store the downloaded config
TEMP_FILE="/tmp/config1.xml"

# Download the configuration file
/usr/bin/fetch -o $TEMP_FILE $CONFIG_URL

# Verify the download was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to download configuration file from $CONFIG_URL"
  exit 1
fi

# Restore the configuration using pfSense's PHP API
/usr/local/bin/php -q <<'EOF'
<?php
require_once("globals.inc");
require_once("config.inc");
require_once("functions.inc");
require_once("services.inc");

$config_file = "/tmp/config1.xml";
$config = parse_config(true, true, $config_file);

if ($config === false) {
    echo "Error: Invalid configuration file format.\n";
    exit(1);
}

write_config();
echo "Configuration applied successfully.\n";
?>
EOF

# Check if the restore was successful
if [ $? -eq 0 ]; then
  echo "Configuration applied successfully."
else
  echo "Error: Failed to apply the configuration."
  exit 1
fi

# Clean up the temporary file
rm -f $TEMP_FILE