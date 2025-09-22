#!/usr/bin/env python3
"""
Cursor VIP GUI Launcher
Professional GUI interface for Cursor VIP with paid features
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext, font
import subprocess
import threading
import os
import sys
import time
import psutil
import webbrowser
from datetime import datetime

class CursorVIPGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Cursor VIP Professional Launcher v2.0")
        self.root.geometry("800x600")
        self.root.resizable(True, True)
        self.root.configure(bg='#f0f0f0')
        
        # Set window icon (if available)
        try:
            self.root.iconbitmap('cursor-vip.ico')
        except:
            pass
        
        # Variables
        self.cursor_vip_process = None
        self.cursor_process = None
        self.auto_refresh = True
        
        # Create GUI
        self.create_widgets()
        
        # Check initial status
        self.check_status()
        
        # Start auto-refresh
        self.auto_refresh_status()
    
    def create_widgets(self):
        # Header frame
        header_frame = tk.Frame(self.root, bg='#2c3e50', height=80)
        header_frame.pack(fill="x", padx=0, pady=0)
        header_frame.pack_propagate(False)
        
        # Title
        title_label = tk.Label(
            header_frame, 
            text="Cursor VIP Professional Launcher", 
            font=("Segoe UI", 18, "bold"),
            fg="white",
            bg='#2c3e50'
        )
        title_label.pack(pady=15)
        
        # Subtitle
        subtitle_label = tk.Label(
            header_frame,
            text="Unlock all premium features with one click",
            font=("Segoe UI", 10),
            fg="#bdc3c7",
            bg='#2c3e50'
        )
        subtitle_label.pack()
        
        # Main content frame
        main_frame = tk.Frame(self.root, bg='#f0f0f0')
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Status frame
        status_frame = tk.Frame(main_frame, bg='#ecf0f1', relief='raised', bd=1)
        status_frame.pack(fill="x", pady=(0, 20))
        
        status_inner = tk.Frame(status_frame, bg='#ecf0f1')
        status_inner.pack(fill="x", padx=15, pady=10)
        
        tk.Label(status_inner, text="Status:", font=("Segoe UI", 11, "bold"), bg='#ecf0f1').pack(side="left")
        self.status_label = tk.Label(status_inner, text="Checking...", fg="orange", font=("Segoe UI", 11), bg='#ecf0f1')
        self.status_label.pack(side="left", padx=(10, 0))
        
        # Progress bar
        self.progress = ttk.Progressbar(status_inner, mode='indeterminate')
        self.progress.pack(side="right", padx=(10, 0))
        
        # Buttons frame
        buttons_frame = tk.Frame(main_frame, bg='#f0f0f0')
        buttons_frame.pack(fill="x", pady=(0, 20))
        
        # Create button style
        button_style = {
            'font': ("Segoe UI", 11, "bold"),
            'height': 2,
            'relief': 'raised',
            'bd': 2,
            'cursor': 'hand2'
        }
        
        # Start VIP + Cursor button
        self.start_all_btn = tk.Button(
            buttons_frame,
            text="🚀 Start Cursor VIP + Open Cursor",
            command=self.start_all,
            bg="#27ae60",
            fg="white",
            activebackground="#2ecc71",
            **button_style
        )
        self.start_all_btn.pack(fill="x", pady=5)
        
        # Start VIP only button
        self.start_vip_btn = tk.Button(
            buttons_frame,
            text="⚙️ Start Cursor VIP Only",
            command=self.start_vip_only,
            bg="#3498db",
            fg="white",
            activebackground="#5dade2",
            **button_style
        )
        self.start_vip_btn.pack(fill="x", pady=5)
        
        # Open Cursor button
        self.open_cursor_btn = tk.Button(
            buttons_frame,
            text="💻 Open Cursor (if VIP running)",
            command=self.open_cursor,
            bg="#9b59b6",
            fg="white",
            activebackground="#bb8fce",
            **button_style
        )
        self.open_cursor_btn.pack(fill="x", pady=5)
        
        # Stop VIP button
        self.stop_vip_btn = tk.Button(
            buttons_frame,
            text="🛑 Stop Cursor VIP",
            command=self.stop_vip,
            bg="#e74c3c",
            fg="white",
            activebackground="#ec7063",
            **button_style
        )
        self.stop_vip_btn.pack(fill="x", pady=5)
        
        # Additional buttons frame
        extra_frame = tk.Frame(main_frame, bg='#f0f0f0')
        extra_frame.pack(fill="x", pady=(0, 20))
        
        # Settings button
        settings_btn = tk.Button(
            extra_frame,
            text="⚙️ Settings",
            command=self.open_settings,
            bg="#95a5a6",
            fg="white",
            font=("Segoe UI", 10),
            height=1,
            cursor='hand2'
        )
        settings_btn.pack(side="left", padx=(0, 10))
        
        # Help button
        help_btn = tk.Button(
            extra_frame,
            text="❓ Help",
            command=self.open_help,
            bg="#95a5a6",
            fg="white",
            font=("Segoe UI", 10),
            height=1,
            cursor='hand2'
        )
        help_btn.pack(side="left", padx=(0, 10))
        
        # About button
        about_btn = tk.Button(
            extra_frame,
            text="ℹ️ About",
            command=self.open_about,
            bg="#95a5a6",
            fg="white",
            font=("Segoe UI", 10),
            height=1,
            cursor='hand2'
        )
        about_btn.pack(side="left")
        
        # Log frame
        log_frame = tk.Frame(main_frame, bg='#f0f0f0')
        log_frame.pack(fill="both", expand=True)
        
        log_header = tk.Frame(log_frame, bg='#34495e', height=30)
        log_header.pack(fill="x")
        log_header.pack_propagate(False)
        
        tk.Label(log_header, text="Activity Log", font=("Segoe UI", 10, "bold"), fg="white", bg='#34495e').pack(side="left", padx=10, pady=5)
        
        # Clear log button
        clear_btn = tk.Button(
            log_header,
            text="Clear",
            command=self.clear_log,
            bg="#e67e22",
            fg="white",
            font=("Segoe UI", 8),
            height=1,
            cursor='hand2'
        )
        clear_btn.pack(side="right", padx=10, pady=5)
        
        self.log_text = scrolledtext.ScrolledText(
            log_frame,
            height=8,
            font=("Consolas", 9),
            bg='#2c3e50',
            fg='#ecf0f1',
            insertbackground='white',
            selectbackground='#3498db'
        )
        self.log_text.pack(fill="both", expand=True)
        
        # Footer
        footer_frame = tk.Frame(self.root, bg='#34495e', height=30)
        footer_frame.pack(fill="x", side="bottom")
        footer_frame.pack_propagate(False)
        
        tk.Label(
            footer_frame,
            text="Cursor VIP Professional Launcher v2.0 | Made with ❤️",
            font=("Segoe UI", 8),
            fg="#bdc3c7",
            bg='#34495e'
        ).pack(pady=5)
    
    def log(self, message):
        """Add message to log"""
        timestamp = time.strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{timestamp}] {message}\n")
        self.log_text.see(tk.END)
        self.root.update()
    
    def check_status(self):
        """Check if Cursor VIP is running"""
        try:
            for proc in psutil.process_iter(['pid', 'name']):
                if 'cursor-vip_windows_bypassed_fixed.exe' in proc.info['name']:
                    return True
            return False
        except:
            return False
    
    def refresh_status(self):
        """Refresh status display"""
        if self.check_status():
            self.status_label.config(text="Cursor VIP: Running", fg="green")
            self.progress.stop()
        else:
            self.status_label.config(text="Cursor VIP: Stopped", fg="red")
            self.progress.stop()
        
        # Schedule next refresh
        if self.auto_refresh:
            self.root.after(5000, self.refresh_status)
    
    def auto_refresh_status(self):
        """Start auto-refresh status"""
        self.progress.start()
        self.refresh_status()
    
    def clear_log(self):
        """Clear the log"""
        self.log_text.delete(1.0, tk.END)
        self.log("Log cleared")
    
    def open_settings(self):
        """Open settings window"""
        settings_window = tk.Toplevel(self.root)
        settings_window.title("Settings")
        settings_window.geometry("400x300")
        settings_window.resizable(False, False)
        settings_window.configure(bg='#f0f0f0')
        
        # Center the window
        settings_window.transient(self.root)
        settings_window.grab_set()
        
        # Settings content
        tk.Label(settings_window, text="Settings", font=("Segoe UI", 16, "bold"), bg='#f0f0f0').pack(pady=20)
        
        # Auto-refresh setting
        auto_refresh_var = tk.BooleanVar(value=self.auto_refresh)
        auto_refresh_check = tk.Checkbutton(
            settings_window,
            text="Auto-refresh status every 5 seconds",
            variable=auto_refresh_var,
            command=lambda: setattr(self, 'auto_refresh', auto_refresh_var.get()),
            bg='#f0f0f0',
            font=("Segoe UI", 10)
        )
        auto_refresh_check.pack(pady=10, padx=20, anchor="w")
        
        # Auto-start setting
        auto_start_var = tk.BooleanVar()
        auto_start_check = tk.Checkbutton(
            settings_window,
            text="Start Cursor VIP automatically on Windows startup",
            variable=auto_start_var,
            bg='#f0f0f0',
            font=("Segoe UI", 10)
        )
        auto_start_check.pack(pady=10, padx=20, anchor="w")
        
        # Close button
        tk.Button(
            settings_window,
            text="Close",
            command=settings_window.destroy,
            bg="#3498db",
            fg="white",
            font=("Segoe UI", 10),
            height=1
        ).pack(pady=20)
    
    def open_help(self):
        """Open help window"""
        help_window = tk.Toplevel(self.root)
        help_window.title("Help")
        help_window.geometry("600x500")
        help_window.resizable(True, True)
        help_window.configure(bg='#f0f0f0')
        
        # Center the window
        help_window.transient(self.root)
        help_window.grab_set()
        
        # Help content
        help_text = scrolledtext.ScrolledText(
            help_window,
            font=("Segoe UI", 10),
            bg='#f0f0f0',
            wrap=tk.WORD
        )
        help_text.pack(fill="both", expand=True, padx=20, pady=20)
        
        help_content = """
Cursor VIP Professional Launcher - Help

OVERVIEW:
This launcher helps you unlock all premium features of Cursor IDE by running the Cursor VIP service in the background.

HOW TO USE:

1. START CURSOR VIP + OPEN CURSOR (Recommended):
   - Starts the Cursor VIP service
   - Automatically opens Cursor with paid features enabled
   - This is the easiest way to get started

2. START CURSOR VIP ONLY:
   - Starts only the Cursor VIP service
   - You can manually open Cursor later
   - Useful if you want to control when Cursor opens

3. OPEN CURSOR (if VIP running):
   - Opens Cursor with paid features
   - Only works if Cursor VIP is already running
   - Use this if you closed Cursor but VIP is still running

4. STOP CURSOR VIP:
   - Stops the Cursor VIP service
   - Cursor will lose access to paid features
   - Use this to completely stop the service

FEATURES UNLOCKED:
- Unlimited AI requests
- Advanced code completion
- Premium AI models
- Extended context windows
- Priority support
- All paid features

TROUBLESHOOTING:
- If Cursor doesn't open: Check if Cursor is installed
- If VIP doesn't start: Check if the executable exists
- If features don't work: Make sure VIP is running
- Check the Activity Log for detailed information

SUPPORT:
- Check the Activity Log for error messages
- Make sure Cursor is properly installed
- Ensure Windows Defender isn't blocking the application

