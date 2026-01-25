# Troubleshooting Guide

## Tool Takes Long Time to Show Layout or Doesn't Appear

### Quick Diagnosis
Run the diagnostic tool to identify issues:
```bash
ai-debug
```

### Common Causes & Solutions

#### 1. **Platform Mismatch (MOST COMMON)**

**Symptom:** Tool takes 10-30+ seconds to start, or hangs completely

**Cause:** Wrong platform architecture (e.g., running x86_64 images on ARM64 Mac via slow emulation)

**Check:**
```bash
# Check your system architecture
uname -m
# arm64 or aarch64 = ARM
# x86_64 = Intel/AMD

# Check image architecture
docker image inspect ai-opencode:latest | grep Architecture
```

**Solution:**
```bash
# Rebuild images for your platform
./setup.sh  # Select tools to rebuild

# Or force correct platform
AI_RUN_PLATFORM=linux/arm64 ai-run opencode  # For ARM
AI_RUN_PLATFORM=linux/amd64 ai-run opencode  # For Intel
```

#### 2. **Terminal Size Not Detected**

**Symptom:** UI appears broken, text overflows, layout is corrupted

**Cause:** Container doesn't know terminal dimensions

**Check:**
```bash
# Check if terminal size is available
tput cols
tput lines
```

**Solution:**
```bash
# Manually set terminal size
export COLUMNS=120
export LINES=40
ai-run opencode

# Or resize your terminal window and retry
```

#### 3. **TTY Not Allocated**

**Symptom:** No interactive prompt, tool doesn't respond to input

**Cause:** Running in non-TTY environment (background, CI, pipe)

**Check:**
```bash
tty
# Should output: /dev/ttys000 (or similar)
# If "not a tty", you're in non-interactive mode
```

**Solution:**
```bash
# Use shell mode for better interactivity
ai-run opencode --shell

# Or check if you're piping output
ai-run opencode  # Don't use: ai-run opencode | less
```

#### 4. **Container Name Conflict**

**Symptom:** Error: "container name already in use"

**Cause:** Previous container didn't exit cleanly

**Solution:**
```bash
# List running containers
docker ps | grep opencode

# Stop and remove
docker rm -f opencode-myproject-abc123

# Or remove all AI containers
docker ps -a | grep "opencode-\|claude-\|gemini-" | awk '{print $1}' | xargs docker rm -f
```

#### 5. **Slow Volume Mounts (macOS)**

**Symptom:** Tool starts but file operations are slow

**Cause:** Docker Desktop volume sync on macOS

**Solution:**
```bash
# Already configured with :delegated flag
# For extremely large projects, consider:
# - Exclude node_modules, .git, build folders
# - Use .dockerignore

# Check current mounts
docker inspect <container-name> | grep Mounts -A 20
```

#### 6. **Missing Dependencies in Container**

**Symptom:** Tool starts but crashes or shows errors

**Check:**
```bash
# Enter container in shell mode
ai-run opencode --shell

# Check if tool is installed
which opencode
opencode --version

# Check for errors
opencode 2>&1 | head -20
```

**Solution:**
```bash
# Rebuild the image
./setup.sh  # Select the tool
```

---

## Performance Optimization

### For Development (Iterative Work)

Use **shell mode** to avoid recreating container:
```bash
ai-run opencode --shell
agent@container$ opencode
# Press Ctrl+C to stop
agent@container$ opencode  # Start again instantly
agent@container$ exit
```

### For Native Speed

Ensure platform matches:
```bash
# Add to ~/.ai-env
AI_RUN_PLATFORM=linux/arm64  # For Apple Silicon
# or
AI_RUN_PLATFORM=linux/amd64  # For Intel/AMD
```

### For Better Terminal Rendering

```bash
# Add to ~/.zshrc or ~/.bashrc
export TERM=xterm-256color
export COLORTERM=truecolor
```

---

## Diagnostic Commands

### System Check
```bash
ai-debug  # Comprehensive diagnostics
```

### Docker Status
```bash
docker ps                    # Running containers
docker images | grep ai-     # Available images
docker stats                 # Resource usage
```

### Container Inspection
```bash
# Get container name
docker ps | grep opencode

# View logs
docker logs <container-name>

# Inspect configuration
docker inspect <container-name>

# Enter running container
docker exec -it <container-name> bash
```

### Debug Mode
```bash
# Enable verbose output
AI_RUN_DEBUG=1 ai-run opencode
```

---

## Common Error Messages

### "Workspaces not configured"
```bash
# Run setup
./setup.sh

# Or manually add workspace
echo "$(pwd)" >> ~/.ai-workspaces
```

### "Image not found"
```bash
# Pull from registry
docker pull registry.gitlab.com/kokorolee/ai-sandbox-wrapper/ai-opencode:latest

# Or rebuild locally
./setup.sh
```

### "Permission denied"
```bash
# Fix Docker socket permissions (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Restart Docker (macOS)
# Docker Desktop > Restart
```

### "Cannot connect to Docker daemon"
```bash
# Check if Docker is running
docker ps

# Start Docker Desktop (macOS/Windows)
# Or start Docker service (Linux)
sudo systemctl start docker
```

---

## Still Having Issues?

1. **Run full diagnostics:**
   ```bash
   ai-debug > diagnostics.txt
   cat diagnostics.txt
   ```

2. **Check container logs:**
   ```bash
   docker logs <container-name> 2>&1 | tail -50
   ```

3. **Try with minimal setup:**
   ```bash
   # Fresh start
   docker pull registry.gitlab.com/kokorolee/ai-sandbox-wrapper/ai-opencode:latest
   cd ~/test-project
   echo "$PWD" >> ~/.ai-workspaces
   ai-run opencode --shell
   ```

4. **Report issue with:**
   - Output of `ai-debug`
   - Output of `AI_RUN_DEBUG=1 ai-run <tool>`
   - Your OS and architecture (`uname -a`)
   - Docker version (`docker --version`)
