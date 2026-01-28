## REMOVED Requirements

### Requirement: Legacy Network File Support
**Reason**: Replaced by centralized config at `~/.ai-sandbox/config.json`
**Migration**: Users re-configure networks using `ai-run <tool> -n` on first run

### Requirement: MetaMCP Auto-Detection
**Reason**: Replaced by dynamic network discovery and user selection
**Migration**: Users select networks explicitly via `-n` flag

## ADDED Requirements

### Requirement: Network Selection Flag
The container runtime (`bin/ai-run`) SHALL support a `-n` / `--network` flag for runtime network configuration.

#### Scenario: Interactive network selection
- **WHEN** user runs `ai-run opencode -n` (flag without argument)
- **THEN** the system SHALL discover available Docker networks
- **AND** display an interactive multi-select menu
- **AND** prompt to save selection after confirmation

#### Scenario: Direct network specification
- **WHEN** user runs `ai-run opencode -n network1,network2`
- **THEN** the system SHALL join the specified networks directly
- **AND** skip the interactive menu
- **AND** skip the save prompt

#### Scenario: No flag provided
- **WHEN** user runs `ai-run opencode` without `-n` flag
- **THEN** the system SHALL use saved networks from config (workspace-specific first, then global)
- **AND** silently skip any networks that no longer exist
- **AND** proceed without prompting

### Requirement: Network Discovery
The container runtime SHALL discover Docker networks dynamically and group them by type.

#### Scenario: Compose network detection
- **WHEN** discovering networks
- **THEN** networks with label `com.docker.compose.project` SHALL be grouped as "Compose Networks"
- **AND** container names within each network SHALL be displayed

#### Scenario: Custom network detection
- **WHEN** discovering networks
- **THEN** networks without compose labels (excluding bridge, host, none) SHALL be grouped as "Other Networks"

#### Scenario: Empty network list
- **WHEN** no Docker networks exist (besides system networks)
- **THEN** the menu SHALL show only the "None" option
- **AND** display a message indicating no networks found

### Requirement: Network Selection Menu
The container runtime SHALL provide an interactive menu for network selection.

#### Scenario: Menu display
- **WHEN** interactive selection is triggered
- **THEN** the menu SHALL display networks grouped by type
- **AND** show container names in parentheses for each network
- **AND** include a "None (no network)" option
- **AND** pre-select "None" as the default

#### Scenario: Multi-select support
- **WHEN** user is in the network selection menu
- **THEN** user SHALL be able to select multiple networks using SPACE key
- **AND** navigate using arrow keys
- **AND** confirm selection with ENTER key

### Requirement: Network Configuration Persistence
The container runtime SHALL persist network selections in `~/.ai-sandbox/config.json`.

#### Scenario: Workspace-specific save
- **WHEN** user selects "This workspace" in save prompt
- **THEN** networks SHALL be saved under `networks.workspaces["/absolute/path"]`
- **AND** only apply when running from that workspace

#### Scenario: Global save
- **WHEN** user selects "Global" in save prompt
- **THEN** networks SHALL be saved under `networks.global`
- **AND** apply to all workspaces without specific configuration

#### Scenario: Don't save
- **WHEN** user selects "Don't save" in save prompt
- **THEN** networks SHALL be used for current run only
- **AND** config file SHALL not be modified

#### Scenario: Config priority
- **WHEN** loading network configuration
- **THEN** workspace-specific config SHALL take priority over global config
- **AND** if workspace has empty array, no networks SHALL be joined (explicit override)

### Requirement: Network Validation
The container runtime SHALL validate configured networks before joining.

#### Scenario: Valid network
- **WHEN** a configured network exists
- **THEN** the container SHALL join that network

#### Scenario: Invalid network (silent skip)
- **WHEN** a configured network no longer exists
- **THEN** the system SHALL skip that network silently
- **AND** continue with remaining valid networks
- **AND** NOT display an error or warning

### Requirement: Host Access with Networks
The container runtime SHALL provide host access when joining networks.

#### Scenario: Network with host access
- **WHEN** container joins any Docker network
- **THEN** `--add-host=host.docker.internal:host-gateway` SHALL be added
- **AND** container can access host services via `host.docker.internal`
