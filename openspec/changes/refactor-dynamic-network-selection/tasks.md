# Tasks: Dynamic Network Selection

## 1. Remove Legacy Network System

- [x] 1.1 Delete `bin/ai-network` file
- [x] 1.2 Remove `~/.ai-networks` file reading from `bin/ai-run` (lines 157-189)
- [x] 1.3 Remove MetaMCP auto-detection from `bin/ai-run` (lines 191-274)
- [x] 1.4 Remove MetaMCP Access Method menu from `setup.sh` (lines 234-289)
- [x] 1.5 Remove `ai-network` symlink creation from `setup.sh` (not present)

## 2. Implement Config Management

- [x] 2.1 Create config directory structure (`~/.ai-sandbox/`)
- [x] 2.2 Implement `read_network_config()` function in `bin/ai-run`
  - Read `~/.ai-sandbox/config.json`
  - Parse with `jq` (with fallback)
  - Return networks for current workspace or global
- [x] 2.3 Implement `write_network_config()` function in `bin/ai-run`
  - Create/update config.json
  - Support workspace-specific and global writes
  - Preserve existing config entries
- [x] 2.4 Implement `validate_networks()` function
  - Check each network exists with `docker network inspect`
  - Return only valid networks (silent skip for missing)

## 3. Implement Network Discovery

- [x] 3.1 Implement `discover_compose_networks()` function
  - Use `docker network ls --filter "label=com.docker.compose.project"`
  - Return list of compose network names
- [x] 3.2 Implement `discover_custom_networks()` function
  - List all networks except: bridge, host, none, and compose networks
  - Return list of custom network names
- [x] 3.3 Implement `get_network_containers()` function
  - Use `docker network inspect <network> --format`
  - Return comma-separated container names

## 4. Implement Interactive Selection

- [x] 4.1 Implement `show_network_menu()` function
  - Display grouped networks (Compose / Other / None)
  - Show container names in parentheses
  - Support multi-select with SPACE
  - Support arrow key navigation
  - Return selected network names
- [x] 4.2 Implement `show_save_prompt()` function
  - Display save options (workspace / global / don't save)
  - Return user choice
- [x] 4.3 Wire up menu to `-n` flag without arguments

## 5. Implement CLI Flag

- [x] 5.1 Add `-n` / `--network` flag parsing to `bin/ai-run`
- [x] 5.2 Handle `-n` without argument (trigger interactive menu)
- [x] 5.3 Handle `-n net1,net2` (direct network specification)
- [x] 5.4 Integrate networks into Docker run command (`--network` flags)

## 6. Update Documentation

- [x] 6.1 Update README.md network section
  - Remove `ai-network` command references
  - Add `-n` flag documentation
  - Add config file location
  - Update examples
- [x] 6.2 Update METAMCP_GUIDE.md
  - Remove setup-time configuration
  - Add runtime selection examples
- [x] 6.3 Update AGENTS.md network-related content

## 7. Testing & Verification

- [x] 7.1 Syntax verification: `bash -n bin/ai-run` passes
- [x] 7.2 Syntax verification: `bash -n setup.sh` passes
- [x] 7.3 Legacy cleanup: No references to `~/.ai-networks` or `ai-network` remain
- [ ] 7.4 Manual test: `ai-run opencode` with no config (requires Docker on host)
- [ ] 7.5 Manual test: `ai-run opencode -n` shows interactive menu
- [ ] 7.6 Manual test: `ai-run opencode -n network_name` joins specified network
- [ ] 7.7 Manual test: Save to workspace, verify config.json updated
- [ ] 7.8 Manual test: Save to global, verify config.json updated

## 8. Cleanup

- [x] 8.1 Remove any remaining references to `~/.ai-networks`
- [x] 8.2 Remove any remaining references to `ai-network` command
- [x] 8.3 Verify no orphaned code paths

## Future TODO (Out of Scope)

- [ ] CI/CD mode: `AI_NETWORKS=net1,net2` environment variable for non-interactive use
