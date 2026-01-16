# AI Sandbox Setup

This script sets up a Docker-based AI sandbox environment with selectable AI coding tools. Choose from amp, opencode, droid, and claude. It automatically installs required dependencies like git and Python if missing, and ensures Docker is available. Note: droid (Factory CLI) is installed directly on the host system rather than containerized.

## Usage

Run `./setup.sh` to set up the environment.

It will prompt for workspace directories (comma-separated), then ask which AI tools to install (or 'all' for everything). It will install dependencies (git, python3), create necessary directories, build Docker images for selected tools, and configure shell aliases.

## Requirements

- Docker Desktop (required)
- Linux/macOS with apt (for dependency installation)

## Tools Included

- **amp**: AI coding assistant from @sourcegraph/amp
- **opencode**: Open-source coding tool from opencode-ai
- **droid**: Factory CLI from factory.ai (installed on host system)
- **claude**: Claude Code CLI from Anthropic

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