For more help, check the README file or contact support.
        """
        
        help_text.insert(1.0, help_content)
        help_text.config(state=tk.DISABLED)
        
        # Close button
        tk.Button(
            help_window,
            text="Close",
            command=help_window.destroy,
            bg="#3498db",
            fg="white",
            font=("Segoe UI", 10),
            height=1
        ).pack(pady=10)
    
    def open_about(self):
        """Open about window"""
        about_window = tk.Toplevel(self.root)
        about_window.title("About")
        about_window.geometry("400x300")
        about_window.resizable(False, False)
        about_window.configure(bg='#f0f0f0')
        
        # Center the window
        about_window.transient(self.root)
        about_window.grab_set()
        
        # About content
        tk.Label(about_window, text="Cursor VIP Professional Launcher", font=("Segoe UI", 16, "bold"), bg='#f0f0f0').pack(pady=20)
        tk.Label(about_window, text="Version 2.0", font=("Segoe UI", 12), bg='#f0f0f0').pack(pady=5)
        
        about_text = """
A professional launcher for Cursor VIP that unlocks all premium features of Cursor IDE.

Features:
• One-click activation
• Professional GUI interface
• Auto-refresh status
• Activity logging
• Easy to use

This tool helps developers access all premium features of Cursor IDE without any restrictions.

