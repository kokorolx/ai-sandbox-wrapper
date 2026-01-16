# VSCode - Fully Containerized Sandbox

VSCode runs in a **Docker container with full isolation**. It can only access files in whitelisted workspaces, and the integrated terminal is also sandboxed.

## Why Containerized?

**Problem with native VSCode:**
- Terminal can `cd /` and access any host file
- Extensions can read environment variables
- Can escape the workspace boundary

**Solution: Container Sandbox**
- VSCode runs in isolated Docker container
- Filesystem is read-only (except /workspace)
- Terminal cannot access host filesystem
- No access to host environment or network
- Non-root user for additional security

## Security Guarantees

Even if VSCode or an extension is compromised, it **cannot**:
- ✗ Access files outside mounted workspaces
- ✗ Read `/home`, `/root`, or host files
- ✗ Access API keys or secrets (OPENAI_API_KEY, etc.)
- ✗ Make network requests to exfiltrate data
- ✗ Escape the container
- ✗ Access other projects or workspaces
- ✗ Modify system files

## Installation

```bash
./setup.sh
# Select: vscode
```

This:
1. Builds `ai-vscode:latest` Docker image
2. Creates `$HOME/bin/vscode-run` wrapper script

## Requirements

- Docker Desktop
- **macOS**: XQuartz installed (for X11 display)
- **Linux**: X11 display available
- Whitelisted workspaces in `~/.ai-workspaces`

### Install XQuartz (macOS)

```bash
brew install xquartz
# Or download from: https://www.xquartz.org/
```

## Usage

```bash
vscode-run
```

That's it. VSCode opens with sandboxed access.

## How It Works

```
Host (your computer)
  ├─ VSCode display (native GUI)
  └─ X11 forwarding

Docker Container (sandbox)
  ├─ VSCode server (no GUI, sends display to X11)
  ├─ /workspace/ (mounted, read-write)
  │  ├─ workspace-0/ (from /Users/you/projects)
  │  ├─ workspace-1/ (from /Users/you/work)
  │  └─ etc.
  ├─ /tmp (ephemeral tmpfs)
  └─ Everything else (read-only or missing)
```

## Step-by-Step Example

### 1. Configure Workspaces

`~/.ai-workspaces`:
```
/Users/me/projects
/Users/me/work
```

### 2. Run VSCode

```bash
$ vscode-run
🔒 Starting containerized VSCode (strict sandbox)...

Mounted workspaces:
  ✓ /Users/me/projects → /workspace/workspace-0
  ✓ /Users/me/work → /workspace/workspace-1

🚀 Launching VSCode in sandbox container...
```

### 3. VSCode Opens

You see VSCode with folder `/workspace` containing:
```
workspace/
├── workspace-0/
│   ├── project1/
│   ├── project2/
│   └── ...
├── workspace-1/
│   ├── work-file1
│   ├── work-file2
│   └── ...
```

### 4. Try to Escape (You Can't!)

**Try in terminal:**
```bash
cd /                        # Error: read-only filesystem
cd /Users/me                # Error: No such file
cat ~/.ssh/id_rsa           # Error: No such file
curl https://evil.com       # Error: No network
```

**Try in UI:**
- File → Open Folder → Try to browse `/home` → Not accessible

### 5. Close VSCode

```bash
# When you close VSCode:
🧹 VSCode container closed
✅ Sandbox cleaned up
```

Container stops and is removed.

## File Access

### What VSCode CAN Access

- All files in `/workspace/` (mounted from whitelisted paths)
- `/tmp` (temporary, isolated)
- Own user files in `/home/vscode` (container user, not host)

### What VSCode CANNOT Access

- `/Users`, `/home` (host home directories)
- `/root` (root home)
- `/etc` (system configuration)
- `/var` (system logs)
- Host network
- Host environment variables
- Docker socket
- Any host filesystem

## Terminal in VSCode

The integrated terminal in VSCode runs **inside the container**, so it's fully sandboxed:

```bash
# Inside VSCode terminal:
$ pwd
/workspace

$ cd ..
$ pwd
/workspace  # Still in workspace (mount point)

$ ls /Users
# Error: No such file or directory

$ echo $OPENAI_API_KEY
# (empty - not visible)

$ curl https://attacker.com
# Error: Network unreachable
```

## Docker Sandbox Flags

The container is started with strict security:

```bash
docker run \
    --rm \
    --read-only \              # Read-only root filesystem
    --tmpfs /tmp \             # Isolated /tmp
    --cap-drop=ALL \           # Drop all Linux capabilities
    --security-opt=no-new-privileges:true \
    -u 1000:1000 \             # Non-root user
    -v /Users/me/projects:/workspace/workspace-0 \
    -v /Users/me/work:/workspace/workspace-1 \
    ai-vscode:latest
```

**What this prevents:**
- `--read-only` → Cannot modify filesystem
- `--tmpfs /tmp` → /tmp is isolated, deleted on exit
- `--cap-drop=ALL` → No Linux capabilities (can't escalate, mount, etc.)
- `-u 1000:1000` → Non-root user (can't access /root, run privileged commands)

## Troubleshooting

### "Can't connect to X11 socket" (macOS)

```bash
# Make sure XQuartz is running
open -a XQuartz

# Try vscode-run again
vscode-run
```

### "Can't connect to X11 socket" (Linux)

```bash
# Check X11 is running
echo $DISPLAY  # Should output something like :0

# If empty:
export DISPLAY=:0
vscode-run
```

### VSCode window doesn't appear

- Make sure X11/XQuartz is running
- Check firewall isn't blocking X11
- Try again with `vscode-run`

### Can't save files

- Make sure your whitelisted workspaces have write permissions
- Files are saved in actual locations (not copies)

### Terminal says "read-only filesystem"

- That's correct! Anything outside `/workspace` is read-only
- Save files in workspace directories

## Platform Differences

### macOS

- Uses XQuartz for X11 display
- `--tmpfs` creates tmpfs mount
- Symlinks in `/workspace` show as native paths

### Linux

- Uses host X11 socket
- `--tmpfs` creates tmpfs mount
- Full bind mount support

## Architecture Comparison

| Feature | Native VSCode | Containerized VSCode |
|---------|--------------|----------------------|
| Terminal isolation | No | **Yes** |
| File access control | Limited | **Full** |
| Environment isolation | No | **Yes** |
| Network isolation | No | **Yes** |
| Escape risk | High | **Minimal** |
| Setup complexity | Simple | Moderate |
| Performance | Best | Good |

## Files Created

- `ai-vscode:latest` - Docker image
- `$HOME/bin/vscode-run` - Launch wrapper
- `~/.vscode-workspace/` - Temporary mount point (created/deleted per run)

## See Also

- [Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Linux Capabilities](http://man7.org/linux/man-pages/man7/capabilities.7.html)
- [VSCode Documentation](https://code.visualstudio.com/docs)
- Main project README
