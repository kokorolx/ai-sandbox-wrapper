<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# AI Sandbox Wrapper - Project Knowledge Base

**Generated:** 2025-01-23
**Branch:** Not in git repo context
**Purpose:** Docker-based security sandbox for AI coding agents

## Overview

Security-focused wrapper that runs AI coding tools (Claude, Gemini, Aider, etc.) in isolated Docker containers with strict access controls. Protects host system by whitelisting only specific workspace directories.

## Structure

```
./
├── bin/              # Executable wrappers (ai-run, setup-ssh-config)
├── lib/              # Installation scripts for 15+ AI tools
├── dockerfiles/      # Container images for each tool
├── setup.sh          # Main setup script (interactive)
├── .opencode/        # OpenCode configuration
├── .specify/         # Spec-driven development config
└── .github/          # GitHub workflows
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Main setup | `setup.sh` | Interactive installer, handles all setup |
| Add new tool | `lib/install-{tool}.sh` | Follow pattern: `install-tool.sh` |
| Container image | `dockerfiles/{tool}/Dockerfile` | Each tool has dedicated Dockerfile |
| Run tool sandbox | `bin/ai-run` | Entry point for all sandboxed tools |

## Code Map

**Key Executables:**

| File | Purpose | Lines |
|------|---------|-------|
| `bin/ai-run` | Main wrapper, handles Docker run commands | ~400 |
| `setup.sh` | Interactive installer with menu system | ~600 |
| `lib/ssh-key-selector.sh` | SSH key management for Git access | ~150 |
| `lib/install-tool.sh` | Template for new tool installations | ~100 |

## Conventions

- **Shell scripts:** Use `set -e` for error handling
- **Dockerfiles:** Multi-stage builds, non-root user (`agent`)
- **Naming:** `install-{tool}.sh` for tool installers
- **Exit codes:** Scripts return non-zero on failure

## Anti-Patterns (This Project)

- ❌ **NEVER** run AI tools without Docker isolation
- ❌ **NEVER** mount full home directory to containers
- ❌ **NEVER** share SSH keys by default (opt-in only)
- ❌ **NEVER** allow network access to host services

## Unique Styles

1. **Interactive menus** in setup.sh using tput for terminal control
2. **Workspace whitelisting** via `~/.ai-workspaces` file
3. **Per-tool Docker images** - each AI tool has dedicated container
4. **SSH key selector** - user chooses which keys to share per workspace
5. **Image source selection** - local build vs. GitLab registry

## Commands

```bash
# Setup (run once)
./setup.sh

# Run AI tool in sandbox
ai-run claude
claude --version  # If symlinked during setup

# Add new workspace
echo '/path/to/project' >> ~/.ai-workspaces

# Configure API keys
nano ~/.ai-env
```

## Security Model

- Containers run as non-root `agent` user
- CAP_DROP=ALL - no elevated privileges
- Read-only filesystem except `/workspace`
- Only whitelisted directories accessible
- API keys passed via environment (explicit opt-in)
- Git access: opt-in per workspace, key-level control

## Docker Network Support

**MetaMCP and multi-container setups:**
- Auto-detects and joins `metamcp_metamcp-network`
- Enables `host.docker.internal` for host service access
- See [METAMCP_GUIDE.md](METAMCP_GUIDE.md) for detailed integration instructions

### Container Naming

Containers are automatically named based on the project folder:

```bash
# Running in /Users/tamlh/projects/my-awesome-app
$ ai-run opencode
# Creates container: opencode-my-awesome-app

# Running in /Users/tamlh/workspace/Test Project
$ ai-run claude
# Creates container: claude-test-project
```

**Naming format:** `{tool}-{sanitized_folder_name}`

**Rules:**
- Folder name sanitized (lowercase, alphanumeric, hyphens, underscores)
- Max 50 characters
- Spaces converted to hyphens
- Special characters removed

### Network Management Commands

```bash
ai-network list              # Show configured networks
ai-network metamcp           # Add MetaMCP network
ai-network add <name>        # Add custom network
ai-network remove <name>     # Remove a network

# List AI tool containers (named by project folder)
docker ps --filter "name=opencode-" --filter "name=claude-"
```

## Gotchas

- Requires Docker running before setup
- Must run `source ~/.zshrc` after setup to get `ai-run` in PATH
- API keys not passed to containers unless in `~/.ai-env`
- Git access requires explicit user permission per workspace
- Dockerfiles use Bun runtime by default (ai-base image)