Made with ❤️ for the developer community
        """
        
        tk.Label(about_window, text=about_text, font=("Segoe UI", 10), bg='#f0f0f0', justify=tk.LEFT).pack(pady=20, padx=20)
        
        # Close button
        tk.Button(
            about_window,
            text="Close",
            command=about_window.destroy,
            bg="#3498db",
            fg="white",
            font=("Segoe UI", 10),
            height=1
        ).pack(pady=10)
    
    def start_all(self):
        """Start Cursor VIP and open Cursor"""
        def run():
            self.log("🚀 Starting Cursor VIP + Opening Cursor...")
            self.progress.start()
            
            # Start Cursor VIP
            try:
                self.cursor_vip_process = subprocess.Popen(
                    ["build\\cursor-vip_windows_bypassed_fixed.exe"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                self.log("✅ Cursor VIP started successfully")
                self.log("⏳ Waiting for initialization...")
                time.sleep(5)  # Wait for initialization
                
                # Check if VIP is still running
                if self.check_status():
                    self.log("✅ Cursor VIP is running properly")
                    # Open Cursor
                    self.open_cursor()
                    self.log("🎉 Setup complete! Cursor is running with paid features.")
                    self.log("💎 All premium features are now unlocked!")
                else:
                    self.log("❌ Cursor VIP stopped unexpectedly")
                    messagebox.showerror("Error", "Cursor VIP stopped unexpectedly. Check the log for details.")
                
            except Exception as e:
                self.log(f"❌ Error starting Cursor VIP: {str(e)}")
                messagebox.showerror("Error", f"Failed to start Cursor VIP:\n{str(e)}")
            finally:
                self.progress.stop()
        
        threading.Thread(target=run, daemon=True).start()
    
    def start_vip_only(self):
        """Start Cursor VIP only"""
        def run():
            self.log("⚙️ Starting Cursor VIP only...")
            self.progress.start()
            
            try:
                self.cursor_vip_process = subprocess.Popen(
                    ["build\\cursor-vip_windows_bypassed_fixed.exe"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                self.log("✅ Cursor VIP started successfully")
                self.log("⏳ Waiting for initialization...")
                time.sleep(3)
                
                if self.check_status():
                    self.log("✅ Cursor VIP is running properly")
                    self.log("💡 You can now open Cursor manually")
                    messagebox.showinfo("Success", "Cursor VIP started successfully!\nYou can now open Cursor manually.")
                else:
                    self.log("❌ Cursor VIP stopped unexpectedly")
                    messagebox.showerror("Error", "Cursor VIP stopped unexpectedly. Check the log for details.")
                
            except Exception as e:
                self.log(f"❌ Error starting Cursor VIP: {str(e)}")
                messagebox.showerror("Error", f"Failed to start Cursor VIP:\n{str(e)}")
            finally:
                self.progress.stop()
        
        threading.Thread(target=run, daemon=True).start()
    
    def open_cursor(self):
        """Open Cursor with paid features"""
        self.log("💻 Opening Cursor with paid features...")
        
        # Check if Cursor VIP is running
        if not self.check_status():
            self.log("⚠️ Warning: Cursor VIP is not running")
            messagebox.showwarning("Warning", "Cursor VIP is not running. Please start it first.")
            return
        
        # Find Cursor executable
        cursor_paths = [
            "cursor",  # In PATH
            os.path.expanduser("~\\AppData\\Local\\Programs\\cursor\\Cursor.exe"),
            "C:\\Program Files\\Cursor\\Cursor.exe",
            "C:\\Program Files (x86)\\Cursor\\Cursor.exe",
            ".\\cursor.exe"
        ]
        
        cursor_found = False
        cursor_path_used = ""
        
        for path in cursor_paths:
            try:
                if path == "cursor":
                    # Check if cursor is in PATH
                    subprocess.run(["where", "cursor"], check=True, capture_output=True)
                    subprocess.Popen(["cursor", "--enable-paid-features"])
                    cursor_found = True
                    cursor_path_used = "PATH"
                    break
                elif os.path.exists(path):
                    subprocess.Popen([path, "--enable-paid-features"])
                    cursor_found = True
                    cursor_path_used = path
                    break
            except:
                continue
        
        if cursor_found:
            self.log(f"✅ Cursor found at: {cursor_path_used}")
            self.log("🎉 Cursor opened with paid features enabled!")
            self.log("💎 All premium features are now available!")
            self.log("🚀 You can now use unlimited AI requests and advanced features!")
        else:
            self.log("❌ Error: Cursor not found. Please install Cursor first.")
            self.log("📥 Download from: https://cursor.sh/")
            messagebox.showerror("Error", "Cursor not found. Please install Cursor first.\nDownload from: https://cursor.sh/")
    
    def stop_vip(self):
        """Stop Cursor VIP"""
        self.log("🛑 Stopping Cursor VIP...")
        
        try:
            # Kill all cursor-vip processes
            killed_count = 0
            for proc in psutil.process_iter(['pid', 'name']):
                if 'cursor-vip_windows_bypassed_fixed.exe' in proc.info['name']:
                    proc.kill()
                    self.log(f"✅ Killed process {proc.info['pid']}")
                    killed_count += 1
            
            if killed_count > 0:
                self.log(f"✅ Cursor VIP stopped successfully ({killed_count} processes)")
                self.log("⚠️ Cursor will lose access to paid features")
                messagebox.showinfo("Success", f"Cursor VIP stopped successfully!\n{killed_count} processes terminated.")
            else:
                self.log("ℹ️ No Cursor VIP processes were running")
                messagebox.showinfo("Info", "No Cursor VIP processes were running.")
            
        except Exception as e:
            self.log(f"❌ Error stopping Cursor VIP: {str(e)}")
            messagebox.showerror("Error", f"Failed to stop Cursor VIP:\n{str(e)}")

def main():
    # Check if required files exist
    if not os.path.exists("build\\cursor-vip_windows_bypassed_fixed.exe"):
        messagebox.showerror("Error", "Cursor VIP executable not found!\nPlease run the build script first.")
        return
    
    # Create and run GUI
    root = tk.Tk()
    app = CursorVIPGUI(root)
    
    # Center window
    root.update_idletasks()
    x = (root.winfo_screenwidth() // 2) - (600 // 2)
    y = (root.winfo_screenheight() // 2) - (500 // 2)
    root.geometry(f"600x500+{x}+{y}")
    
    root.mainloop()

if __name__ == "__main__":
    main()
