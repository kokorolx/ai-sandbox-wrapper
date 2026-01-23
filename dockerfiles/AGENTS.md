# Dockerfiles/ - Container Images

**Purpose:** Docker container definitions for AI coding tool isolation

## Overview

One Dockerfile per supported AI tool. Each creates a secure, sandboxed environment with only the necessary runtime and access to whitelisted workspaces.

## Structure

```
dockerfiles/
├── base/        # Bun runtime, shared by most tools
├── claude/      # Claude Code CLI
├── gemini/      # Google Gemini CLI
├── aider/       # Aider pair programmer
├── opencode/    # Open-source AI coding
├── kilo/        # 500+ model support
├── codex/       # OpenAI Codex
├── amp/         # Sourcegraph Amp
├── qwen/        # Alibaba Qwen (1M context)
├── droid/       # Factory CLI
├── jules/       # Google Jules
├── qoder/       # Qoder AI assistant
├── auggie/      # Augment Auggie
├── codebuddy/   # Tencent CodeBuddy
└── shai/        # OVHcloud SHAI
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Modify base image | `base/Dockerfile` | Bun runtime, shared deps |
| Tool-specific config | `{tool}/Dockerfile` | Tool install, env setup |
| Security settings | All Dockerfiles | User, permissions, caps |

## Image Patterns

**Base Image (base/):**
- Bun runtime installation
- Non-root `agent` user
- Workspace mount point at `/workspace`

**Tool Images:**
- FROM `ai-base:latest`
- Tool-specific installation
- Environment variables for API keys
- Entry point configuration

## Security Settings (All Images)

```dockerfile
# Non-root user
RUN adduser -D agent

# Workspace mount
VOLUME ["/workspace"]

# Entry point
USER agent
WORKDIR /home/agent
```

## Image Source Options

- **Local build:** `AI_IMAGE_SOURCE=local` (default)
- **Registry pull:** `AI_IMAGE_SOURCE=registry` (faster)

Registry: `registry.gitlab.com/kokorolee/ai-sandbox-wrapper/ai-{tool}:latest`

## Platform Support

- linux/amd64 (x64)
- linux/arm64 (Apple Silicon)
- Configurable via `AI_RUN_PLATFORM` env var

## Host Access

**Accessing host services from containers:**

When joining Docker networks (e.g., MetaMCP), containers can access host services via `host.docker.internal`:

```bash
# Inside container, access MetaMCP at port 12008
curl http://host.docker.internal:12008/metamcp/default/sse

# Access PostgreSQL on host at port 5432
psql -h host.docker.internal -p 5432 -U myuser mydb
```

**Configuration:** See [METAMCP_GUIDE.md](../METAMCP_GUIDE.md) for detailed examples.
