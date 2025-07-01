# Custom tvOS Plex Profile for Apple TV 4K

This repository contains an optimized `tvOS.xml` Plex profile for the **first-generation Apple TV 4K**.  
It enables:

- **Direct Play of 4K H.264 and HEVC video**
- **Support for 5.1 AAC, AC3, and EAC3 audio**
- **Higher resolution limits (up to 3840x2160)**

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
   sudo systemctl stop plexmediaserver```
2. **Backup Original File**
  ```sudo cp /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml.bak```

3. **Copy New File**
   ```sudo cp tvOS.xml /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml```
4. **Correct Permissions**
   ```sudo chmod 644 /usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml```
5. **Restart Plex Media Server**
   ```sudo systemctl start plexmediaserver```
