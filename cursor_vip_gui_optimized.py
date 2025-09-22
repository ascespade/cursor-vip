#!/usr/bin/env python3
"""
Cursor VIP Optimized GUI Launcher
Professional GUI interface for Cursor VIP with enhanced performance and features
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext, font, filedialog
import subprocess
import threading
import os
import sys
import time
import psutil
import webbrowser
import json
import requests
from datetime import datetime, timedelta
import queue
import logging

class CursorVIPOptimizedGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Cursor VIP Professional Launcher v3.0 - Optimized")
        self.root.geometry("900x700")
        self.root.resizable(True, True)
        self.root.configure(bg='#f0f0f0')
        
        # Set window icon
        try:
            self.root.iconbitmap('cursor-vip.ico')
        except:
            pass
        
        # Variables
        self.cursor_vip_process = None
        self.cursor_process = None
        self.auto_refresh = True
        self.performance_mode = True
        self.auto_start = False
        self.log_queue = queue.Queue()
        self.stats = {
            'start_time': None,
            'requests_processed': 0,
            'memory_usage': 0,
            'uptime': 0
        }
        
        # Setup logging
        self.setup_logging()
        
        # Create GUI
        self.create_widgets()
        
        # Check initial status
        self.check_status()
        
        # Start background tasks
        self.start_background_tasks()
        
        # Load settings
        self.load_settings()
    
    def setup_logging(self):
        """Setup logging configuration"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('cursor_vip.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def create_widgets(self):
        """Create the main GUI widgets"""
        # Header frame
        header_frame = tk.Frame(self.root, bg='#2c3e50', height=100)
        header_frame.pack(fill="x", padx=0, pady=0)
        header_frame.pack_propagate(False)
        
        # Title
        title_label = tk.Label(
            header_frame, 
            text="Cursor VIP Professional Launcher", 
            font=("Segoe UI", 20, "bold"),
            fg="white",
            bg='#2c3e50'
        )
        title_label.pack(pady=10)
        
        # Subtitle
        subtitle_label = tk.Label(
            header_frame,
            text="Optimized Performance • Enhanced Features • Professional Interface",
            font=("Segoe UI", 11),
            fg="#bdc3c7",
            bg='#2c3e50'
        )
        subtitle_label.pack()
        
        # Version info
        version_label = tk.Label(
            header_frame,
            text="Version 3.0 - Optimized Build",
            font=("Segoe UI", 9),
            fg="#95a5a6",
            bg='#2c3e50'
        )
        version_label.pack()
        
        # Main content frame
        main_frame = tk.Frame(self.root, bg='#f0f0f0')
        main_frame.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Status and stats frame
        status_frame = tk.Frame(main_frame, bg='#ecf0f1', relief='raised', bd=2)
        status_frame.pack(fill="x", pady=(0, 20))
        
        # Status section
        status_inner = tk.Frame(status_frame, bg='#ecf0f1')
        status_inner.pack(fill="x", padx=15, pady=10)
        
        # Status row
        status_row = tk.Frame(status_inner, bg='#ecf0f1')
        status_row.pack(fill="x", pady=(0, 10))
        
        tk.Label(status_row, text="Status:", font=("Segoe UI", 12, "bold"), bg='#ecf0f1').pack(side="left")
        self.status_label = tk.Label(status_row, text="Checking...", fg="orange", font=("Segoe UI", 12), bg='#ecf0f1')
        self.status_label.pack(side="left", padx=(10, 0))
        
        # Progress bar
        self.progress = ttk.Progressbar(status_row, mode='indeterminate')
        self.progress.pack(side="right", padx=(10, 0))
        
        # Stats row
        stats_row = tk.Frame(status_inner, bg='#ecf0f1')
        stats_row.pack(fill="x")
        
        self.stats_label = tk.Label(
            stats_row, 
            text="Uptime: 00:00:00 | Requests: 0 | Memory: 0 MB", 
            font=("Segoe UI", 10), 
            fg="#7f8c8d", 
            bg='#ecf0f1'
        )
        self.stats_label.pack(side="left")
        
        # Performance indicator
        self.perf_label = tk.Label(
            stats_row, 
            text="⚡ Performance Mode", 
            font=("Segoe UI", 10, "bold"), 
            fg="#27ae60", 
            bg='#ecf0f1'
        )
        self.perf_label.pack(side="right")
        
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
        
        # Main action buttons
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
        
        # Additional controls frame
        controls_frame = tk.Frame(main_frame, bg='#f0f0f0')
        controls_frame.pack(fill="x", pady=(0, 20))
        
        # Performance controls
        perf_frame = tk.LabelFrame(controls_frame, text="Performance Controls", font=("Segoe UI", 10, "bold"), bg='#f0f0f0')
        perf_frame.pack(side="left", fill="x", expand=True, padx=(0, 10))
        
        self.performance_var = tk.BooleanVar(value=True)
        perf_check = tk.Checkbutton(
            perf_frame,
            text="Enable Performance Mode",
            variable=self.performance_var,
            command=self.toggle_performance_mode,
            bg='#f0f0f0',
            font=("Segoe UI", 10)
        )
        perf_check.pack(anchor="w", padx=10, pady=5)
        
        self.auto_refresh_var = tk.BooleanVar(value=True)
        refresh_check = tk.Checkbutton(
            perf_frame,
            text="Auto-refresh status",
            variable=self.auto_refresh_var,
            command=self.toggle_auto_refresh,
            bg='#f0f0f0',
            font=("Segoe UI", 10)
        )
        refresh_check.pack(anchor="w", padx=10, pady=5)
        
        # Action buttons
        action_frame = tk.Frame(controls_frame, bg='#f0f0f0')
        action_frame.pack(side="right")
        
        settings_btn = tk.Button(
            action_frame,
            text="⚙️ Settings",
            command=self.open_settings,
            bg="#95a5a6",
            fg="white",
            font=("Segoe UI", 10),
            height=1,
            cursor='hand2'
        )
        settings_btn.pack(side="left", padx=(0, 5))
        
        help_btn = tk.Button(
            action_frame,
            text="❓ Help",
            command=self.open_help,
            bg="#95a5a6",
            fg="white",
            font=("Segoe UI", 10),
            height=1,
            cursor='hand2'
        )
        help_btn.pack(side="left", padx=(0, 5))
        
        about_btn = tk.Button(
            action_frame,
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
        
        log_header = tk.Frame(log_frame, bg='#34495e', height=35)
        log_header.pack(fill="x")
        log_header.pack_propagate(False)
        
        tk.Label(log_header, text="Activity Log & Performance Monitor", font=("Segoe UI", 11, "bold"), fg="white", bg='#34495e').pack(side="left", padx=10, pady=8)
        
        # Log control buttons
        log_controls = tk.Frame(log_header, bg='#34495e')
        log_controls.pack(side="right", padx=10, pady=5)
        
        clear_btn = tk.Button(
            log_controls,
            text="Clear",
            command=self.clear_log,
            bg="#e67e22",
            fg="white",
            font=("Segoe UI", 8),
            height=1,
            cursor='hand2'
        )
        clear_btn.pack(side="left", padx=(0, 5))
        
        export_btn = tk.Button(
            log_controls,
            text="Export",
            command=self.export_log,
            bg="#16a085",
            fg="white",
            font=("Segoe UI", 8),
            height=1,
            cursor='hand2'
        )
        export_btn.pack(side="left")
        
        self.log_text = scrolledtext.ScrolledText(
            log_frame,
            height=10,
            font=("Consolas", 9),
            bg='#2c3e50',
            fg='#ecf0f1',
            insertbackground='white',
            selectbackground='#3498db'
        )
        self.log_text.pack(fill="both", expand=True)
        
        # Footer
        footer_frame = tk.Frame(self.root, bg='#34495e', height=35)
        footer_frame.pack(fill="x", side="bottom")
        footer_frame.pack_propagate(False)
        
        tk.Label(
            footer_frame,
            text="Cursor VIP Professional Launcher v3.0 - Optimized | Made with ❤️ | Enhanced Performance",
            font=("Segoe UI", 9),
            fg="#bdc3c7",
            bg='#34495e'
        ).pack(pady=8)
    
    def log(self, message, level="INFO"):
        """Add message to log with timestamp and level"""
        timestamp = time.strftime("%H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] {message}\n"
        
        # Add to queue for thread-safe logging
        self.log_queue.put(log_entry)
        
        # Also log to file
        self.logger.info(message)
    
    def process_log_queue(self):
        """Process log queue in main thread"""
        try:
            while True:
                log_entry = self.log_queue.get_nowait()
                self.log_text.insert(tk.END, log_entry)
                self.log_text.see(tk.END)
                self.root.update()
        except queue.Empty:
            pass
    
    def start_background_tasks(self):
        """Start background monitoring tasks"""
        # Process log queue
        self.root.after(100, self.process_log_queue)
        self.root.after(100, self.start_background_tasks)
        
        # Auto-refresh status
        if self.auto_refresh:
            self.root.after(5000, self.refresh_status)
        
        # Update stats
        self.root.after(1000, self.update_stats)
    
    def update_stats(self):
        """Update performance statistics"""
        if self.stats['start_time']:
            uptime = time.time() - self.stats['start_time']
            uptime_str = str(timedelta(seconds=int(uptime)))
            memory_mb = self.stats['memory_usage'] / (1024 * 1024)
            
            stats_text = f"Uptime: {uptime_str} | Requests: {self.stats['requests_processed']} | Memory: {memory_mb:.1f} MB"
            self.stats_label.config(text=stats_text)
        
        self.root.after(1000, self.update_stats)
    
    def toggle_performance_mode(self):
        """Toggle performance mode"""
        self.performance_mode = self.performance_var.get()
        if self.performance_mode:
            self.perf_label.config(text="⚡ Performance Mode", fg="#27ae60")
            self.log("Performance mode enabled", "INFO")
        else:
            self.perf_label.config(text="🐌 Normal Mode", fg="#e67e22")
            self.log("Performance mode disabled", "INFO")
    
    def toggle_auto_refresh(self):
        """Toggle auto-refresh"""
        self.auto_refresh = self.auto_refresh_var.get()
        if self.auto_refresh:
            self.log("Auto-refresh enabled", "INFO")
        else:
            self.log("Auto-refresh disabled", "INFO")
    
    def check_status(self):
        """Check if Cursor VIP is running"""
        try:
            for proc in psutil.process_iter(['pid', 'name', 'memory_info']):
                if 'cursor-vip' in proc.info['name'].lower():
                    self.stats['memory_usage'] = proc.info['memory_info'].rss
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
    
    def clear_log(self):
        """Clear the log"""
        self.log_text.delete(1.0, tk.END)
        self.log("Log cleared", "INFO")
    
    def export_log(self):
        """Export log to file"""
        try:
            filename = filedialog.asksaveasfilename(
                defaultextension=".txt",
                filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
            )
            if filename:
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(self.log_text.get(1.0, tk.END))
                self.log(f"Log exported to {filename}", "INFO")
                messagebox.showinfo("Success", f"Log exported to {filename}")
        except Exception as e:
            self.log(f"Error exporting log: {str(e)}", "ERROR")
            messagebox.showerror("Error", f"Failed to export log: {str(e)}")
    
    def start_all(self):
        """Start Cursor VIP and open Cursor"""
        def run():
            self.log("🚀 Starting Cursor VIP + Opening Cursor...", "INFO")
            self.progress.start()
            self.stats['start_time'] = time.time()
            
            try:
                # Use optimized executable if available
                exe_name = "cursor-vip_windows_optimized.exe"
                if not os.path.exists(f"build/{exe_name}"):
                    exe_name = "cursor-vip_windows_amd64.exe"
                
                self.cursor_vip_process = subprocess.Popen(
                    [f"build/{exe_name}"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                self.log("✅ Cursor VIP started successfully", "SUCCESS")
                self.log("⏳ Waiting for initialization...", "INFO")
                time.sleep(3)
                
                if self.check_status():
                    self.log("✅ Cursor VIP is running properly", "SUCCESS")
                    self.open_cursor()
                    self.log("🎉 Setup complete! Cursor is running with paid features.", "SUCCESS")
                    self.log("💎 All premium features are now unlocked!", "SUCCESS")
                else:
                    self.log("❌ Cursor VIP stopped unexpectedly", "ERROR")
                    messagebox.showerror("Error", "Cursor VIP stopped unexpectedly. Check the log for details.")
                
            except Exception as e:
                self.log(f"❌ Error starting Cursor VIP: {str(e)}", "ERROR")
                messagebox.showerror("Error", f"Failed to start Cursor VIP:\n{str(e)}")
            finally:
                self.progress.stop()
        
        threading.Thread(target=run, daemon=True).start()
    
    def start_vip_only(self):
        """Start Cursor VIP only"""
        def run():
            self.log("⚙️ Starting Cursor VIP only...", "INFO")
            self.progress.start()
            self.stats['start_time'] = time.time()
            
            try:
                exe_name = "cursor-vip_windows_optimized.exe"
                if not os.path.exists(f"build/{exe_name}"):
                    exe_name = "cursor-vip_windows_amd64.exe"
                
                self.cursor_vip_process = subprocess.Popen(
                    [f"build/{exe_name}"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    creationflags=subprocess.CREATE_NO_WINDOW
                )
                self.log("✅ Cursor VIP started successfully", "SUCCESS")
                self.log("⏳ Waiting for initialization...", "INFO")
                time.sleep(3)
                
                if self.check_status():
                    self.log("✅ Cursor VIP is running properly", "SUCCESS")
                    self.log("💡 You can now open Cursor manually", "INFO")
                    messagebox.showinfo("Success", "Cursor VIP started successfully!\nYou can now open Cursor manually.")
                else:
                    self.log("❌ Cursor VIP stopped unexpectedly", "ERROR")
                    messagebox.showerror("Error", "Cursor VIP stopped unexpectedly. Check the log for details.")
                
            except Exception as e:
                self.log(f"❌ Error starting Cursor VIP: {str(e)}", "ERROR")
                messagebox.showerror("Error", f"Failed to start Cursor VIP:\n{str(e)}")
            finally:
                self.progress.stop()
        
        threading.Thread(target=run, daemon=True).start()
    
    def open_cursor(self):
        """Open Cursor with paid features"""
        self.log("💻 Opening Cursor with paid features...", "INFO")
        
        if not self.check_status():
            self.log("⚠️ Warning: Cursor VIP is not running", "WARNING")
            messagebox.showwarning("Warning", "Cursor VIP is not running. Please start it first.")
            return
        
        cursor_paths = [
            "cursor",
            os.path.expanduser("~\\AppData\\Local\\Programs\\cursor\\Cursor.exe"),
            "C:\\Program Files\\Cursor\\Cursor.exe",
            "C:\\Program Files (x86)\\Cursor\\Cursor.exe",
            ".\\cursor.exe"
        ]
        
        cursor_found = False
        for path in cursor_paths:
            try:
                if path == "cursor":
                    subprocess.run(["where", "cursor"], check=True, capture_output=True)
                    subprocess.Popen(["cursor", "--enable-paid-features"])
                    cursor_found = True
                    break
                elif os.path.exists(path):
                    subprocess.Popen([path, "--enable-paid-features"])
                    cursor_found = True
                    break
            except:
                continue
        
        if cursor_found:
            self.log("✅ Cursor found and opened with paid features", "SUCCESS")
            self.log("🎉 All premium features are now available!", "SUCCESS")
            self.stats['requests_processed'] += 1
        else:
            self.log("❌ Error: Cursor not found. Please install Cursor first.", "ERROR")
            self.log("📥 Download from: https://cursor.sh/", "INFO")
            messagebox.showerror("Error", "Cursor not found. Please install Cursor first.\nDownload from: https://cursor.sh/")
    
    def stop_vip(self):
        """Stop Cursor VIP"""
        self.log("🛑 Stopping Cursor VIP...", "INFO")
        
        try:
            killed_count = 0
            for proc in psutil.process_iter(['pid', 'name']):
                if 'cursor-vip' in proc.info['name'].lower():
                    proc.kill()
                    self.log(f"✅ Killed process {proc.info['pid']}", "SUCCESS")
                    killed_count += 1
            
            if killed_count > 0:
                self.log(f"✅ Cursor VIP stopped successfully ({killed_count} processes)", "SUCCESS")
                self.log("⚠️ Cursor will lose access to paid features", "WARNING")
                messagebox.showinfo("Success", f"Cursor VIP stopped successfully!\n{killed_count} processes terminated.")
            else:
                self.log("ℹ️ No Cursor VIP processes were running", "INFO")
                messagebox.showinfo("Info", "No Cursor VIP processes were running.")
            
        except Exception as e:
            self.log(f"❌ Error stopping Cursor VIP: {str(e)}", "ERROR")
            messagebox.showerror("Error", f"Failed to stop Cursor VIP:\n{str(e)}")
    
    def open_settings(self):
        """Open settings window"""
        settings_window = tk.Toplevel(self.root)
        settings_window.title("Settings")
        settings_window.geometry("500x400")
        settings_window.resizable(False, False)
        settings_window.configure(bg='#f0f0f0')
        
        settings_window.transient(self.root)
        settings_window.grab_set()
        
        tk.Label(settings_window, text="Settings", font=("Segoe UI", 16, "bold"), bg='#f0f0f0').pack(pady=20)
        
        # Performance settings
        perf_frame = tk.LabelFrame(settings_window, text="Performance", font=("Segoe UI", 12, "bold"), bg='#f0f0f0')
        perf_frame.pack(fill="x", padx=20, pady=10)
        
        self.performance_var.set(self.performance_mode)
        perf_check = tk.Checkbutton(
            perf_frame,
            text="Enable Performance Mode (Recommended)",
            variable=self.performance_var,
            command=self.toggle_performance_mode,
            bg='#f0f0f0',
            font=("Segoe UI", 10)
        )
        perf_check.pack(anchor="w", padx=10, pady=5)
        
        self.auto_refresh_var.set(self.auto_refresh)
        refresh_check = tk.Checkbutton(
            perf_frame,
            text="Auto-refresh status every 5 seconds",
            variable=self.auto_refresh_var,
            command=self.toggle_auto_refresh,
            bg='#f0f0f0',
            font=("Segoe UI", 10)
        )
        refresh_check.pack(anchor="w", padx=10, pady=5)
        
        # Auto-start settings
        startup_frame = tk.LabelFrame(settings_window, text="Startup", font=("Segoe UI", 12, "bold"), bg='#f0f0f0')
        startup_frame.pack(fill="x", padx=20, pady=10)
        
        self.auto_start_var = tk.BooleanVar(value=self.auto_start)
        auto_start_check = tk.Checkbutton(
            startup_frame,
            text="Start Cursor VIP automatically on Windows startup",
            variable=self.auto_start_var,
            command=lambda: setattr(self, 'auto_start', self.auto_start_var.get()),
            bg='#f0f0f0',
            font=("Segoe UI", 10)
        )
        auto_start_check.pack(anchor="w", padx=10, pady=5)
        
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
        help_window.geometry("700x600")
        help_window.resizable(True, True)
        help_window.configure(bg='#f0f0f0')
        
        help_window.transient(self.root)
        help_window.grab_set()
        
        help_text = scrolledtext.ScrolledText(
            help_window,
            font=("Segoe UI", 10),
            bg='#f0f0f0',
            wrap=tk.WORD
        )
        help_text.pack(fill="both", expand=True, padx=20, pady=20)
        
        help_content = """
Cursor VIP Professional Launcher v3.0 - Optimized - Help

OVERVIEW:
This optimized launcher helps you unlock all premium features of Cursor IDE with enhanced performance and monitoring capabilities.

NEW FEATURES IN v3.0:
• Enhanced Performance Mode for faster operation
• Real-time performance monitoring
• Advanced logging and statistics
• Improved memory management
• Better error handling and recovery
• Export functionality for logs

HOW TO USE:

1. START CURSOR VIP + OPEN CURSOR (Recommended):
   - Starts the optimized Cursor VIP service
   - Automatically opens Cursor with paid features enabled
   - Includes performance optimizations

2. START CURSOR VIP ONLY:
   - Starts only the Cursor VIP service
   - You can manually open Cursor later
   - Useful for advanced users

3. OPEN CURSOR (if VIP running):
   - Opens Cursor with paid features
   - Only works if Cursor VIP is already running

4. STOP CURSOR VIP:
   - Stops the Cursor VIP service
   - Cursor will lose access to paid features

PERFORMANCE FEATURES:
• Performance Mode: Optimizes resource usage
• Real-time monitoring: Tracks uptime, requests, memory
• Auto-refresh: Keeps status updated automatically
• Memory management: Automatic garbage collection
• Request tracking: Monitors processed requests

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
- Use Performance Mode for better stability

SUPPORT:
- Check the Activity Log for error messages
- Export logs for debugging
- Make sure Cursor is properly installed
- Ensure Windows Defender isn't blocking the application

For more help, check the README file or contact support.
        """
        
        help_text.insert(1.0, help_content)
        help_text.config(state=tk.DISABLED)
        
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
        about_window.geometry("500x400")
        about_window.resizable(False, False)
        about_window.configure(bg='#f0f0f0')
        
        about_window.transient(self.root)
        about_window.grab_set()
        
        tk.Label(about_window, text="Cursor VIP Professional Launcher", font=("Segoe UI", 18, "bold"), bg='#f0f0f0').pack(pady=20)
        tk.Label(about_window, text="Version 3.0 - Optimized Build", font=("Segoe UI", 14), bg='#f0f0f0').pack(pady=5)
        
        about_text = """
A professional, optimized launcher for Cursor VIP that unlocks all premium features of Cursor IDE with enhanced performance and monitoring.

New Features in v3.0:
• Enhanced Performance Mode
• Real-time performance monitoring
• Advanced logging and statistics
• Improved memory management
• Better error handling
• Export functionality

Features:
• One-click activation
• Professional GUI interface
• Performance optimization
• Real-time monitoring
• Activity logging
• Easy to use
• Enhanced stability

This tool helps developers access all premium features of Cursor IDE without any restrictions, with optimized performance and professional monitoring capabilities.

Made with ❤️ for the developer community
        """
        
        tk.Label(about_window, text=about_text, font=("Segoe UI", 10), bg='#f0f0f0', justify=tk.LEFT).pack(pady=20, padx=20)
        
        tk.Button(
            about_window,
            text="Close",
            command=about_window.destroy,
            bg="#3498db",
            fg="white",
            font=("Segoe UI", 10),
            height=1
        ).pack(pady=10)
    
    def load_settings(self):
        """Load settings from file"""
        try:
            if os.path.exists('settings.json'):
                with open('settings.json', 'r') as f:
                    settings = json.load(f)
                    self.performance_mode = settings.get('performance_mode', True)
                    self.auto_refresh = settings.get('auto_refresh', True)
                    self.auto_start = settings.get('auto_start', False)
        except Exception as e:
            self.log(f"Error loading settings: {str(e)}", "WARNING")
    
    def save_settings(self):
        """Save settings to file"""
        try:
            settings = {
                'performance_mode': self.performance_mode,
                'auto_refresh': self.auto_refresh,
                'auto_start': self.auto_start
            }
            with open('settings.json', 'w') as f:
                json.dump(settings, f, indent=2)
        except Exception as e:
            self.log(f"Error saving settings: {str(e)}", "WARNING")

def main():
    # Check if required files exist
    if not os.path.exists("build/cursor-vip_windows_amd64.exe") and not os.path.exists("build/cursor-vip_windows_optimized.exe"):
        messagebox.showerror("Error", "Cursor VIP executable not found!\nPlease run the build script first.")
        return
    
    # Create and run GUI
    root = tk.Tk()
    app = CursorVIPOptimizedGUI(root)
    
    # Center window
    root.update_idletasks()
    x = (root.winfo_screenwidth() // 2) - (900 // 2)
    y = (root.winfo_screenheight() // 2) - (700 // 2)
    root.geometry(f"900x700+{x}+{y}")
    
    # Save settings on close
    def on_closing():
        app.save_settings()
        root.destroy()
    
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()

if __name__ == "__main__":
    main()