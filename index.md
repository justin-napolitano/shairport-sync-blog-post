+++
title = "How to Enable AirPlay Audio on Linux (ThinkPad ALC257 + ALSA Only)"
date = "2025-10-17T14:25:13-05:00"
description = "Fixing broken PulseAudio on ThinkPads with Realtek ALC257 and setting up direct AirPlay via Shairport-Sync using ALSA only."
author = "Justin Napolitano"
categories = ["projects", "audio", "linux"]
tags = ["ubuntu", "alsa", "airplay", "thinkpad", "shairport-sync"]
#image = "airplay-thinkpad.png"
[extra]
lang = "en"
toc = true
featured = false
reaction = false
+++

# AirPlay Audio on Linux ThinkPad (No PulseAudio, ALSA Only)

Most modern ThinkPads use the **Realtek ALC257** codec. On Ubuntu 24.04+ (kernel ≥ 6.8), the sound subsystem often loads but PulseAudio or PipeWire fails to expose it, leading to:

```
aplay: device_list:274: no soundcards found...
pactl list short sinks
0 auto_null module-null-sink.c s16le 2ch 44100Hz IDLE
```

This guide fixes that and sets up **Shairport-Sync** to stream AirPlay audio directly through ALSA.

---

## Step 1 – Verify Kernel Driver and Codec
```bash
sudo dmesg | grep -E "snd|sof|hdaudio"
aplay -l
```

Expect output similar to:
```
HDA:10ec0257,17aa2279,00100001
```

If `/dev/snd/*` exists, ALSA is working at the kernel level.

---

## Step 2 – Install Dependencies
```bash
sudo apt update
sudo apt install -y build-essential git autoconf automake libtool   libdaemon-dev libpopt-dev libconfig-dev libasound2-dev avahi-daemon   libavahi-client-dev libssl-dev sox
```

---

## Step 3 – Build Shairport-Sync from Source
```bash
git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync
autoreconf -fi
./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr
make
sudo make install
```

---

## Step 4 – Minimal Config
```bash
sudo tee /usr/local/etc/shairport-sync.conf >/dev/null <<'EOF'
general = { name = "ThinkPad-AirPlay"; mdns_backend = "avahi"; diagnostics = { log_verbosity = 2; }; };
alsa = {
  output_device = "plughw:0,0";
  use_mmap = "no";
  output_format = "S16";
  output_rate = 44100;
};
EOF
```

---

## Step 5 – Unmute and Test ALSA
```bash
amixer -c 0 sset 'Headphone' 100% unmute
amixer -c 0 sset 'Auto-Mute Mode' Disabled
aplay /usr/share/sounds/alsa/Front_Center.wav
```

If you hear “Front Center,” the codec works.

---

## Step 6 – Firewall and Avahi
```bash
sudo ufw allow 5000,6001:6010,7000/tcp
sudo ufw allow 5353,6001:6010/udp
sudo systemctl enable --now avahi-daemon
```

---

## Step 7 – Systemd Service
```bash
sudo tee /etc/systemd/system/shairport-sync.service >/dev/null <<'EOF'
[Unit]
Description=Shairport Sync AirPlay Receiver
After=network-online.target sound.target avahi-daemon.service
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/shairport-sync -o alsa -- -d plughw:0,0
Restart=always
User=shairport
Group=audio

[Install]
WantedBy=multi-user.target
EOF

sudo useradd -r -s /usr/sbin/nologin -G audio shairport || true
sudo systemctl daemon-reload
sudo systemctl enable --now shairport-sync
```

---

## Step 8 – Verification
```bash
sudo journalctl -u shairport-sync -f
```
Look for:
```
Connection 1: ANNOUNCE
Connection 1: RECORD
alsa: PCM start
```
Your ThinkPad now appears as **“ThinkPad-AirPlay”** on iOS/macOS devices.

---

## Full Install Script

Save as `install_airplay_thinkpad.sh` and run with:

```bash
sudo bash install_airplay_thinkpad.sh
```

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing dependencies..."
apt update
apt install -y build-essential git autoconf automake libtool libdaemon-dev   libpopt-dev libconfig-dev libasound2-dev avahi-daemon   libavahi-client-dev libssl-dev sox ufw

echo "[+] Cloning Shairport Sync..."
cd /tmp
git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync
autoreconf -fi
./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr
make
make install

echo "[+] Creating config..."
tee /usr/local/etc/shairport-sync.conf >/dev/null <<'EOF'
general = { name = "ThinkPad-AirPlay"; mdns_backend = "avahi"; diagnostics = { log_verbosity = 2; }; };
alsa = { output_device = "plughw:0,0"; use_mmap = "no"; output_format = "S16"; output_rate = 44100; };
EOF

echo "[+] Adjusting audio mixer..."
amixer -c 0 sset 'Headphone' 100% unmute || true
amixer -c 0 sset 'Auto-Mute Mode' Disabled || true

echo "[+] Opening firewall..."
ufw allow 5000,6001:6010,7000/tcp
ufw allow 5353,6001:6010/udp
ufw reload

echo "[+] Creating systemd service..."
tee /etc/systemd/system/shairport-sync.service >/dev/null <<'EOF'
[Unit]
Description=Shairport Sync AirPlay Receiver
After=network-online.target sound.target avahi-daemon.service
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/shairport-sync -o alsa -- -d plughw:0,0
Restart=always
User=shairport
Group=audio

[Install]
WantedBy=multi-user.target
EOF

useradd -r -s /usr/sbin/nologin -G audio shairport 2>/dev/null || true
systemctl daemon-reload
systemctl enable --now shairport-sync

echo "[+] Done. Your AirPlay receiver is ready as 'ThinkPad-AirPlay'."
```

---

## Result
You now have a completely PulseAudio-free, AirPlay-enabled ThinkPad using only **ALSA + Avahi + Shairport-Sync**.  
Lightweight, fast, and scriptable.
