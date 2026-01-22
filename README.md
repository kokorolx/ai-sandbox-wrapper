# 🔒 AI Sandbox Wrapper

**Isolate AI coding agents from your host system. Protect your data.**

AI coding tools like Claude, Gemini, and Aider have full access to your filesystem, environment variables, and terminal. This project sandboxes them in Docker containers with **strict security restrictions**.

*Last updated: Thursday, January 22, 2026*

## 🛡️ Why Use This?

Without sandbox:
- AI agents can read your SSH keys, API tokens, browser data
- Can execute arbitrary code with your user permissions
- Can access files outside your project

With AI Sandbox:
- ✅ AI only sees whitelisted workspace folders
- ✅ No access to host environment variables (API keys hidden)
- ✅ Read-only filesystem (except workspace)
- ✅ No network access to host services
- ✅ Runs as non-root user in container
- ✅ CAP_DROP=ALL (no elevated privileges)

## 🚀 Quick Start

```bash
git clone https://github.com/kokorolx/ai-sandbox-wrapper.git
cd ai-sandbox-wrapper
./setup.sh
```

Select tools to install when prompted, then:

```bash
# Either restart your terminal OR source your shell config:
source ~/.zshrc

# Then run any installed tool:
ai-run claude          # Sandboxed Claude Code
ai-run gemini          # Sandboxed Gemini CLI
ai-run aider           # Sandboxed Aider

# Or use the convenient aliases:
claude                 # Same as ai-run claude
gemini                 # Same as ai-run gemini
aider                  # Same as ai-run aider
```

## 📋 Prerequisites

Before running `setup.sh`, ensure you have:

| Requirement | Description | Verify Command |
|-------------|-------------|----------------|
| **Docker** | Docker Desktop (Mac/Windows) or dockerd (Linux) | `docker --version` |
| **Git** | For version control operations | `git --version` |
| **Python 3** | For Python-based tools like Aider | `python3 --version` |
| **Bash** | Setup script requires bash | `bash --version` |
| **SSH keys** (optional) | For Git authentication | `ls ~/.ssh/` |

### Platform-Specific Setup

**macOS:**
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Ensure Docker Desktop is running (check menubar icon)
```

**Linux:**
```bash
# Install Docker Engine
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

**Windows (WSL2):**
```bash
# Install Docker Desktop and enable WSL2 integration in Docker Desktop settings
# Use a WSL2 terminal (Ubuntu, etc.) for setup.sh
```

## ✅ Post-Setup

After running `./setup.sh`, complete these steps:

### 1. Reload Your Shell
The setup script adds `~/bin` to your PATH and creates aliases. Either:
```bash
source ~/.zshrc  # Reload immediately
# OR restart your terminal
```

### 2. Configure API Keys
Edit the environment file to add your API keys:
```bash
nano ~/.ai-env
```
Required keys vary by tool:
- **Claude**: `ANTHROPIC_API_KEY`
- **OpenAI tools** (Aider, Kilo, Codex): `OPENAI_API_KEY`
- **Gemini**: `GOOGLE_API_KEY` (optional - Gemini CLI has free tier)

### 3. Verify Installation
```bash
# List installed tools
ls ~/bin/

# Test a tool
ai-run claude --version
```

### 4. Add Your Projects
Workspaces are already configured from setup, but you can manage them:
```bash
# Add a new workspace
echo '/path/to/new/project' >> ~/.ai-workspaces

# Remove a workspace
nano ~/.ai-workspaces  # Delete the line

# List all whitelisted workspaces
cat ~/.ai-workspaces
```

## 🐳 Using Pre-Built Images

**Skip the build process!** Pull pre-built images directly from GitLab Container Registry:

```bash
# Pull a specific tool image
docker pull registry.gitlab.com/kokorolee/ai-sandbox-wrapper/ai-claude:latest
docker pull registry.gitlab.com/kokorolee/ai-sandbox-wrapper/ai-gemini:latest
docker pull registry.gitlab.com/kokorolee/ai-sandbox-wrapper/ai-aider:latest

# Or let setup.sh pull them automatically
./setup.sh  # Select tools, images will be pulled if available
```

**Available pre-built images:**
- `ai-base:latest` - Base image with Bun runtime
- `ai-amp:latest` - Sourcegraph Amp
- `ai-claude:latest` - Claude Code CLI
- `ai-droid:latest` - Factory CLI
- `ai-gemini:latest` - Google Gemini CLI
- `ai-kilo:latest` - Kilo Code (500+ models)
- `ai-codex:latest` - OpenAI Codex
- `ai-aider:latest` - AI pair programmer
- `ai-opencode:latest` - Open-source AI coding
- `ai-qwen:latest` - Alibaba Qwen (1M context)
- `ai-qoder:latest` - Qoder AI assistant
- `ai-auggie:latest` - Augment Auggie
- `ai-codebuddy:latest` - Tencent CodeBuddy
- `ai-jules:latest` - Google Jules
- `ai-shai:latest` - OVHcloud SHAI

**Benefits:**
- ⚡ **Faster setup** - No build time (seconds vs minutes)
- ✅ **CI-tested** - All images verified in GitLab CI
- 🔄 **Auto-updated** - Latest versions on every push to beta branch

## 📦 Supported Tools

### CLI Tools (Terminal-based)

| Tool | Status | Install Type | Description |
|------|--------|--------------|-------------|
| **claude** | ✅ | Native binary | Anthropic Claude Code |
| **opencode** | ✅ | Native Go | Open-source AI coding |
| **gemini** | ✅ | npm/Bun | Google Gemini CLI (free tier) |
| **aider** | ✅ | Python | AI pair programmer (Git-native) |
| **kilo** | ✅ | npm/Bun | Kilo Code (500+ models) |
| **codex** | ✅ | npm/Bun | OpenAI Codex agent |
| **amp** | ✅ | npm/Bun | Sourcegraph Amp |
| **qwen** | ✅ | npm/Bun | Alibaba Qwen CLI (1M context) |
| **droid** | ✅ | Custom | Factory CLI |

### GUI Tools (IDE/Editor)

| Tool | Status | Description |
|------|--------|-------------|
| **codeserver** | ✅ | VSCode in browser (localhost:8080) |
| **vscode** | ⚠️ Experimental | VSCode Desktop via X11 |
| **cursor** | 🔜 Planned | Cursor IDE sandbox |
| **antigravity** | 🔜 Planned | Antigravity IDE sandbox |

## 🖥️ Platform Support

| Platform | Status |
|----------|--------|
| macOS (Intel) | ✅ |
| macOS (Apple Silicon) | ✅ |
| Linux (x64) | ✅ |
| Linux (ARM64) | ✅ |
| Windows (Docker Desktop + WSL2) | ✅ |

## 📁 Directory Structure

AI Sandbox Wrapper creates and manages the following directories in your home folder:

| Directory | Purpose | Contents |
|-----------|---------|----------|
| `~/bin/` | Executables | `ai-run` wrapper and symlinks to tool scripts |
| `~/.ai-env` | API keys | Environment variables passed to containers (API keys) |
| `~/.ai-workspaces` | Security | List of whitelisted directories AI can access |
| `~/.ai-git-allowed` | Security | Workspaces where Git credentials are allowed |
| `~/.ai-cache/` | Caching | Tool-specific cache directories (e.g., `~/.ai-cache/claude/`) |
| `~/.ai-home/` | Config | Tool home directories with persistent configs |
| `~/.ai-images/` | Local images | Locally built Docker images (if not using registry) |

### Key Files

| File | Purpose |
|------|---------|
| `~/.ai-env` | API keys (format: `KEY=value`, one per line) |
| `~/.ai-git-allowed` | Workspaces with persistent Git access (one path per line) |
| `~/.ai-git-keys-*` | Saved SSH key selections for each workspace (md5-hashed) |

### Cache Structure

```
~/.ai-cache/
├── claude/          # Claude Code cache
├── gemini/          # Gemini CLI cache
├── aider/           # Aider cache
├── git/             # Git credentials cache (when enabled)
│   └── ssh/         # SSH keys and config for allowed workspace
```

### Home Structure

```
~/.ai-home/
├── claude/          # .claude.json and settings
├── gemini/          # Gemini configuration
├── aider/           # Aider config and history
└── .gitconfig       # Git configuration (when Git access enabled)
```

## ⚙️ Configuration

### API Keys
```bash
# Edit environment file
nano ~/.ai-env
```

