#!/bin/bash

echo "======================================"
echo " 🧪 Raspberry Pi NTP Server Test Suite"
echo "======================================"
echo ""

# Check GPS device
echo "🔌 Checking GPS device (/dev/serial0)..."
if [ -e /dev/serial0 ]; then
    echo "✅ /dev/serial0 found"
else
    echo "❌ GPS device not found!"
fi
echo ""

# Check PPS device
echo "🔌 Checking PPS device (/dev/pps0)..."
if [ -e /dev/pps0 ]; then
    echo "✅ /dev/pps0 found"
else
    echo "❌ PPS device not found!"
fi
echo ""

# Check gpsd service
echo "📡 Checking gpsd.service..."
systemctl is-active --quiet gpsd.service && echo "✅ gpsd is running" || echo "❌ gpsd is NOT running"
echo ""

# Check chrony service
echo "⏱️ Checking chrony.service..."
systemctl is-active --quiet chrony.service && echo "✅ chrony is running" || echo "❌ chrony is NOT running"
echo ""

# Test GPS signal lock using gpspipe
echo "📍 Checking GPS signal with gpspipe..."
MODE=$(gpspipe -w -n 10 | grep -m1 TPV | grep -o '"mode":[0-9]' | cut -d: -f2)

if [ "$MODE" == "3" ]; then
    echo "✅ GPS fix acquired (3D lock)"
elif [ "$MODE" == "2" ]; then
    echo "⚠️  GPS has 2D fix (not ideal, but acceptable)"
else
    echo "❌ No GPS fix detected"
fi

# Test PPS with ppstest
echo "🧿 Testing PPS signal (/dev/pps0)..."
sudo ppstest /dev/pps0 | head -n 5
echo ""

# Chrony tracking check
echo "📈 Chrony Tracking Summary:"
chronyc tracking
echo ""

# Chrony sources check
echo "📡 Chrony Sources:"
chronyc -n sources
echo ""

# Client report (if any)
echo "🧑‍🤝‍🧑 Chrony Clients:"
sudo chronyc clients
echo ""

echo "✅ All checks complete. Review output above."
