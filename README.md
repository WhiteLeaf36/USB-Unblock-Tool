# USB-Unblock-Tool

**USB-Unblock-Tool** is a lightweight PowerShell tool designed to solve the frustrating "Problem Ejecting USB Mass Storage Device" error on Windows.

It scans the Windows Event Logs (Kernel-PnP Event ID 225) to identify exactly which process is holding your external drive hostage, allowing you to safely close it or force-kill it.

**中文介绍：** 一个轻量级的 PowerShell 工具，用于解决 Windows 下“无法弹出 USB 存储设备”的问题。它通过读取系统事件日志，精准定位占用设备的进程，并允许你结束该进程。

## ✨ Features / 功能特点

* **No Installation Required:** Pure PowerShell script.
* **Precision Detection:** Uses Windows Event ID 225 to find the exact culprit (PID & Path).
* **Auto-Elevation:** Automatically requests Administrator privileges to access system logs.
* **Process Management:** Displays process details and offers a one-key option to force kill it.

* **无需安装：** 纯 PowerShell 脚本，即下即用。
* **精准检测：** 基于系统底层事件 ID 225，准确找到占用者。
* **自动提权：** 自动获取管理员权限以读取日志。
* **进程管理：** 显示进程路径，支持一键结束进程。

## 🚀 How to Use / 使用方法

1.  **Trigger the Error:** Attempt to eject your USB drive via the system tray first. Wait for Windows to say "This device is currently in use".
    > **Note:** The script relies on this error event to find the process.
    >
    > **步骤 1：** 先尝试在右下角弹出 USB 设备，等待 Windows 提示“设备正在使用中”。(注意：脚本依赖此报错记录来定位进程)

2.  **Run the Script:**
    * Locate the `USB_Blocker_Detector.ps1` file.
    * **Right-click** the file and select **"Run with PowerShell"**.
    * *(Note: Do not just double-click, as it may open in Notepad by default).*
    >
    > **步骤 2：** 找到 `USB_Blocker_Detector.ps1` 文件，**鼠标右键点击**，选择 **“使用 PowerShell 运行”**。(直接双击可能会用记事本打开，所以请使用右键菜单)

3.  **View Results:** The script will show the application name, PID, and file path blocking the device.
    > **步骤 3：** 脚本将显示阻止弹出的程序名称、PID 和文件路径。

4.  **Kill Process (Optional):** Follow the prompt to terminate the process if needed.
    > **步骤 4：** 如果需要，根据提示输入 `Y` 结束该进程。

## ❓ Troubleshooting / 常见问题

**Q: The script closes immediately / Red text appears.**
**A:** This is usually due to Windows Execution Policy. You may need to allow script execution. Open PowerShell as Admin and run:
`Set-ExecutionPolicy RemoteSigned`

**问：脚本一闪而过或出现红字报错？**
**答：** 这通常是因为 Windows 的执行策略限制。请以管理员身份打开 PowerShell 并运行以下命令以允许脚本运行：
`Set-ExecutionPolicy RemoteSigned`

## 🛠️ Requirements / 环境要求

* Windows 10 / Windows 11
* PowerShell 5.1 or later (Built-in on Windows)

## ⚠️ Disclaimer / 免责声明

This tool provides an option to force-kill processes. Please ensure you have saved your data before terminating any application. The author is not responsible for any data loss caused by forcing a process to close.

本工具提供强制结束进程的功能。在结束任何程序之前，请确保已保存数据。作者不对因强制关闭进程导致的数据丢失负责。

---

### 📝 License

MIT License
