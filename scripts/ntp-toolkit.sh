#!/bin/bash

'''
Note: This is mostly untested.. use it as a reference or go for it... its a raspberry pi...
'''

set -e

TOOLKIT_DIR="$(pwd)"

# Ensure we're root
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run with sudo or as root."
  echo "ℹ️  Try: sudo $0"
  exit 1
fi

print_menu() {
  echo ""
  echo "===================================="
  echo " 🕰️  NTP Toolkit for Raspberry Pi"
  echo "===================================="
  echo " 1) Build NTP Server (fresh install)"
  echo " 2) Restore Configs (from export)"
  echo " 3) Export Current Configs"
  echo " 4) Run Validation Test"
  echo " 5) Exit"
  echo "===================================="
  echo -n "Select an option [1-5]: "
}

build_ntp() {
  echo "Starting build..."
  bash "$TOOLKIT_DIR/build.sh"
}

restore_ntp() {
  echo -n "Enter path to config folder (e.g., ./ntp-configs): "
  read -r restore_path
  if [[ ! -d "$restore_path" ]]; then
    echo "❌ Directory not found: $restore_path"
    return
  fi
  echo "Restoring from $restore_path..."
  bash "$TOOLKIT_DIR/build.sh" --restore "$restore_path"
}

export_configs() {
  echo "Exporting system configs to ./ntp-configs/..."
  bash "$TOOLKIT_DIR/export-configs.sh"
}

run_test() {
  echo "Running NTP system validation..."
  bash "$TOOLKIT_DIR/test.sh"
}

while true; do
  print_menu
  read -r choice
  case $choice in
    1) build_ntp ;;
    2) restore_ntp ;;
    3) export_configs ;;
    4) run_test ;;
    5) echo "Goodbye!"; exit 0 ;;
    *) echo "❌ Invalid choice. Please select 1-5." ;;
  esac
done
