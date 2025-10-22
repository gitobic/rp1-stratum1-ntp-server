#!/bin/bash

# Ensure the script is run with sudo
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run with sudo or as root."
  echo "ℹ️  Try: sudo $0"
  exit 1
fi

# Output folder
EXPORT_DIR="ntp-configs"
mkdir -p "$EXPORT_DIR"

echo "📦 Exporting Stratum-1 NTP server configuration files to ./$EXPORT_DIR"
echo ""

# 1. NTP & Chrony
echo "➤ Saving /etc/chrony/chrony.conf"
cp /etc/chrony/chrony.conf "$EXPORT_DIR/chrony.conf"

# 2. GPSD
echo "➤ Saving /etc/default/gpsd"
cp /etc/default/gpsd "$EXPORT_DIR/gpsd"

# 3. Udev PPS rules
echo "➤ Saving /etc/udev/rules.d/pps-sources.rules (if exists)"
[ -f /etc/udev/rules.d/pps-sources.rules ] && cp /etc/udev/rules.d/pps-sources.rules "$EXPORT_DIR/pps-sources.rules"

# 4. Boot config
echo "➤ Saving /boot/firmware/config.txt"
cp /boot/firmware/config.txt "$EXPORT_DIR/config.txt"

# 5. Optional: cmdline.txt (if modified)
echo "➤ Saving /boot/firmware/cmdline.txt"
cp /boot/firmware/cmdline.txt "$EXPORT_DIR/cmdline.txt"

# 6. Status snapshots
echo "➤ Capturing chronyc and GPS/pps state..."
chronyc tracking > "$EXPORT_DIR/chrony-tracking.txt"
chronyc sources > "$EXPORT_DIR/chrony-sources.txt"
chronyc sourcestats > "$EXPORT_DIR/chrony-sourcestats.txt"
chronyc clients > "$EXPORT_DIR/chrony-clients.txt"
ppstest /dev/pps0 | head -n 10 > "$EXPORT_DIR/pps-status.txt"
gpspipe -w -n 10 > "$EXPORT_DIR/gpspipe-output.json"
timeout 5 ntpshmmon > "$EXPORT_DIR/ntpshmmon.txt"

# 7. Networking (optional)
echo "➤ Saving network interfaces info"
ip addr > "$EXPORT_DIR/ip-addr.txt"
hostnamectl > "$EXPORT_DIR/hostnamectl.txt"

echo ""
echo "✅ Export complete. Files saved to: $EXPORT_DIR/"
