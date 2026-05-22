# Custom tvOS Plex Profile for Apple TV 4K

This repository contains an optimized `tvOS.xml` Plex profile for **Apple TV 4K / tvOS Plex clients**.
It enables:

- **Direct Play of H.264 and HEVC video up to 3840x2160 at 60 fps**
- **HEVC HDR/Dolby Vision, HDR10+, HDR10, and HLG passthrough where Plex reports compatible metadata**
- **Legacy MPEG-4 Simple Profile and Motion JPEG support within Apple TV limits**
- **AAC/HE-AAC, MP3, ALAC, FLAC, AIFF, WAV, AC3 5.1, and EAC3 7.1/Atmos audio support**
- **HEIF, JPEG, GIF, and TIFF photo direct play**

HDMI Quick Media Switching and cinematic aspect-ratio handling are Apple TV display/playback features, not Plex client profile codec rules.

This can also resolve issue where Plex reports **"Your connection to the server is not fast enough..."** on connections which are more than fast enough for the content.

---

## 📂 File

- `tvOS.xml` – The updated Plex client profile.

---

## ✨ How to Install

Below are platform-specific instructions to replace your current tvOS profile.

---

### 🟢 Linux (Ubuntu / Debian)

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
