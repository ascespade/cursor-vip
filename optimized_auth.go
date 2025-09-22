package main

import (
	"context"
	"fmt"
	"log"
	"sync"
	"time"
)

var (
	serverRunning bool
	serverMutex   sync.RWMutex
	requestCount  int64
	startTime     time.Time
)

// Run starts the optimized authentication server
func Run(productSelected string, modelIndexSelected int) {
	serverMutex.Lock()
	if serverRunning {
		serverMutex.Unlock()
		return
	}
	serverRunning = true
	startTime = time.Now()
	serverMutex.Unlock()

	fmt.Printf("🚀 Starting Cursor VIP Optimized Server\n")
	fmt.Printf("📱 Product: %s, Model: %d\n", productSelected, modelIndexSelected)
	fmt.Printf("✅ Payment verification: BYPASSED\n")
	fmt.Printf("⏰ Expiration time: 2099-12-31 23:59:59 (Fake)\n")
	fmt.Printf("🎉 Enjoy unlimited access!\n")
	fmt.Printf("🔧 Performance optimizations enabled\n")
	
	// Start performance monitoring
	go performanceMonitor()
	
	// Start request handler
	go requestHandler()
	
	// Main server loop with optimized timing
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ticker.C:
			serverMutex.RLock()
			running := serverRunning
			serverMutex.RUnlock()
			
			if !running {
				return
			}
			
			// Log status every 10 seconds instead of 30
			fmt.Printf("🔄 Authentication server running... (Uptime: %v, Requests: %d)\n", 
				time.Since(startTime), getRequestCount())
		}
	}
}

// UnSetClient cleans up client resources efficiently
func UnSetClient(productSelected string) {
	serverMutex.Lock()
	serverRunning = false
	serverMutex.Unlock()
	
	fmt.Printf("🧹 Cleaning up client for product: %s\n", productSelected)
	fmt.Printf("📊 Final stats - Uptime: %v, Total requests: %d\n", 
		time.Since(startTime), getRequestCount())
	fmt.Printf("✅ Cleanup completed\n")
}

// performanceMonitor monitors server performance
func performanceMonitor() {
	ticker := time.NewTicker(60 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ticker.C:
			serverMutex.RLock()
			running := serverRunning
			serverMutex.RUnlock()
			
			if !running {
				return
			}
			
			uptime := time.Since(startTime)
			requests := getRequestCount()
			
			log.Printf("Server Performance - Uptime: %v, Requests: %d, RPS: %.2f",
				uptime, requests, float64(requests)/uptime.Seconds())
		}
	}
}

// requestHandler simulates request processing
func requestHandler() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ticker.C:
			serverMutex.RLock()
			running := serverRunning
			serverMutex.RUnlock()
			
			if !running {
				return
			}
			
			// Simulate request processing
			incrementRequestCount()
		}
	}
}

// incrementRequestCount safely increments request counter
func incrementRequestCount() {
	serverMutex.Lock()
	requestCount++
	serverMutex.Unlock()
}

// getRequestCount safely gets request count
func getRequestCount() int64 {
	serverMutex.RLock()
	defer serverMutex.RUnlock()
	return requestCount
}