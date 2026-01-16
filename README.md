# AI Sandbox Setup

This script sets up a Docker-based AI sandbox environment with selectable AI coding tools. Choose from amp, opencode, droid, and claude. It automatically installs required dependencies like git and Python if missing, and ensures Docker is available. Note: droid (Factory CLI) is installed directly on the host system rather than containerized.

## Usage

Run `./setup.sh` to set up the environment.

It will prompt for workspace directories (comma-separated), then ask which AI tools to install (or 'all' for everything). It will install dependencies (git, python3), create necessary directories, build Docker images for selected tools, and configure shell aliases.

### Running Tools

**Containerized tools** (docker-based):
```bash
ai-run amp              # or: amp
ai-run opencode         # or: opencode
ai-run claude           # or: claude
ai-run droid            # or: droid
```

**VSCode** (fully containerized sandbox):
```bash
vscode-run              # or: vscode
```

## Requirements

- Docker Desktop (required)
- Linux/macOS with apt (for dependency installation)

## Tools Included

- **amp**: AI coding assistant from @sourcegraph/amp
- **opencode**: Open-source coding tool from opencode-ai
- **droid**: Factory CLI from factory.ai (installed on host system)
- **claude**: Claude Code CLI from Anthropic
- **vscode**: Model Context Protocol (MCP) server configuration for VSCode integration

## Configuration

After setup, edit `$HOME/.ai-env` with your API keys (OPENAI_API_KEY, ANTHROPIC_API_KEY).

## Workspace Management

AI tools are restricted to whitelisted directories for security. Workspaces are stored in `~/.ai-workspaces` (one path per line).

### Add a folder

```bash
echo '/path/to/new/folder' >> ~/.ai-workspaces
```

### Remove a folder

Edit `~/.ai-workspaces` and delete the line containing the folder path:

```bash
nano ~/.ai-workspaces
# or
vim ~/.ai-workspaces
```

### List whitelisted folders

```bash
cat ~/.ai-workspaces
```

### Example

```bash
# Add multiple folders
echo '/Users/me/projects' >> ~/.ai-workspaces
echo '/Users/me/work' >> ~/.ai-workspaces

# Verify
cat ~/.ai-workspaces
```

## Supported Configs

Per-project configurations:
- `.amp.json`
- `.opencode.json`
- `.droid.json`
- `.claude.json`

VSCode MCP Configuration:
- `.vscode/mcp.json` - MCP server definitions for VSCode integration

## VSCode with Full Sandbox

> **TODO**: VSCode GUI with X11 forwarding has library dependency issues. Currently switching to VSCode Server (web-based) for reliable implementation.

If you selected `vscode` during setup, **VSCode Server** (web-based) runs in a **fully containerized sandbox** similar to other AI tools. VSCode can ONLY access files in whitelisted workspaces, and the terminal is also sandboxed.

### Security Model

**Sandbox Restrictions:**
- ✓ **Runs in Docker container** (isolated from host)
- ✓ **Read-only filesystem** (except /workspace, /tmp)
- ✓ **No network access** (only localhost:8000)
- ✓ **No host environment variables** (OPENAI_API_KEY, etc. invisible)
- ✓ **No host filesystem access** (outside mounted volumes)
- ✓ **No elevated privileges** (CAP_DROP=ALL)
- ✓ **Terminal is sandboxed** (cannot cd outside /workspace)
- ✓ **Non-root user** (runs as UID 1001)

**Protection**: Even if VSCode or an extension is compromised, it cannot:
- Access your private files
- Read API keys or secrets
- Make network requests
- Escape the container
- Access other projects

### Setup

1. Run `./setup.sh` and select `vscode`
2. This builds the `ai-vscode:latest` Docker image
3. The wrapper script is created at `$HOME/bin/vscode-run`

### Requirements

- Docker Desktop
- No additional dependencies (web-based, no X11 needed)

### Usage

Simply run:

```bash
vscode-run
```

This will:
1. Mount all whitelisted workspaces into the container
2. Start VSCode Server in the container
3. Open browser at `http://localhost:8000`
4. VSCode runs fully sandboxed
5. Terminal inside VSCode is also sandboxed
6. Clean up when you close the browser or press Ctrl+C

### Example

If `~/.ai-workspaces` contains:
```
/Users/me/projects
/Users/me/work
```

Running `vscode-run`:
```
🔒 Starting VSCode Server (strict sandbox)...

Mounted workspaces:
  ✓ /Users/me/projects → /workspace/workspace-0
  ✓ /Users/me/work → /workspace/workspace-1

🚀 Opening browser at http://localhost:8000
```

VSCode opens in browser, but:
- Can ONLY see `/workspace/workspace-0` and `/workspace/workspace-1`
- Terminal cannot `cd /home` or access other files
- All edits stay in mounted workspaces
- No access to API keys, secrets, or host config

### Files Created

- `ai-vscode:latest` - Docker image (containerized VSCode Server)
- `$HOME/bin/vscode-run` - Wrapper script to launch VSCode Server