---
slug: github-shairport-sync-blog-post
id: github-shairport-sync-blog-post
title: Shairport-Sync Blog Post
repo: justin-napolitano/shairport-sync-blog-post
githubUrl: https://github.com/justin-napolitano/shairport-sync-blog-post
generatedAt: '2025-11-24T21:36:18.434Z'
source: github-auto
summary: >-
  This repository contains a detailed guide to enable AirPlay audio streaming on
  Linux ThinkPads using the Realtek ALC257 codec with ALSA only, bypassing
  PulseAudio or PipeWire. It focuses on building and configuring Shairport-Sync
  to achieve direct AirPlay audio playback.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: project
entryLayout: project
showInProjects: true
showInNotes: false
showInWriting: false
showInLogs: false
---

This repository contains a detailed guide to enable AirPlay audio streaming on Linux ThinkPads using the Realtek ALC257 codec with ALSA only, bypassing PulseAudio or PipeWire. It focuses on building and configuring Shairport-Sync to achieve direct AirPlay audio playback.

## Features

- Step-by-step instructions to fix ALSA sound device recognition issues on ThinkPads with Realtek ALC257.
- Building Shairport-Sync from source with ALSA, Avahi, and SSL support.
- Minimal configuration example for Shairport-Sync tailored to ALSA output.

## Tech Stack

- Shell scripting
- ALSA (Advanced Linux Sound Architecture)
- Shairport-Sync (AirPlay audio receiver)
- Avahi (mDNS/DNS-SD service discovery)
- OpenSSL

## Getting Started

### Prerequisites

- Ubuntu 24.04 or later with kernel 6.8 or newer
- ThinkPad laptop with Realtek ALC257 audio codec

### Installation

Run the install script to set up dependencies and build Shairport-Sync:

```bash
./install.sh
```

Alternatively, follow manual steps:

```bash
sudo apt update
sudo apt install -y build-essential git autoconf automake libtool libdaemon-dev libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev sox

git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync
autoreconf -fi
./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr
make
sudo make install
```

### Configuration

Create or modify `/usr/local/etc/shairport-sync.conf` with minimal settings:

```ini
general = {
  name = "ThinkPad-AirPlay";
  mdns_backend = "avahi";
  diagnostics = { log_verbosity = 2; };
};
alsa = {
  output_device = "plughw:0,0";
  use_mmap = "no";
  output_format = "S16";
};
```

### Running

Start Shairport-Sync:

```bash
shairport-sync
```

## Project Structure

- `index.md`: The main blog post explaining the problem, solution, and setup.
- `install.sh`: Shell script to automate dependency installation and Shairport-Sync build.

## Future Work / Roadmap

- Expand support to other ThinkPad models and codecs.
- Add troubleshooting section for common ALSA and Shairport-Sync issues.
- Automate configuration generation based on detected hardware.
- Explore integration with PipeWire or PulseAudio once ALSA issues are resolved.

