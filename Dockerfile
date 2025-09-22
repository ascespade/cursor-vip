# Multi-stage Dockerfile for cursor-vip
# This Dockerfile creates a minimal production image

# Build stage
FROM golang:1.23-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Install build tools
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build go install mvdan.cc/garble@latest

# Build the application
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 GOOS=linux GOARCH=amd64 garble -literals -tiny build -trimpath -buildvcs=false -ldflags "-w -s" -o cursor-vip

# Production stage
FROM alpine:3.20

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata \
    && addgroup -g 1001 -S appgroup \
    && adduser -u 1001 -S appuser -G appgroup

# Create non-root user
# user already created above

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/cursor-vip .

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port (adjust as needed based on your application)
EXPOSE 8080

# Health check
# Keep image minimal; keep healthcheck lightweight if endpoint exists
# HEALTHCHECK can be enabled in deployment environment

# Run the application
CMD ["./cursor-vip"]
