# Cursor VIP - Deployment Guide

This guide explains how to run the cursor-vip application locally or deploy it to remote servers using various methods.

## Quick Start

### Local Development
```bash
# Build and run locally
./run-local.sh

# Or build for current platform only
./build.sh --local
```

### Remote Server Deployment
```bash
# Deploy to remote server
./deploy-remote.sh -h your-server.com -u username

# Or use environment variables
REMOTE_HOST=your-server.com REMOTE_USER=username ./deploy-remote.sh
```

### Docker Deployment
```bash
# Build and run with Docker
./docker-deploy.sh build
./docker-deploy.sh run

# Or use docker-compose
./docker-deploy.sh compose-up
```

## Deployment Methods

### 1. Local Development

The `run-local.sh` script provides an easy way to build and run the application locally for development:

```bash
./run-local.sh
```

**Features:**
- Automatically detects current platform and architecture
- Installs required dependencies (Go, garble, rsrc)
- Builds optimized binary for current platform
- Optionally runs the application immediately

### 2. Remote Server Deployment

The `deploy-remote.sh` script deploys the application to a remote server via SSH:

```bash
# Basic deployment
./deploy-remote.sh -h server.example.com -u admin

# With custom options
./deploy-remote.sh -h server.example.com -u admin -p 2222 -d /opt/cursor-vip -s my-cursor-vip
```

**Features:**
- Builds application for target platform
- Copies binary to remote server
- Installs systemd service
- Starts and enables the service
- Supports custom paths and service names

**Environment Variables:**
- `REMOTE_HOST`: Remote server hostname or IP
- `REMOTE_USER`: Remote username (default: root)
- `REMOTE_PORT`: SSH port (default: 22)
- `REMOTE_PATH`: Remote deployment path (default: /opt/cursor-vip)
- `SERVICE_NAME`: Systemd service name (default: cursor-vip)
- `BUILD_PLATFORM`: Build platform (default: linux/amd64)

### 3. Docker Deployment

The Docker deployment provides containerized deployment options:

#### Using Docker directly:
```bash
# Build image
./docker-deploy.sh build

# Run container
./docker-deploy.sh run -p 8080:8080

# Stop container
./docker-deploy.sh stop

# View logs
./docker-deploy.sh logs
```

#### Using Docker Compose:
```bash
# Start services
./docker-deploy.sh compose-up

# Stop services
./docker-deploy.sh compose-down

# View logs
./docker-deploy.sh compose-logs
```

**Features:**
- Multi-stage build for minimal production image
- Non-root user for security
- Health checks
- Resource limits
- Optional reverse proxy with nginx

### 4. Systemd Service

For Linux servers, you can install a systemd service:

```bash
# Install service
sudo ./systemd-install.sh install

# Start service
sudo ./systemd-install.sh start

# Check status
sudo ./systemd-install.sh status

# View logs
sudo ./systemd-install.sh logs

# Uninstall service
sudo ./systemd-install.sh uninstall
```

**Features:**
- Automatic startup on boot
- Service management commands
- Security hardening
- Resource limits
- Logging integration

## Build Options

The enhanced `build.sh` script supports various build options:

```bash
# Build all platforms (default)
./build.sh

# Build for current platform only
./build.sh --local

# Build for specific platform/architecture
./build.sh --platform linux --arch amd64

# Development build (no obfuscation)
./build.sh --dev

# Disable obfuscation
./build.sh --no-obfuscation
```

## Configuration

### Environment Variables

Most scripts support environment variables for configuration:

```bash
# Remote deployment
export REMOTE_HOST=server.example.com
export REMOTE_USER=admin
export REMOTE_PATH=/opt/cursor-vip
./deploy-remote.sh

# Docker deployment
export IMAGE_NAME=my-cursor-vip
export TAG=v1.0.0
./docker-deploy.sh build
```

### Service Configuration

The systemd service can be customized by editing the service file:

```bash
# Edit service file
sudo nano /etc/systemd/system/cursor-vip.service

# Reload systemd
sudo systemctl daemon-reload
sudo systemctl restart cursor-vip
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Make scripts executable
   chmod +x *.sh
   ```

2. **Go Not Found**
   ```bash
   # Install Go 1.23+
   # See: https://golang.org/doc/install
   ```

3. **SSH Connection Failed**
   ```bash
   # Test SSH connection
   ssh -p 22 user@server.com
   
   # Check SSH key authentication
   ssh-add -l
   ```

4. **Docker Permission Denied**
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Logout and login again
   ```

### Logs and Monitoring

```bash
# Systemd service logs
journalctl -u cursor-vip -f

# Docker container logs
docker logs -f cursor-vip

# Application logs (if configured)
tail -f /opt/cursor-vip/logs/app.log
```

### Health Checks

```bash
# Check if service is running
systemctl is-active cursor-vip

# Check Docker container health
docker ps --filter name=cursor-vip

# Test application endpoint
curl http://localhost:8080/health
```

## Security Considerations

1. **Use non-root users** for running the application
2. **Enable firewall rules** for exposed ports
3. **Use HTTPS** in production environments
4. **Regular updates** of the application and dependencies
5. **Monitor logs** for suspicious activity

## Production Deployment Checklist

- [ ] Configure firewall rules
- [ ] Set up SSL/TLS certificates
- [ ] Configure log rotation
- [ ] Set up monitoring and alerting
- [ ] Configure backup strategy
- [ ] Test disaster recovery procedures
- [ ] Document deployment procedures
- [ ] Train operations team

## Support

For issues and questions:
- Check the logs first
- Review this documentation
- Create an issue on GitHub
- Contact the development team
