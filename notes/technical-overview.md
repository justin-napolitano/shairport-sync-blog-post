---
slug: github-shairport-sync-blog-post-note-technical-overview
id: github-shairport-sync-blog-post-note-technical-overview
title: Shairport-Sync Blog Post
repo: justin-napolitano/shairport-sync-blog-post
githubUrl: https://github.com/justin-napolitano/shairport-sync-blog-post
generatedAt: '2025-11-24T18:46:10.413Z'
source: github-auto
summary: >-
  This repo is all about getting AirPlay audio streaming on Linux ThinkPads with
  the Realtek ALC257 codec, using just ALSA—no PulseAudio or PipeWire needed.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: note
entryLayout: note
showInProjects: false
showInNotes: true
showInWriting: false
showInLogs: false
---

This repo is all about getting AirPlay audio streaming on Linux ThinkPads with the Realtek ALC257 codec, using just ALSA—no PulseAudio or PipeWire needed. 

## Key Components:
- **Shairport-Sync**: Acts as your AirPlay audio receiver.
- **ALSA**: Manages the audio hardware.
- **Avahi**: Handles the mDNS service discovery.

## Quick Start:
1. **Prerequisites**: Ubuntu 24.04+ with kernel 6.8+ on a ThinkPad with the Realtek ALC257 codec.
2. **Install**:
   Run the script:
   ```bash
   ./install.sh
   ```
   Or manually install dependencies and build it:
   ```bash
   sudo apt update
   sudo apt install -y build-essential git ...
   git clone https://github.com/mikebrady/shairport-sync.git
   cd shairport-sync
   autoreconf -fi
   ./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr
   make
   sudo make install
   ```
3. **Configuration**: Edit your `/usr/local/etc/shairport-sync.conf`. Use the provided example settings.

4. **Run**:
   ```bash
   shairport-sync
   ```

Watch for ALSA device recognition quirks on ThinkPads.
