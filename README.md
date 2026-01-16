# AI Sandbox Setup

This script sets up a Docker-based AI sandbox environment with tools like amp, opencode, and droid. It automatically installs required dependencies like git and Python if missing, and ensures Docker is available.

## Usage

Run `./setup.sh` to set up the environment.

It will prompt for a workspace directory, install dependencies (git, python3), create necessary directories, build Docker images for AI tools, and configure shell aliases.

## Requirements

- Docker Desktop (required)
- Linux/macOS with apt (for dependency installation)

## Tools Included

- **amp**: AI coding assistant from @sourcegraph/amp
- **opencode**: Open-source coding tool from opencode-ai
- **droid**: Automation tool from droid-factory

## Configuration

After setup, edit `$HOME/.ai-env` with your API keys (OPENAI_API_KEY, ANTHROPIC_API_KEY).

The workspace is locked to the specified directory for security.

## Supported Configs

Per-project configurations:
- `.amp.json`
- `.opencode.json`
- `.droid.json`