package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"runtime"
	"sync"
	"syscall"
	"time"

	"github.com/gofrs/flock"
	"github.com/kingparks/cursor-vip/auth"
	"github.com/kingparks/cursor-vip/tui"
	"github.com/kingparks/cursor-vip/tui/params"
	"github.com/kingparks/cursor-vip/tui/shortcut"
	"github.com/kingparks/cursor-vip/tui/tool"
)

var (
	lock         *flock.Flock
	pidFilePath  string
	ctx          context.Context
	cancel       context.CancelFunc
	wg           sync.WaitGroup
	performance  *PerformanceMonitor
)

// PerformanceMonitor monitors system performance
type PerformanceMonitor struct {
	startTime    time.Time
	memoryUsage  uint64
	cpuUsage     float64
	requestCount int64
	mu           sync.RWMutex
}

// NewPerformanceMonitor creates a new performance monitor
func NewPerformanceMonitor() *PerformanceMonitor {
	return &PerformanceMonitor{
		startTime: time.Now(),
	}
}

// UpdateMemoryUsage updates memory usage statistics
func (pm *PerformanceMonitor) UpdateMemoryUsage() {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	pm.memoryUsage = m.Alloc
}

// GetStats returns current performance statistics
func (pm *PerformanceMonitor) GetStats() (uptime time.Duration, memory uint64, requests int64) {
	pm.mu.RLock()
	defer pm.mu.RUnlock()
	
	return time.Since(pm.startTime), pm.memoryUsage, pm.requestCount
}

// IncrementRequests increments request counter
func (pm *PerformanceMonitor) IncrementRequests() {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	pm.requestCount++
}

func main() {
	// Initialize performance monitoring
	performance = NewPerformanceMonitor()
	
	// Set up graceful shutdown
	ctx, cancel = context.WithCancel(context.Background())
	defer cancel()
	
	// Set up signal handling
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP, syscall.SIGQUIT)
	
	// Start performance monitoring goroutine
	go performanceMonitor()
	
	// Initialize single instance lock
	var err error
	lock, pidFilePath, err = tool.EnsureSingleInstance("cursor-vip-optimized")
	if err != nil {
		log.Fatalf("Failed to create single instance lock: %v", err)
	}
	
	// Run TUI and get selections
	productSelected, modelIndexSelected := tui.Run()
	
	// Start server with context
	startServer(ctx, productSelected, modelIndexSelected)
	
	// Wait for shutdown signal
	<-sigChan
	log.Println("Shutdown signal received, cleaning up...")
	
	// Cancel context to stop all goroutines
	cancel()
	
	// Wait for all goroutines to finish
	wg.Wait()
	
	// Cleanup
	cleanup()
	
	log.Println("Application stopped gracefully")
}

func startServer(ctx context.Context, productSelected string, modelIndexSelected int) {
	// Set up signal handling for the server
	params.Sigs = make(chan os.Signal, 1)
	signal.Notify(params.Sigs, os.Interrupt, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP, syscall.SIGQUIT, syscall.SIGKILL)
	
	// Start signal handler goroutine
	wg.Add(1)
	go func() {
		defer wg.Done()
		select {
		case <-ctx.Done():
			return
		case sig := <-params.Sigs:
			log.Printf("Received signal: %v", sig)
			cancel()
		}
	}()
	
	// Start shortcut handler
	wg.Add(1)
	go func() {
		defer wg.Done()
		select {
		case <-ctx.Done():
			return
		default:
			shortcut.Do()
		}
	}()
	
	// Start authentication server
	wg.Add(1)
	go func() {
		defer wg.Done()
		select {
		case <-ctx.Done():
			auth.UnSetClient(productSelected)
			return
		default:
			auth.Run(productSelected, modelIndexSelected)
		}
	}()
}

func performanceMonitor() {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			performance.UpdateMemoryUsage()
			uptime, memory, requests := performance.GetStats()
			
			log.Printf("Performance Stats - Uptime: %v, Memory: %d bytes, Requests: %d",
				uptime, memory, requests)
			
			// Force garbage collection if memory usage is high
			if memory > 100*1024*1024 { // 100MB
				runtime.GC()
				log.Println("Forced garbage collection due to high memory usage")
			}
		}
	}
}

func cleanup() {
	if lock != nil {
		_ = lock.Unlock()
	}
	if pidFilePath != "" {
		_ = os.Remove(pidFilePath)
	}
	
	// Final performance stats
	uptime, memory, requests := performance.GetStats()
	log.Printf("Final Stats - Uptime: %v, Memory: %d bytes, Requests: %d",
		uptime, memory, requests)
}