# 🕰️ RP1-STRATUM1-NTP-SERVER
August 24.2024

Over the weekend, I built a … thing.

I had a spare Raspberry Pi 4B gathering dust that *needed* a project. So (in no way influenced by my social media feed), I set out to build a self-hosted GPS-backed NTP server.

By the time I was done, I had a **Stratum-1 NTP server** with **GPS PPS** input and **microsecond-level accuracy**. A fully self-hosted Stratum-1 NTP server using a Raspberry Pi 4B, GPS hat, and PPS signal input — delivering **microsecond accuracy** from your own home lab.

---

## 📸 What’s Inside

- ✅ Microsecond-accurate time sync (Stratum-1)
- 📡 GPS + PPS integration via Adafruit GPS Hat
- 🐧 Raspberry Pi OS Lite 64-bit
- 🔧 Rebuild-ready scripts and full config exports
- 📁 Project structure includes tooling, configs, documentation, and original blog source

---

## 🧩 Hardware

- Raspberry Pi 4B
- Adafruit Ultimate GPS Hat ([product](https://www.adafruit.com/product/2324))
- Active GPS antenna ([example](https://a.co/d/8RFh7eL)) with SMA → IPEX adapter
- Pi OS 64-bit Lite + SD card

---

## 🗂️ Repository Structure

```
.
├── images/              # Photos of hardware setup
├── ntp-configs/         # Exported configs and status snapshots
├── scripts/             # Build, export, and validation tools
├── source_blog/         # Original guide reference (katron.org)
├── LICENSE
└── README.md
```

---

## 🚀 Quick Start

To set up from scratch or rebuild an existing config:

```bash
cd scripts/
sudo ./ntp-toolkit.sh
```

You'll be presented with a menu to:
1. Build a new NTP server
2. Restore previously exported configs from `ntp-configs/`
3. Export current live config
4. Run validation tests

---

## 🔁 Restore from Configs

All exported configs and status are located in [`ntp-configs/`](./ntp-configs/):

- `chrony.conf` – NTP server core config  
- `gpsd`, `pps-sources.rules` – GPS/PPS integration  
- `config.txt`, `cmdline.txt` – Pi boot overlays  
- `chronyc` output – time sync & source stability  
- `ntpshmmon`, `gpspipe` – diagnostics & fix status  

Use:
```bash
sudo ./scripts/build.sh --restore ./ntp-configs/
```

---

## 🧪 Run a System Test

To verify GPS lock, PPS detection, and time sync:

```bash
cd scripts/
sudo ./test_gps.sh
```

It checks for:
- PPS device presence
- GPSD and Chrony service status
- GPS fix status via `gpspipe`
- NTP source tracking and stability

---

## 📷 Images

Photos of the build can be found in [`images/`](./images/). A few examples:

- GPS hat mounted to Pi
- Antenna placement
- Terminal output from `chronyc`, `gpsmon`, etc.

---

## 📝 Original Build Guide

This project was inspired by:  
📖 [`katron-rp1-GPS.html`](./source_blog/katron-rp1-GPS.html)

The full referenced files are available in [`source_blog/katron-rp1-GPS_files/`](./source_blog/katron-rp1-GPS_files/)

---

## 📃 License

MIT License – see [`LICENSE`](./LICENSE)

---

⌚ Happy timing from `tick.local`
