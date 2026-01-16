# 🔒 AI Sandbox Wrapper

**Isolate AI coding agents from your host system. Protect your data.**

AI coding tools like Claude, Gemini, and Aider have full access to your filesystem, environment variables, and terminal. This project sandboxes them in Docker containers with **strict security restrictions**.

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
| **qwen** | ✅ | npm/Bun | Alibaba Qwen CLI |
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