### Workspace Management
```bash
# Add workspace
echo '/path/to/project' >> ~/.ai-workspaces

# List workspaces
cat ~/.ai-workspaces
```

### Environment Variables

All environment variables are configured in `~/.ai-env` or passed at runtime:

#### Image Source
Choose between locally built images or pre-built GitLab registry images:

```bash
# Add to ~/.ai-env

# Use locally built images (default)
AI_IMAGE_SOURCE=local

# Use pre-built images from GitLab registry
AI_IMAGE_SOURCE=registry
```

Or run with environment variable:
```bash
AI_IMAGE_SOURCE=registry ai-run claude
```

#### Platform Selection
For ARM64 Macs or other platforms, specify the container platform:

```bash
# Run with specific platform (linux/arm64, linux/amd64)
AI_RUN_PLATFORM=linux/arm64 ai-run claude
```

#### Docker Connection
For remote Docker hosts or non-default configurations:

```bash
# Use a different Docker socket
export DOCKER_HOST=unix:///var/run/docker.sock

# Or TCP connection
export DOCKER_HOST=tcp://localhost:2375
```

#### API Keys
Configure in `~/.ai-env`:

```bash
# Required for Claude tools
ANTHROPIC_API_KEY=sk-ant-api03-...

# Required for OpenAI-based tools
OPENAI_API_KEY=sk-...

# Optional for Gemini CLI
GOOGLE_API_KEY=AIza...

# Optional: disable specific keys
# ANTHROPIC_API_KEY=
# OPENAI_API_KEY=

### Per-Project Config

Each tool supports project-specific config files that override global settings:

| Tool | Project Config | Global Config Location |
|------|----------------|------------------------|
| Claude | `.claude.json` | `~/.claude/` |
| Gemini | `.gemini.json` | `~/.config/gemini/` |
| Aider | `.aider.conf` | `~/.config/aider/` |
| Opencode | `.opencode.json` | `~/.config/opencode/` |
| Kilo | `.kilo.json` | `~/.config/kilo/` |
| Codex | `.codex.json` | `~/.config/codex/` |
| Amp | `.amp.json` | `~/.config/amp/` |

**Priority:** Project config > Global config > Container defaults

```bash
# Example: Project-specific Claude config
cat > .claude.json << 'EOF'
{
  "model": "sonnet-4-20250514",
  "max_output_tokens": 8192,
  "temperature": 0.7
}
EOF
```

### Tool-Specific Config Locations

When using global configs (not project-specific), they're stored in:

```
~/.ai-home/{tool}/
├── .config/          # Tool configuration
│   └── {tool}/       # Per-tool config directory
├── .local/share/     # Tool data (cache, sessions)
└── .cache/           # Runtime cache
```

Each tool's config is mounted to `/home/agent/` inside the container.

### Git Workflow
AI tools work **inside** containers without Git credentials by default (secure).

**Option 1: Secure (Default) - Review & Commit from Host**
```bash
# 1. AI tool makes changes
ai-run claude  # Edits files in your workspace

# 2. Review changes on host
git diff

# 3. Commit from host (you have full control)
git add .
git commit -m "feat: changes suggested by AI"
git push
```

**Option 2: Enable Git Access (Interactive Prompt)**
When you run an AI tool, you'll be prompted:
```
🔐 Git Access Control
Allow AI tool to access Git credentials for this workspace?

  1) Yes, allow once (this session only)
  2) Yes, always allow for this workspace
  3) No, keep Git disabled (secure default)
```

**Managing Git access:**
```bash
# View allowed workspaces
cat ~/.ai-git-allowed

# Remove a workspace from allowed list
nano ~/.ai-git-allowed  # Delete the line
```

**Why this is secure:**
- ✅ Opt-in per workspace (not global)
- ✅ Granular control: Only selected keys and their matching Host configs are shared
- ✅ SSH keys mounted read-only
- ✅ You control which projects get Git access
- ✅ Easy to revoke access anytime

## 🔐 Security Model

```
┌─────────────────────────────────────────────────┐
│                   HOST SYSTEM                    │
│  ❌ SSH keys, API tokens, browser data          │
│  ❌ Home directory, system files                │
│  ❌ Other projects                               │
└─────────────────────────────────────────────────┘
                        │
                   Docker isolation
                        │
