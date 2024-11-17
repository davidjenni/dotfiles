#!/bin/bash

# Variables
KANATA_PATH="$(realpath $(which kanata))"
echo "Kanata path: $KANATA_PATH"
KANATA_CFG_PATH="$(realpath $(dirname $0)/../home-row-mods.kbd)"
echo "Kanata config path: $KANATA_CFG_PATH"
SUDOERS_FILE="/etc/sudoers.d/kanata"
PLIST_FILE="/Library/LaunchDaemons/com.jtroo.kanata.plist"

# Create a sudoers file entry for kanata
echo "$(whoami) ALL=(ALL) NOPASSWD: $KANATA_PATH" | sudo tee "$SUDOERS_FILE" > /dev/null

# Create a plist file for the LaunchDaemon
cat <<EOF | sudo tee "$PLIST_FILE" > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jtroo.kanata</string>

    <key>ProgramArguments</key>
    <array>
        <string>$KANATA_PATH</string>
        <string>--cfg</string>
        <string>$KANATA_CFG_PATH</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardErrorPath</key>
    <string>/Users/david/.local/Logs/Kanata/kanata.err.log</string>

    <key>StandardOutPath</key>
    <string>/Users/david/.local/Logs/Kanata/kanata.out.log</string>
</dict>
</plist>
EOF

# Load the daemon
sudo launchctl load -w "$PLIST_FILE"
# sudo launchctl enable gui/$(id -u)/com.jtroo.kanata
# sudo launchctl bootstrap gui/$(id -u) "$PLIST_FILE"
