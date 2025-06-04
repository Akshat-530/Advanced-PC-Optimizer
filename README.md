
# Advanced PC Optimizer
**Created by: AKSHAT_530**  

---

## 🚀 Overview

Welcome to **Advanced PC Optimizer**, a powerful PowerShell script designed to enhance your Windows PC's performance! This tool offers a suite of cleanup, maintenance, reporting, and tweaking functions to keep your system running smoothly. From clearing temporary files to toggling system settings, this script is your all-in-one solution for PC optimization.

---

## ✨ Features

### 🧹 Cleanup Tools
- **Advanced Cleanup**: Removes temporary files, prefetch data, and empties the Recycle Bin.
- **System Disk Cleanup**: Runs Windows' built-in `cleanmgr` with preconfigured settings.
- **GPU Shader Cache**: Clears shader caches for NVIDIA, AMD, Intel, and DirectX.
- **DNS Cache & Network Reset**: Flushes DNS and resets network settings.
- **Browser Cache**: Clears cache for Chrome, Edge, and Firefox.

### 🛠️ System Maintenance
- **DISM Health Check**: Repairs system image with `DISM /RestoreHealth`.
- **System File Checker (SFC)**: Scans and fixes corrupted system files.
- **Update Apps & Software**: Updates Windows and installed apps via `winget` and `PSWindowsUpdate`.

### 📊 System Reports
- **Battery Health Report**: Generates and opens a detailed battery report in HTML.
- **System Information**: Launches `msinfo32` for a comprehensive system overview.

### ⚙️ Tweaks & Tools
- **Toggle Shortcut Arrows** (Beta): Removes or restores shortcut arrows on desktop icons.
- **Toggle Windows Telemetry**: Enables or disables telemetry services.
- **Toggle Windows Update**: Turns Windows Update on or off (use with caution).
- **Toggle Right Click Menu UI**: Switches between Windows 10 and 11 context menu styles.
- **Toggle End Task on Taskbar**: Enables or disables the "End Task" option in the taskbar.
- **Toggle Safe or Normal Boot Mode**: Switches between Safe Mode and normal boot.

---

## 🛠️ Usage

1. **How to Run**:
   - Download the script from this repository.
   - Right-click the `START.bat` file and select **Run with as Administrator**.
   - Follow the interactive menu by entering numbers to select options.
   - Confirm actions (Y/N) for potentially disruptive operations.

2. **Warnings**:
   - Close browsers before clearing cache to avoid file access issues.
   - Network reset may disrupt active connections.
   - Disabling Windows Update or telemetry may impact security or features.
   - Restart may be required for some tweaks (e.g., Safe Mode, Explorer changes).


## ⚠️ Disclaimer
- Use this script at your own risk. Some features (e.g., network reset, telemetry, Windows Update toggle) may affect system stability or security.
- Always back up important data before running cleanup or tweaking operations.
- Beta features (e.g., Toggle Shortcut Arrows) may have unexpected behavior.
---

## 🤝 Support
Love this project? Support the developer!  
- **Link:** [https://linktr.ee/Akshat_530](https://linktr.ee/Akshat_530)
---

**Thank you for using Advanced PC Optimizer!**  
Built with ❤️ by AKSHAT_530
