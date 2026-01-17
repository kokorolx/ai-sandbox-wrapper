# 🔒 AI Sandbox Wrapper

**Isolate AI coding agents from your host system. Protect your data.**

AI coding tools like Claude, Gemini, and Aider have full access to your filesystem, environment variables, and terminal. This project sandboxes them in Docker containers with **strict security restrictions**.

*Last updated: Saturday, January 17, 2026*

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
ai-run claude          # Sandboxed Claude Code
ai-run gemini          # Sandboxed Gemini CLI
ai-run aider           # Sandboxed Aider
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

### Per-Project Config
Each tool supports project-specific config files:
- `.claude.json`, `.gemini.json`, `.aider.conf`, etc.

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

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT