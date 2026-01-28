# Change: Refactor Network Configuration to Dynamic Runtime Selection

## Why

The current network configuration is fragmented and inflexible:
- Setup-time configuration via `setup.sh` MetaMCP menu (static, requires re-running setup)
- Runtime auto-detection only for `metamcp_metamcp-network` (hardcoded)
- Separate `ai-network` CLI tool for management (adds complexity)
- Configuration stored in flat `~/.ai-networks` file (no workspace awareness)

Users need dynamic network selection at runtime with workspace-level persistence, similar to how modern tools handle environment configuration.

## What Changes

### **BREAKING** - Remove Legacy Network System
- Remove `~/.ai-networks` file support
- Remove `bin/ai-network` CLI command
- Remove MetaMCP Access Method menu from `setup.sh`
- Remove hardcoded `metamcp_metamcp-network` auto-detection in `ai-run`

### Add Dynamic Network Selection
- Add `-n` / `--network` flag to `ai-run` for runtime network selection
- Discover Docker networks dynamically using `docker network ls`
- Group networks by type (Compose projects vs custom networks)
- Show container names within each network for context
- Support multi-select (join multiple networks)
- Support direct specification: `ai-run opencode -n net1,net2,net3`

### Add Centralized Configuration
- New config location: `~/.ai-sandbox/config.json`
- Store network preferences per-workspace (full path as key)
- Support global default networks
- Auto-validate networks on startup (skip non-existent silently)

### Add Save Prompt Flow
After interactive selection, prompt user:
1. **This workspace** (default) - Save for current project only
2. **Global** - Save as default for all workspaces
3. **Don't save** - One-time use

## Impact

- **Affected specs**: `container-runtime` (network requirements)
- **Affected code**:
  - `bin/ai-run` - Replace network logic (~120 lines), add `-n` flag
  - `bin/ai-network` - **DELETE** entire file
  - `setup.sh` - Remove MetaMCP menu section (~60 lines)
  - `README.md` - Update network documentation
  - `METAMCP_GUIDE.md` - Update integration instructions

## Migration

- Users with existing `~/.ai-networks` will see networks ignored (file no longer read)
- First run with `-n` flag will prompt for new configuration
- No automatic migration (clean break, simple mental model)

## Non-Goals

- CI/CD support (non-interactive mode) - marked as TODO for future
- Network creation (use `docker network create` directly)
- Container-to-container DNS resolution configuration
