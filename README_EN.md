# USB-Unblock-Tool

[中文](README.md) | English

**USB-Unblock-Tool** is a lightweight PowerShell tool designed to solve the frustrating "Problem Ejecting USB Mass Storage Device" error on Windows.

It scans the Windows Event Logs (Kernel-PnP Event ID 225) to identify exactly which process is holding your external drive hostage, allowing you to safely close it or force-kill it.

## ✨ Features

* **No Installation Required:** Pure PowerShell script.
* **Precision Detection:** Uses Windows Event ID 225 to find the exact culprit (PID & Path).
* **Auto-Elevation:** Automatically requests Administrator privileges to access system logs.
* **Process Management:** Displays process details and offers a one-key option to force kill it.

## 🚀 How to Use

1.  **Trigger the Error:** Attempt to eject your USB drive via the system tray first. Wait for Windows to say "This device is currently in use".
    > **Note:** The script relies on this error event to find the process.

2.  **Run the Script:**
    * Locate the `USB_Blocker_Detector.ps1` file.
    * **Right-click** the file and select **"Run with PowerShell"**.
    * *(Note: Do not just double-click, as it may open in Notepad by default).*

3.  **View Results:** The script will show the application name, PID, and file path blocking the device.

4.  **Kill Process (Optional):** Follow the prompt to terminate the process if needed.

## ❓ Troubleshooting

**Q: The script closes immediately / Red text appears.**

**A:** Try opening PowerShell as Admin and running the script manually. Make sure the filename of the script does **not include any special characters or space**.

## 🛠️ Requirements

* Windows 10 / Windows 11
* PowerShell 5.1 or later (Built-in on Windows)

## ⚠️ Disclaimer

This tool provides an option to force-kill processes. Please ensure you have saved your data before terminating any application. The author is not responsible for any data loss caused by forcing a process to close.

---

### 📝 License

MIT License - See [LICENSE](LICENSE) file for details.