┌─────────────────────────────────────────────────┐
│              AI SANDBOX CONTAINER               │
│  ✅ /workspace (whitelisted folders only)       │
│  ✅ Passed API keys (explicit, for API calls)   │
│  ✅ Git config (for commits)                    │
│  ❌ Everything else                              │
└─────────────────────────────────────────────────┘
```

## ❓ Troubleshooting

### Installation Issues

**"Docker not found. Please install Docker Desktop first."**
```bash
# Verify Docker is installed
docker --version

# On macOS: Start Docker Desktop from Applications
# On Linux: sudo systemctl start docker

# Ensure Docker daemon is running
docker ps
```

**"Workspaces not configured. Run setup.sh first."**
```bash
# Run setup.sh again
cd /path/to/ai-sandbox-wrapper
./setup.sh

# Or manually create the workspaces file
echo "$HOME/projects" >> ~/.ai-workspaces
```

**"No tools selected for installation"**
- Re-run setup.sh and select at least one tool from the menu

### Runtime Issues

**"command not found: ai-run"**
```bash
# Reload your shell
source ~/.zshrc

# Or manually add to PATH
export PATH="$HOME/bin:$PATH"

# Verify the script exists
ls -la ~/bin/ai-run
```

**Tool doesn't start or shows errors**
```bash
# Check if image exists
docker images | grep ai-

# Pull pre-built image if using registry mode
AI_IMAGE_SOURCE=registry docker pull registry.gitlab.com/kokorolee/ai-sandbox-wrapper/ai-claude:latest

# Rebuild locally (if using local mode)
cd /path/to/ai-sandbox-wrapper
./setup.sh  # Select the tool to rebuild
```

**Permission denied errors**
```bash
# Ensure bin directory is in PATH
source ~/.zshrc

# Make scripts executable
chmod +x ~/bin/ai-run
chmod +x ~/bin/*
```

### Security Warnings

**"SECURITY WARNING: You are running outside a whitelisted workspace"**
```bash
# Option 1: Add current directory to workspaces
echo "$(pwd)" >> ~/.ai-workspaces

# Option 2: Navigate to a whitelisted directory
cd ~/projects
ai-run claude
```

**Git access prompts don't appear**
- Git access is only available when:
  1. Running in interactive mode (TTY attached)
  2. SSH keys exist in `~/.ssh/`
  3. `.gitconfig` exists in home directory

**"No git remotes found with SSH URLs"**
```bash
# Check your git remotes
git remote -v

# Add SSH remote if needed
git remote add origin git@github.com:username/repo.git
```

### Performance Issues

**Slow container startup**
- Use pre-built registry images instead of local builds
- Enable Docker build cache
- Use SSD storage for Docker data

**High memory usage**
```bash
# Check Docker disk usage
docker system df

# Clean up unused images/containers
docker system prune -a
```

### API Key Issues

**"API key not found" errors**
```bash
# Verify ~/.ai-env exists and has correct format
cat ~/.ai-env

# Edit with correct keys
nano ~/.ai-env

# Reload environment (start new terminal or source ~/.zshrc)
```

**Wrong model or pricing**
- Check tool-specific documentation for model requirements
- Some tools require specific API key formats

### Uninstallation

To completely remove AI Sandbox Wrapper:

```bash
# Remove installed tools and scripts
rm -rf ~/bin/ai-run
rm -rf ~/bin/{claude,gemini,aider,kilo,codex,amp,opencode,qwen,droid,qoder,auggie,codebuddy,jules,shai,vscode-run,codeserver-run}

# Remove configuration (optional - backup first!)
rm -f ~/.ai-env
rm -f ~/.ai-workspaces
rm -f ~/.ai-git-allowed
rm -rf ~/.ai-cache/
rm -rf ~/.ai-home/
rm -rf ~/.ai-images/

# Remove shell additions
# Edit ~/.zshrc and remove:
# - export PATH="$HOME/bin:$PATH"
# - alias claude="ai-run claude"
# - etc.

# Remove Docker images (optional)
docker rmi $(docker images -q 'ai-*') 2>/dev/null || true
docker rmi registry.gitlab.com/kokorolee/ai-sandbox-wrapper/* 2>/dev/null || true
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT