# Lib/ - Tool Installation Scripts

**Purpose:** Installation and configuration scripts for 15+ AI coding tools

## Overview

Bash scripts that install and configure each supported AI tool inside Docker containers. Each script handles tool-specific setup, environment variables, and Docker image requirements.

## Structure

```
lib/
├── install-base.sh      # Bun runtime base image
├── install-{tool}.sh    # 14 tool-specific installers
├── generate-ai-run.sh   # Generates ai-run wrapper script
├── install-tool.sh      # Template for new tools
├── ssh-key-selector.sh  # Interactive SSH key chooser
├── install-codeserver.sh # VSCode Server setup
└── install-vscode.sh    # Desktop VSCode (X11)
```

## Where to Look

| Task | Script | Notes |
|------|--------|-------|
| Add new tool | `install-tool.sh` | Copy template, customize |
| Modify tool install | `install-{tool}.sh` | Update Docker image, env vars |
| SSH handling | `ssh-key-selector.sh` | User prompts for key selection |
| Wrapper generation | `generate-ai-run.sh` | Creates bin/ai-run |

## Tool Inventory

| Tool | Script | Type |
|------|--------|------|
| Claude | `install-claude.sh` | CLI binary |
| Gemini | `install-gemini.sh` | npm/Bun |
| Aider | `install-aider.sh` | Python |
| Opencode | `install-opencode.sh` | Go binary |
| Kilo | `install-kilo.sh` | npm/Bun |
| Codex | `install-codex.sh` | npm/Bun |
| Amp | `install-amp.sh` | npm/Bun |
| Qwen | `install-qwen.sh` | npm/Bun |
| Droid | `install-droid.sh` | Custom |
| Jules | `install-jules.sh` | npm/Bun |
| Qoder | `install-qoder.sh` | npm/Bun |
| Auggie | `install-auggie.sh` | npm/Bun |
| CodeBuddy | `install-codebuddy.sh` | npm/Bun |
| SHAI | `install-shai.sh` | npm/Bun |
| CodeServer | `install-codeserver.sh` | VSCode browser |
| VSCode | `install-vscode.sh` | Desktop X11 |

## Conventions

- Scripts use `set -e` for fail-fast
- Environment variables use `AI_` prefix
- Tool configs mounted to `/home/agent/` in container
- API keys read from `~/.ai-env`
- Docker images named `ai-{tool}:latest`
