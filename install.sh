#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing dependencies..."
apt update
apt install -y build-essential git autoconf automake libtool libdaemon-dev \
  libpopt-dev libconfig-dev libasound2-dev avahi-daemon \
  libavahi-client-dev libssl-dev sox ufw

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
