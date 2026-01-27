# 🔒 AI Sandbox Wrapper

**Isolate AI coding agents from your host system. Protect your data.**

AI coding tools like Claude, Gemini, and Aider have full access to your filesystem, environment variables, and terminal. This project sandboxes them in Docker containers with **strict security restrictions**.

**What this does:** Runs AI tools in secure containers that can only access specific project folders, protecting your SSH keys, API tokens, and other sensitive data.

**What you get:** Peace of mind using AI coding tools without risking your personal and system data.

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

## 🚀 Step-by-Step Installation

### Step 1: Prerequisites
Ensure you have Docker installed and running:
- **macOS:** [Install Docker Desktop](https://www.docker.com/products/docker-desktop) and start it
- **Linux:** Install Docker Engine with `curl -fsSL https://get.docker.com | sh`
- **Windows:** Use WSL2 with Docker Desktop

Verify Docker is working:
```bash
docker --version
docker ps  # Should not show errors
```

### Step 2: Run Setup

**Option A: Using npx (Recommended)**
```bash
npx @kokorolx/ai-sandbox-wrapper setup
```

**Option B: Clone and run manually**
```bash
git clone https://github.com/kokorolx/ai-sandbox-wrapper.git
cd ai-sandbox-wrapper
./setup.sh
```

### Step 3: Follow the Interactive Prompts
1. **Whitelist workspaces** - Enter the directories where you want AI tools to access (e.g., `~/projects,~/code`)
2. **Select tools** - Use arrow keys to move, space to select, Enter to confirm
3. **Choose image source** - Select registry (faster) or build locally

### Step 4: Complete Setup
```bash
# Reload your shell to update PATH
source ~/.zshrc

# Add your API keys (only if using tools that require them)
nano ~/.ai-env  # Add ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.
```

### Step 5: Run Your First Tool
```bash
# Navigate to a project directory that's in your whitelisted workspaces
cd ~/projects/my-project

# Run a tool (the example below assumes you selected Claude during setup)
claude --version  # or: ai-run claude --version
```

## 📋 What You Need

**Required:**
- **Docker** - Docker Desktop (macOS/Windows) or Docker Engine (Linux)
- **Git** - For cloning the repository
- **Bash** - For running the setup script

**Optional (for specific tools):**
- **Python 3** - For tools like Aider
- **SSH keys** - For Git access in containers

## ✅ After Installation

### Verify Everything Works
```bash
# Reload your shell to get the new commands
source ~/.zshrc

# Check if the main command works
ai-run --help

# Test a tool you installed (replace 'claude' with your chosen tool)
claude --version
```

### Add More Projects Later (Optional)
If you want to give AI access to more project directories later:
```bash
# Add a new workspace
echo '/path/to/new/project' >> ~/.ai-workspaces

# View current allowed directories
cat ~/.ai-workspaces
```

### Configure API Keys (If Needed)
Some tools require API keys to work properly:
```bash
nano ~/.ai-env
```
Then add your keys in the format: `KEY_NAME=your_actual_key_here`
Examples:
- `ANTHROPIC_API_KEY=your_key_here` (for Claude)
- `OPENAI_API_KEY=your_key_here` (for OpenAI tools)

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

### Additional Tools (Container-Only)

During setup, you can optionally install additional tools into the base Docker image:

| Tool | Description | Size Impact |
|------|-------------|-------------|
| spec-kit | Spec-driven development toolkit | ~50MB |
| ux-ui-promax | UI/UX design intelligence tool | ~30MB |
| openspec | OpenSpec - spec-driven development | ~20MB |
| playwright | Browser automation with Chromium/Firefox/WebKit | ~500MB |

**Always Installed (for LSP support):**
- `typescript` + `typescript-language-server` - Required for AI coding assistants with LSP integration

**Playwright** is useful when AI tools need to:
- Run browser-based tests
- Scrape web content
- Verify UI changes
- Automate browser workflows

```bash
# Manual build with Playwright (if not selected during setup)
INSTALL_PLAYWRIGHT=1 bash lib/install-base.sh

# Verify Playwright in container
docker run --rm ai-base:latest npx playwright --version

# Verify TypeScript LSP
docker run --rm ai-base:latest tsc --version
```

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

### Common Issues

**Docker not found**
- Make sure Docker Desktop is installed and running
- Check with: `docker --version` and `docker ps`

**"command not found: ai-run"**
- Reload your shell: `source ~/.zshrc`
- Verify setup completed: check if `~/bin/ai-run` exists

**"Workspaces not configured"**
- Run setup again: `./setup.sh`
- Make sure you entered workspace directories during setup

**Tool doesn't start**
- Check if you selected the tool during setup
- Look for the Docker image: `docker images | grep ai-`

**"Outside whitelisted workspace" error**
- Add your current directory: `echo "$(pwd)" >> ~/.ai-workspaces`
- Or navigate to a directory you whitelisted during setup

**API key errors**
- Check your keys in: `cat ~/.ai-env`
- Make sure keys are in format: `KEY_NAME=actual_key_value`

### Getting Help

If you're still having issues:
1. Check that Docker is running
2. Re-run `./setup.sh` to reinstall
3. Look at the configuration files in your home directory:
   - `~/.ai-workspaces` - should contain your project directories
   - `~/.ai-env` - should contain your API keys (if needed)
4. View Docker images: `docker images` to see if tools built successfully

## 📚 Quick Reference

### Main Commands
- `ai-run <tool>` - Run any tool in sandbox (e.g., `ai-run claude`)
- `ai-run <tool> --shell` - Start interactive shell mode (see [Shell Mode Guide](SHELL-MODE-USAGE.md))
- `<tool>` - Shortcut for tools you installed (e.g., `claude`, `aider`)

### Execution Modes

**Direct Mode (Default):**
```bash
ai-run opencode
# Tool runs directly, exits on Ctrl+C
```

**Shell Mode (Interactive):**
```bash
ai-run opencode --shell  # or -s
# Starts bash shell, run tool manually
# Ctrl+C stops tool only, not container
# Perfect for development and debugging
```

See [SHELL-MODE-USAGE.md](SHELL-MODE-USAGE.md) for detailed examples and use cases.

### Configuration Files
- `~/.ai-env` - Store API keys here
- `~/.ai-workspaces` - Whitelisted project directories
- `~/.ai-cache/` - Tool cache (persistent)
- `~/.ai-home/` - Tool configurations (persistent)

### Common Tasks
```bash
# Add a new project directory to AI access
echo '/path/to/my/new/project' >> ~/.ai-workspaces

# Check what tools are installed
ls ~/bin/

# Reload shell after setup
source ~/.zshrc

# Update to latest version
npx @kokorolx/ai-sandbox-wrapper@latest setup
```

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT