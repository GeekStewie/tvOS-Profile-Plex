# Custom Apple Plex Profiles

This repository contains optimized Plex client profiles for **Apple TV 4K / tvOS** and **modern iOS/iPadOS** clients.

The tvOS profile enables:

- **Direct Play of H.264 and HEVC video up to 3840x2160 at 60 fps**
- **HEVC HDR/Dolby Vision, HDR10+, HDR10, and HLG passthrough where Plex reports compatible metadata**
- **Legacy MPEG-4 Simple Profile and Motion JPEG support within Apple TV limits**
- **AAC/HE-AAC, MP3, ALAC, FLAC, AIFF, WAV, AC3 5.1, and EAC3 7.1/Atmos audio support**
- **HEIF, JPEG, GIF, and TIFF photo direct play**

HDMI Quick Media Switching and cinematic aspect-ratio handling are Apple TV display/playback features, not Plex client profile codec rules.

The iOS profile enables:

- **Direct Play of H.264 High Profile and HEVC Main 10 video up to 3840x2160 at 60 fps**
- **MPEG-4 Simple Profile and Motion JPEG support within Apple legacy limits**
- **Apple ProRes direct play for supported Pro devices**
- **AAC/HE-AAC, MP3, ALAC, FLAC, Linear PCM, AC3, and EAC3 audio support**
- **MP4/M4V/MOV/3GP video containers, plus legacy AVI for M-JPEG**
- **MP3/M4A/WAV/AIFF/AU/CAF/FLAC audio containers**
- **HEIF/HEIC, JPEG, PNG, GIF, and TIFF image direct play**

Protected AAC, MV-HEVC spatial video metadata, and Dolby Atmos spatial behavior depend on Apple frameworks, device support, app support, and source DRM. The profile advertises compatible codec/container paths but cannot force DRM playback or device-specific spatial rendering.

This can also resolve issue where Plex reports **"Your connection to the server is not fast enough..."** on connections which are more than fast enough for the content.

---

## 📂 Files

- `tvOS.xml` – Updated Plex profile for Apple TV / tvOS clients.
- `iOS.xml` – Updated Plex profile for iPhone / iPad / iOS clients.
- `install.sh` – Installer that downloads, validates, backs up, installs, and restarts Plex.

---

## ✨ How to Install

Below are platform-specific instructions to replace your current tvOS profile.

---

### 🟢 Linux (Ubuntu / Debian)

#### Install tvOS Profile

Run this on the Plex server:

```bash
curl -fsSL https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/install.sh | sudo bash
```

The installer downloads the latest `tvOS.xml`, locates the current Plex `tvOS.xml`, validates the download, backs up the existing profile, installs the replacement, and restarts Plex Media Server.

To verify the installed tvOS profile:

```bash
grep -nE 'hevc|mpeg4|mjpeg|heif|tiff|flac|alac' /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml
```

#### Install iOS Profile

Run this on the Plex server:

```bash
curl -fsSL https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/install.sh | sudo env PROFILE_NAME=iOS bash
```

The installer downloads the latest `iOS.xml`, locates the current Plex `iOS.xml`, validates the download, backs up the existing profile, installs the replacement, and restarts Plex Media Server.

To verify the installed iOS profile:

```bash
grep -nE 'hevc|mpeg4|mjpeg|prores|heif|tiff|flac|alac|aiff|wav|caf' /usr/lib/plexmediaserver/Resources/Profiles/iOS.xml
```

If Plex is installed in a non-standard location, pass the target path explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/install.sh | sudo env PROFILE_PATH=/path/to/tvOS.xml bash
```

For iOS in a non-standard location:

```bash
curl -fsSL https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/install.sh | sudo env PROFILE_NAME=iOS PROFILE_PATH=/path/to/iOS.xml bash
```

#### Manual Install

1. **Stop Plex Media Server:**

   ```bash
   sudo systemctl stop plexmediaserver
   ```
2. **Backup Original File**
   ```bash
   sudo cp /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml.bak
   ```

3. **Copy New File**
   ```bash
   sudo cp tvOS.xml /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml
   ```
4. **Correct Permissions**
   ```bash
   sudo chmod 644 /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml
   ```
5. **Restart Plex Media Server**
   ```bash
   sudo systemctl start plexmediaserver
   ```
