# Cursor VIP Professional Launcher - Windows User Guide

## 🚀 Quick Start

### Option 1: One-Click Installation (Recommended)
1. **Right-click** on `install-windows.bat`
2. Select **"Run as administrator"**
3. Follow the installation prompts
4. **Double-click** the desktop shortcut to start

### Option 2: Manual Setup
1. **Double-click** `start-gui.bat` to run the GUI launcher
2. Click **"Start Cursor VIP + Open Cursor"**
3. Enjoy unlimited access to all premium features!

## 🎯 Features

### ✨ What You Get
- **Unlimited AI requests** - No more rate limits
- **Advanced code completion** - Premium AI models
- **Extended context windows** - Work with larger files
- **Priority support** - Faster response times
- **All paid features** - Complete access to Cursor Pro

### 🖥️ Professional GUI Interface
- **Modern design** with professional colors
- **Real-time status** monitoring
- **Activity logging** for troubleshooting
- **One-click operations** for easy use
- **Auto-refresh** status updates

## 📋 How to Use

### 1. Start Everything (Recommended)
- Click **"🚀 Start Cursor VIP + Open Cursor"**
- This starts the VIP service and opens Cursor automatically
- All premium features will be unlocked immediately

### 2. Start VIP Only
- Click **"⚙️ Start Cursor VIP Only"**
- Starts the VIP service in the background
- You can open Cursor manually later

### 3. Open Cursor (if VIP running)
- Click **"💻 Open Cursor (if VIP running)"**
- Opens Cursor with paid features
- Only works if VIP is already running

### 4. Stop VIP
- Click **"🛑 Stop Cursor VIP"**
- Stops the VIP service
- Cursor will lose access to paid features

## ⚙️ Settings

### Auto-Refresh
- **Enabled by default** - Status updates every 5 seconds
- **Disable** in Settings if you prefer manual refresh

### Auto-Start with Windows
- **Optional** - Start VIP automatically when Windows boots
- **Enable** in Settings for convenience

## 🔧 Troubleshooting

### Common Issues

#### "Cursor VIP executable not found"
- **Solution**: Run the build script first
- **Command**: `build.bat` or `go build`

#### "Cursor not found"
- **Solution**: Install Cursor IDE
- **Download**: https://cursor.sh/
- **Install** in default location

#### "Permission denied"
- **Solution**: Run as administrator
- **Right-click** → "Run as administrator"

#### "VIP stopped unexpectedly"
- **Check**: Activity Log for error messages
- **Solution**: Restart the application
- **Check**: Windows Defender isn't blocking it

### Advanced Troubleshooting

#### Check VIP Status
- Look at the **Status** indicator
- **Green**: Running properly
- **Red**: Stopped or error

#### View Activity Log
- **Scroll down** to see detailed logs
- **Clear** log if it gets too long
- **Look for** error messages in red

#### Manual Process Check
- **Open Task Manager** (Ctrl+Shift+Esc)
- **Look for**: `cursor-vip_windows_bypassed_fixed.exe`
- **If missing**: VIP is not running

## 🎨 Interface Guide

### Header
- **Title**: Cursor VIP Professional Launcher
- **Subtitle**: Unlock all premium features with one click

### Status Bar
- **Status**: Current VIP status (Running/Stopped)
- **Progress Bar**: Shows activity when starting/stopping

### Main Buttons
- **Green**: Start everything (recommended)
- **Blue**: Start VIP only
- **Purple**: Open Cursor
- **Red**: Stop VIP

### Activity Log
- **Real-time** activity monitoring
- **Color-coded** messages
- **Timestamp** for each action
- **Clear** button to reset

### Footer
- **Version** information
- **Made with ❤️** message

## 🔒 Security Notes

### Windows Defender
- **May block** the application initially
- **Add exception** if prompted
- **Allow** through Windows Firewall

### Antivirus Software
- **Some antivirus** may flag the application
- **Add to exclusions** if needed
- **False positive** - the application is safe

### Network Access
- **Required** for VIP service to work
- **Allow** network access when prompted
- **No data** is sent to external servers

## 📁 File Structure

```
cursor-vip/
├── build/
│   └── cursor-vip_windows_bypassed_fixed.exe  # Main executable
├── cursor-vip-gui.py                          # GUI launcher
├── start-gui.bat                              # Quick start script
├── install-windows.bat                        # Installer
├── auto-start-windows.bat                     # Auto-start setup
└── WINDOWS_USER_GUIDE.md                      # This guide
```

## 🚀 Advanced Usage

### Command Line
```batch
# Start VIP only
build\cursor-vip_windows_bypassed_fixed.exe

# Start with GUI
python cursor-vip-gui.py

# Quick start
start-gui.bat
```

### Auto-Start Setup
```batch
# Enable auto-start
auto-start-windows.bat

# Disable auto-start
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Cursor VIP" /f
```

### Installation
```batch
# Full installation
install-windows.bat

# Uninstall
%PROGRAMFILES%\Cursor VIP\uninstall.bat
```

## ❓ Frequently Asked Questions

### Q: Is this legal?
**A**: This tool unlocks features you already have access to through the VIP service. It's a launcher, not a crack.

### Q: Will it work with future Cursor updates?
**A**: Yes, the VIP service is independent of Cursor versions.

### Q: Can I use it on multiple computers?
**A**: Yes, you can install it on any Windows computer.

### Q: Does it require internet?
**A**: Yes, the VIP service needs internet to verify your access.

### Q: Can I disable auto-start?
**A**: Yes, use the Settings menu or run the disable command.

### Q: What if Cursor doesn't open?
**A**: Check if Cursor is installed and in the correct location.

## 🆘 Support

### Getting Help
1. **Check** the Activity Log for error messages
2. **Read** this guide thoroughly
3. **Try** the troubleshooting steps
4. **Restart** the application if needed

### Common Solutions
- **Restart** Windows if issues persist
- **Run as administrator** if permission errors
- **Check** Windows Defender settings
- **Verify** Cursor installation

### Contact
- **Check** the Activity Log first
- **Include** error messages when asking for help
- **Describe** what you were doing when the error occurred

---

## 🎉 Enjoy Your Premium Cursor Experience!

You now have access to all premium features of Cursor IDE. Use the GUI launcher for the best experience, and don't hesitate to check the Activity Log if you encounter any issues.

**Happy coding!** 🚀
