#!/bin/bash
'''
Note: This is mostly untested.. use it as a reference or go for it... its a raspberry pi...

Fresh Build:
sudo ./build.sh

Rebuild from Exported Configs:
sudo ./build.sh --restore ./ntp-configs/
'''

set -e

# Check for sudo/root
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run with sudo or as root."
  echo "ℹ️  Try: sudo $0"
  exit 1
fi

RESTORE_PATH=""

# Parse optional --restore flag
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --restore)
      shift
      RESTORE_PATH="$1"
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Usage: sudo ./build.sh [--restore /path/to/ntp-configs/]"
      exit 1
      ;;
  esac
  shift
done

echo "🛠️  Starting Raspberry Pi Stratum-1 NTP Server Setup..."
echo ""

# Step 1: System update
echo "📦 Updating system packages..."
apt update && apt upgrade -y && apt autoremove -y

# Step 2: Install dependencies
echo "📦 Installing chrony, gpsd, pps-tools, vim..."
apt install -y chrony gpsd gpsd-clients pps-tools vim

# Step 3: Configure /boot/config.txt for PPS and UART
echo "🔧 Configuring /boot/config.txt"
CONFIG=/boot/config.txt
grep -q "enable_uart=1" "$CONFIG" || echo "enable_uart=1" >> "$CONFIG"
grep -q "dtoverlay=pps-gpio,gpiopin=18" "$CONFIG" || echo "dtoverlay=pps-gpio,gpiopin=18" >> "$CONFIG"

# Step 4: Clean serial console if needed
echo "⚙️  Cleaning serial console from /boot/cmdline.txt"
sed -i 's/console=serial0,115200 //g' /boot/cmdline.txt

# Step 5: Restore configs if --restore is used
if [[ -n "$RESTORE_PATH" && -d "$RESTORE_PATH" ]]; then
  echo "♻️ Restoring configuration files from: $RESTORE_PATH"
  
  [ -f "$RESTORE_PATH/chrony.conf" ] && cp "$RESTORE_PATH/chrony.conf" /etc/chrony/chrony.conf
  [ -f "$RESTORE_PATH/gpsd" ] && cp "$RESTORE_PATH/gpsd" /etc/default/gpsd
  [ -f "$RESTORE_PATH/pps-sources.rules" ] && cp "$RESTORE_PATH/pps-sources.rules" /etc/udev/rules.d/pps-sources.rules
  [ -f "$RESTORE_PATH/config.txt" ] && cp "$RESTORE_PATH/config.txt" /boot/config.txt
  [ -f "$RESTORE_PATH/cmdline.txt" ] && cp "$RESTORE_PATH/cmdline.txt" /boot/cmdline.txt
else
  echo "📝 No restore path given or directory doesn't exist. Using default config."
  
  # gpsd default
  echo "🔧 Writing default /etc/default/gpsd"
  cat <<EOF > /etc/default/gpsd
START_DAEMON="true"
GPSD_OPTIONS="-n"
DEVICES="/dev/serial0"
USBAUTO="false"
GPSD_SOCKET="/var/run/gpsd.sock"
EOF

  # udev rule
  echo "📎 Creating /etc/udev/rules.d/pps-sources.rules"
  cat <<EOF > /etc/udev/rules.d/pps-sources.rules
KERNEL=="pps0", OWNER="root", GROUP="tty", MODE="0660"
EOF

  # append to chrony.conf
  echo "📌 Appending GPS/PPS sources to /etc/chrony/chrony.conf"
  cat <<EOF >> /etc/chrony/chrony.conf

# GPS Serial Input
refclock SHM 0 offset 0.5 delay 0.2 refid GPS

# PPS Signal Input
refclock PPS /dev/pps0 refid PPS lock GPS

EOF
fi

# Step 6: Stop socket and enable services
echo "🔁 Restarting and enabling gpsd and chrony"
systemctl stop gpsd.socket || true
systemctl disable gpsd.socket || true
systemctl enable gpsd.service
systemctl restart gpsd.service
systemctl enable chrony
systemctl restart chrony

# Final message
echo ""
echo "✅ Build complete!"
echo "📎 PPS and GPS configured. Chrony + gpsd are running."
echo "🔁 Reboot is required to activate overlays and apply kernel modules."
echo ""
echo "Run: sudo reboot"
