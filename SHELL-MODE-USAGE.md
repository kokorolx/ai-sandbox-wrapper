# Shell Mode Usage Guide

## Overview

The `ai-run` command now supports two execution modes:

### 1. Direct Mode (Default)
Runs the AI tool directly. Container exits when tool exits (Ctrl+C stops both tool and container).

```bash
# Run tool directly
ai-run opencode

# Run with arguments
ai-run claude --help
```

**Use case:** Quick one-off commands, CI/CD pipelines

### 2. Shell Mode (Interactive)
Starts a bash shell inside the container. AI tool is available to run manually. Container persists until you exit the shell.

```bash
# Start shell mode
ai-run opencode --shell
# or
ai-run opencode -s
```

**Use case:** Development sessions, iterative workflows, debugging

## Shell Mode Examples

### Basic Workflow

```bash
$ ai-run opencode --shell

🚀 AI Tool Container - Interactive Shell
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tool available: opencode
Run the tool: opencode
Exit container: exit or Ctrl+D

Additional tools:
  - specify (spec-kit): Spec-driven development
  - uipro (ux-ui-promax): UI/UX design intelligence
  - openspec: OpenSpec workflow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

agent@container:/workspace$ opencode
# OpenCode starts...
# Press Ctrl+C to stop OpenCode
^C

agent@container:/workspace$ opencode
# Run OpenCode again without recreating container!

agent@container:/workspace$ specify --help
# Use additional tools

agent@container:/workspace$ exit
# Exit and remove container
```

### Why Use Shell Mode?

#### Problem with Direct Mode
```bash
$ ai-run opencode
# OpenCode is running...
# You press Ctrl+C
^C
# Container is destroyed!
# To run again, you need to:
$ ai-run opencode  # Recreates entire container (slow)
```

#### Solution: Shell Mode
```bash
$ ai-run opencode --shell
agent@container:/workspace$ opencode
# OpenCode is running...
# You press Ctrl+C
^C
agent@container:/workspace$ opencode  # Run again instantly!
agent@container:/workspace$ opencode  # And again!
agent@container:/workspace$ exit      # When you're done
```

## Comparison

| Feature | Direct Mode | Shell Mode |
|---------|-------------|------------|
| **Command** | `ai-run opencode` | `ai-run opencode --shell` |
| **Tool starts** | Immediately | Manually (type tool name) |
| **Ctrl+C behavior** | Exits container | Stops tool only |
| **Restart tool** | Need to re-run `ai-run` | Just type tool name again |
| **Container lifetime** | Same as tool | Until you type `exit` |
| **Best for** | One-off commands | Interactive sessions |
| **Speed** | Fast initial run | Fast restarts |

## Advanced Usage

### Multiple Tool Sessions

```bash
# Shell mode lets you switch between tools
$ ai-run opencode --shell
agent@container:/workspace$ opencode
# ... work with opencode ...
^C
agent@container:/workspace$ specify
# ... work with spec-kit ...
agent@container:/workspace$ uipro init
# ... use UI/UX tool ...
agent@container:/workspace$ exit
```

### Debugging Workflow

```bash
# Perfect for debugging configurations
$ ai-run claude --shell
agent@container:/workspace$ cat ~/.claude/config.json
agent@container:/workspace$ claude --version
agent@container:/workspace$ claude --help
agent@container:/workspace$ claude  # Try it
^C
agent@container:/workspace$ nano ~/.claude/config.json  # Edit config
agent@container:/workspace$ claude  # Try again with new config
agent@container:/workspace$ exit
```

### Development Workflow

```bash
# Working on a project that requires frequent tool restarts
$ cd ~/projects/my-app
$ ai-run opencode --shell

agent@container:/workspace/my-app$ opencode
# ... make some changes ...
# Need to restart OpenCode to apply new .opencode config
^C
agent@container:/workspace/my-app$ opencode  # Restart instantly
# ... continue working ...
^C
agent@container:/workspace/my-app$ git status
agent@container:/workspace/my-app$ git diff
agent@container:/workspace/my-app$ exit
```

## Tips

1. **Use shell mode for development**: When you're actively working on a project and need to restart tools frequently
2. **Use direct mode for automation**: Scripts, CI/CD, one-off commands
3. **Exit cleanly**: Always use `exit` or Ctrl+D to properly clean up the container
4. **Container name**: In shell mode, container is named `{tool}-{folder}-{random}` for easy identification

## Troubleshooting

### "Container name already in use"
If you exit shell mode uncleanly, the container might still be running:
```bash
docker ps  # Find the container
docker stop {container-name}
```

### Lost in the container?
```bash
# Check where you are
pwd

# See what's mounted
df -h

# Exit anytime
exit
```

### Tool not found in shell mode?
```bash
# Check if tool is installed
which opencode

# Check PATH
echo $PATH

# Try with full path
/usr/local/bin/opencode
```
