#!/usr/bin/env bash
set -e

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_BIN="$PROJECT_ROOT/bin"

# The ai-run script already exists in bin/ai-run (version controlled)
# We just need to ensure it's executable and symlinked

chmod +x "$PROJECT_BIN/ai-run"

# Create symlink in user's bin directory
mkdir -p "$HOME/bin"
ln -sf "$PROJECT_BIN/ai-run" "$HOME/bin/ai-run"

echo "✅ ai-run script at $PROJECT_BIN/ai-run"
echo "✅ Symlinked to $HOME/bin/ai-run"
