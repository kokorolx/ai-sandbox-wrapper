# MetaMCP Integration Guide

**Connect AI tools to MetaMCP running on host with proper localhost mapping**

## Overview

When running AI coding tools (Claude, OpenCode, etc.) in the sandbox, they run inside Docker containers. Services running on your host machine (like MetaMCP) are not at `localhost` from inside the container.

**Solution:** Use `host.docker.internal` instead of `localhost`

## Quick Reference

### MetaMCP Connection

```bash
# From inside the AI tool container, MetaMCP is at:
http://host.docker.internal:12008/metamcp/<endpoint>/sse
```

### Environment Variables (Recommended)

Set these in your `~/.ai-env` file to auto-configure AI tools:

```bash
# MetaMCP configuration
MCP_HOST=host.docker.internal
MCP_PORT=12008
METAMCP_URL=http://host.docker.internal:12008/metamcp/default/sse

# Database connections (if using PostgreSQL on host)
POSTGRES_HOST=host.docker.internal
POSTGRES_PORT=5432

# Other host services
REDIS_HOST=host.docker.internal
REDIS_PORT=6379
```

## AI Tool Configuration

### OpenCode

OpenCode doesn't have a direct MCP configuration file like Claude, but you can:

**1. Use environment variables in your prompts:**
```
Use the MetaMCP server at http://host.docker.internal:12008/metamcp/default/sse
```

**2. Set environment variables:**
```bash
# Add to ~/.ai-env
METAMCP_URL=http://host.docker.internal:12008/metamcp/default/sse
```

### Claude Code

Claude uses `.claude.json` in your project:

```json
{
  "mcpServers": {
    "MetaMCP": {
      "url": "http://host.docker.internal:12008/metamcp/default/sse"
    }
  }
}
```

### Aider

Aider uses `.aider.conf` in your project:

```bash
# In your terminal before running aider
export MCP_SERVERS="metamcp|http://host.docker.internal:12008/metamcp/default/sse"
ai-run aider
```

## Common Patterns

### Pattern 1: Connect to MetaMCP

**Goal:** AI tool uses MetaMCP tools

**Setup:**
1. Join the MetaMCP Docker network at runtime
2. Use `host.docker.internal:12008` in MCP configuration

```bash
# Interactive network selection
ai-run opencode -n

# Direct network specification
ai-run opencode -n metamcp_metamcp-network
```

**In AI tool prompt:**
```
You have access to MetaMCP tools via http://host.docker.internal:12008/metamcp/default/sse
```

### Pattern 2: Connect to PostgreSQL on Host

**Goal:** AI tool queries database on host machine

**Setup:**
```bash
# In ~/.ai-env
POSTGRES_HOST=host.docker.internal
POSTGRES_PORT=5432
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
POSTGRES_DB=mydb
```

**AI tool can now use:**
```python
import psycopg2
conn = psycopg2.connect(
    host="host.docker.internal",  # Instead of localhost
    port=5432,
    user="myuser",
    password="mypassword",
    database="mydb"
)
```

### Pattern 3: Connect to Redis on Host

**Setup:**
```bash
# In ~/.ai-env
REDIS_HOST=host.docker.internal
REDIS_PORT=6379
```

**AI tool usage:**
```python
import redis
r = redis.Redis(
    host="host.docker.internal",  # Instead of localhost
    port=6379,
    decode_responses=True
)
```

### Pattern 4: Multiple Host Services

**Example `.env` file for complex setup:**
```bash
# ~/.ai-env

# API Keys
ANTHROPIC_API_KEY=sk-...
OPENAI_API_KEY=sk-...

# MetaMCP
MCP_HOST=host.docker.internal
MCP_PORT=12008

# Database
POSTGRES_HOST=host.docker.internal
POSTGRES_PORT=5432

# Cache
REDIS_HOST=host.docker.internal
REDIS_PORT=6379

# Message Queue
RABBITMQ_HOST=host.docker.internal
RABBITMQ_PORT=5672
```

## Troubleshooting

### "Connection refused" on port 12008

**Check if MetaMCP is running:**
```bash
# On host
docker ps | grep metamcp
curl http://localhost:12008/health
```

**Check network membership:**
```bash
docker network inspect metamcp_metamcp-network --format '{{range .Containers}}{{.Name}} {{end}}'
```

If your container is missing, run with the network flag:
```bash
ai-run opencode -n metamcp_metamcp-network
```

### "Name or service not known" for host.docker.internal

**This shouldn't happen** with our setup, but if it does:

```bash
# Manually add to container's /etc/hosts
ai-run --rm -it --add-host=host.docker.internal:host-gateway --entrypoint=/bin/bash ai-opencode

# Inside container, verify:
ping host.docker.internal
```

### Port already in use

If you see "Address already in use", the service might be running inside the container instead of on host:

```bash
# Check what's using the port inside container
ai-run opencode --entrypoint=/bin/bash
# Then inside:
netstat -tlnp | grep 12008
```

## Network Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      HOST MACHINE                           │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────────┐            │
│  │ MetaMCP         │    │ PostgreSQL          │            │
│  │ Port: 12008     │    │ Port: 5432          │            │
│  │ 127.0.0.1:12008 │    │ 127.0.0.1:5432      │            │
│  └────────┬────────┘    └──────────┬──────────┘            │
│           │                        │                       │
└───────────┼────────────────────────┼───────────────────────┘
            │                        │
    host.docker.internal:12008   host.docker.internal:5432
            │                        │
            ▼                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  AI TOOL CONTAINER                          │
│                                                             │
│  localhost → Container's own services                       │
│  host.docker.internal → Host machine services               │
│                                                             │
│  AI Tool can connect to:                                    │
│  - http://host.docker.internal:12008 (MetaMCP)              │
│  - http://host.docker.internal:5432 (PostgreSQL)            │
└─────────────────────────────────────────────────────────────┘
```

## Quick Commands

```bash
# Join MetaMCP network at runtime
ai-run opencode -n metamcp_metamcp-network

# Check if MetaMCP is running on host
docker ps | grep metamcp

# Test connection from host
curl http://localhost:12008/health

# List your AI tool containers (named by project folder)
docker ps --filter "name=opencode-" --filter "name=claude-" --filter "name=gemini-"
```

## Environment Variables Summary

| Variable | Example Value | Purpose |
|----------|---------------|---------|
| `MCP_HOST` | `host.docker.internal` | MCP server host |
| `MCP_PORT` | `12008` | MCP server port |
| `METAMCP_URL` | `http://host.docker.internal:12008/...` | Full MCP URL |
| `POSTGRES_HOST` | `host.docker.internal` | PostgreSQL host |
| `POSTGRES_PORT` | `5432` | PostgreSQL port |
| `REDIS_HOST` | `host.docker.internal` | Redis host |
| `REDIS_PORT` | `6379` | Redis port |
