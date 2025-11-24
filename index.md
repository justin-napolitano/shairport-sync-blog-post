---
slug: github-shairport-sync-blog-post
title: Streaming AirPlay Audio on Linux ThinkPad Using ALSA and Shairport-Sync
repo: justin-napolitano/shairport-sync-blog-post
githubUrl: https://github.com/justin-napolitano/shairport-sync-blog-post
generatedAt: '2025-11-23T09:36:15.402391Z'
source: github-auto
summary: >-
  Instructions for enabling AirPlay audio on Linux ThinkPads with Realtek ALC257 codec by bypassing
  PulseAudio and using Shairport-Sync with ALSA.
tags:
  - linux
  - thinkpad
  - alsa
  - shairport-sync
  - airplay
  - audio-streaming
seoPrimaryKeyword: airplay audio linux thinkpad
seoSecondaryKeywords:
  - shairport-sync
  - alsa
  - realtek alc257
  - pulseaudio workaround
seoOptimized: true
topicFamily: devtools
topicFamilyConfidence: 0.95
topicFamilyNotes: >-
  The blog post focuses on Linux audio device setup, ALSA kernel drivers, and building and
  configuring Shairport-Sync on a Linux ThinkPad. These topics align with dev environment setup,
  OS-level configuration, and development tooling covered in the 'Devtools' family. Other families
  like automation or static are less relevant because the post is hardware and OS setup oriented
  rather than about scripting pipelines, automation, or static site creation.
---

---
title: How to Enable AirPlay Audio on Linux (ThinkPad ALC257 + ALSA Only)
date: 2025-10-17
categories: [projects, audio, linux]
tags: [ubuntu, alsa, airplay, thinkpad, shairport-sync]
author: Justin Napolitano
---

# AirPlay Audio on Linux ThinkPad (No PulseAudio, ALSA Only)

This document addresses a specific problem encountered on modern ThinkPads equipped with the Realtek ALC257 audio codec running Ubuntu 24.04 or later with kernel version 6.8 or higher. The issue is that while the ALSA kernel sound subsystem loads correctly, PulseAudio or PipeWire fails to recognize or expose the audio device, rendering it unusable for typical sound applications.

Typical symptoms include the absence of soundcards in ALSA's `aplay` listing and an empty or null sink in PulseAudio:

```
aplay: device_list:274: no soundcards found...
pactl list short sinks
0 auto_null module-null-sink.c s16le 2ch 44100Hz IDLE
```

This project provides a practical workaround by bypassing PulseAudio and PipeWire entirely, instead using Shairport-Sync to stream AirPlay audio directly through ALSA.

## Motivation

The primary motivation is to restore functional AirPlay audio streaming on hardware where the conventional Linux audio stack components fail to expose the sound device properly. This is particularly relevant for ThinkPads with the Realtek ALC257 codec, which is common but problematic under the given software environment.

## Problem Statement

- Kernel-level ALSA drivers load and recognize the codec.
- User-space audio servers (PulseAudio, PipeWire) do not detect or expose the sound hardware.
- Resulting in no usable audio output for typical applications.

## Solution Overview

The solution involves:

1. Verifying kernel-level ALSA device presence.
2. Installing necessary build dependencies.
3. Building Shairport-Sync from source with ALSA, Avahi, and SSL support.
4. Configuring Shairport-Sync to output directly to ALSA.

This approach bypasses the broken PulseAudio/PipeWire layer and leverages ALSA directly for audio playback.

## Implementation Details

### Step 1: Verify Kernel Driver and Codec

Run:

```bash
sudo dmesg | grep -E "snd|sof|hdaudio"
aplay -l
```

Confirm that the output includes the Realtek ALC257 codec identifier and that `/dev/snd/*` devices exist.

### Step 2: Install Dependencies

Install build tools and libraries required for Shairport-Sync:

```bash
sudo apt update
sudo apt install -y build-essential git autoconf automake libtool libdaemon-dev libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev sox
```

### Step 3: Build Shairport-Sync

Clone the official Shairport-Sync repository and build with the necessary options:

```bash
git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync
autoreconf -fi
./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr
make
sudo make install
```

### Step 4: Minimal Configuration

Create a configuration file `/usr/local/etc/shairport-sync.conf` with minimal settings to direct output to ALSA:

```ini
general = { name = "ThinkPad-AirPlay"; mdns_backend = "avahi"; diagnostics = { log_verbosity = 2; }; };
alsa = {
  output_device = "plughw:0,0";
  use_mmap = "no";
  output_format = "S16";
};
```

### Step 5: Run Shairport-Sync

Start the service manually or configure it to run as a daemon:

```bash
shairport-sync
```

## Notes

- This setup circumvents the broken PulseAudio/PipeWire layer but does not address the underlying cause of their failure.
- The configuration disables memory-mapped I/O (`use_mmap = "no"`) which may be necessary for compatibility with the hardware or driver.
- The output device `plughw:0,0` assumes the primary ALSA hardware device; adjust as necessary.

## Conclusion

This project serves as a practical reference for enabling AirPlay audio streaming on Linux ThinkPads with problematic audio stacks. It prioritizes direct ALSA usage and provides a reproducible build and configuration process for Shairport-Sync. Future work may involve diagnosing and fixing PulseAudio/PipeWire integration or expanding hardware support.


