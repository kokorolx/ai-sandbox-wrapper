# Design: Dynamic Network Selection

## Context

AI Sandbox Wrapper runs AI coding tools in Docker containers. These containers often need to communicate with other services (databases, APIs, MetaMCP servers) running in Docker networks.

Current implementation has grown organically with multiple overlapping mechanisms:
1. Setup-time menu in `setup.sh`
2. Runtime auto-detection for MetaMCP
3. Separate `ai-network` CLI tool
4. Flat file storage (`~/.ai-networks`)

This creates confusion and inflexibility.

## Goals

- **Simplicity**: Single mechanism for network configuration
- **Discoverability**: Show available networks with context (containers inside)
- **Flexibility**: Per-workspace and global configuration
- **Runtime control**: Configure at run time, not setup time

## Non-Goals

- CI/CD automation (future TODO)
- Network creation/deletion
- Advanced Docker networking (overlay, macvlan)

## Decisions

### Decision 1: Single Config File (`~/.ai-sandbox/config.json`)

**Why JSON:**
- Human-readable and editable
- Native parsing in shell via `jq` (already common dependency)
- Extensible for future settings
- Standard format, no custom parsing

**Schema:**
```json
{
  "version": 1,
  "networks": {
    "global": ["network-name-1"],
    "workspaces": {
      "/absolute/path/to/project": ["network-1", "network-2"]
    }
  }
}
```

**Alternatives considered:**
- YAML: Requires additional parser, overkill for simple config
- TOML: Less common, shell parsing harder
- Flat files: Current approach, lacks structure

### Decision 2: Network Discovery via Docker Labels

**Compose networks** are identified by label `com.docker.compose.project`:
```bash
docker network ls --filter "label=com.docker.compose.project" --format "{{.Name}}"
```

**Custom networks** are everything else except system networks (bridge, host, none).

**Container listing** via:
```bash
docker network inspect <network> --format '{{range .Containers}}{{.Name}} {{end}}'
```

### Decision 3: Flag Behavior Matrix

| Command | Behavior |
|---------|----------|
| `ai-run opencode` | Use saved networks (workspace > global > none), silent |
| `ai-run opencode -n` | Interactive selector, then save prompt |
| `ai-run opencode -n net1,net2` | Use specified networks directly, no prompt, no save |

**Rationale:**
- No flag = fast, use saved config
- Flag without args = interactive discovery
- Flag with args = explicit override (scripting friendly)

### Decision 4: Interactive Menu UX

```
$ ai-run opencode -n

Discovering Docker networks...

Compose Networks:
  [ ] my-app_default (postgres, redis, web)
  [ ] metamcp_metamcp-network (metamcp-server)

Other Networks:
  [ ] shared-services

  [x] None (no network)

Use arrow keys to move, SPACE to select, ENTER to confirm

Save selection?
  > This workspace (/Users/tamlh/projects/my-app)
    Global (all workspaces)
    Don't save
```

**Key UX decisions:**
- "None" is pre-selected (secure default)
- Compose networks listed first (most common use case)
- Container names shown in parentheses (helps identification)
- Workspace path shown in save prompt (clarity)

### Decision 5: Network Validation Strategy

**On startup (silent):**
- Read saved networks from config
- Validate each with `docker network inspect`
- Skip non-existent networks silently (no error, no warning)
- Continue with valid networks only

**Rationale:** Networks come and go (docker-compose down). Failing loudly would be annoying. User can re-run with `-n` to update.

### Decision 6: Files to Remove

| File | Reason |
|------|--------|
| `bin/ai-network` | Replaced by `-n` flag |
| `~/.ai-networks` | Replaced by `~/.ai-sandbox/config.json` |
| `setup.sh` MetaMCP menu | Replaced by runtime selection |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Breaking change for existing users | Clear migration docs, simple re-configuration |
| `jq` dependency | Already common, fallback to grep/sed if needed |
| Config file corruption | Version field for future migrations, simple schema |

## Migration Plan

1. Remove old code (clean break)
2. First run with `-n` prompts for configuration
3. Document in README and CHANGELOG
4. No automatic migration of `~/.ai-networks`

## Open Questions

- [ ] **TODO**: Non-interactive mode for CI/CD (e.g., `AI_NETWORKS=net1,net2` env var)
- [ ] Future: Should we support network aliases/shortcuts?
