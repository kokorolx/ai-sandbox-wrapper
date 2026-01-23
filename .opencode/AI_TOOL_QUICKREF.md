# AI Tool - Quick Reference Card

**For AI coding assistants running in Docker sandbox**

## Host Services Access

When you need to connect to services on the **host machine**, use `host.docker.internal` instead of `localhost`.

```python
# ❌ Wrong - this is the container itself
requests.get("http://localhost:12008/metamcp/...")

# ✅ Correct - this reaches the host machine
requests.get("http://host.docker.internal:12008/metamcp/...")
```

## Common Host Services

| Service | Host Address | Port | Example |
|---------|--------------|------|---------|
| MetaMCP | `host.docker.internal` | 12008 | `http://host.docker.internal:12008/metamcp/default/sse` |
| PostgreSQL | `host.docker.internal` | 5432 | `psycopg2.connect(host="host.docker.internal", ...)` |
| Redis | `host.docker.internal` | 6379 | `redis.Redis(host="host.docker.internal", ...)` |
| MongoDB | `host.docker.internal` | 27017 | `mongodb://host.docker.internal:27017/` |

## Environment Variables (Already Set)

These are available in your environment:

```bash
# Check them with:
echo $MCP_HOST
echo $MCP_PORT
echo $METAMCP_URL
```

## Connecting to MetaMCP

**Example connection URL:**
```
http://host.docker.internal:12008/metamcp/default/sse
```

**For Claude Code (.claude.json):**
```json
{
  "mcpServers": {
    "MetaMCP": {
      "url": "http://host.docker.internal:12008/metamcp/default/sse"
    }
  }
}
```

## Important Notes

1. **localhost ≠ host machine** - Inside the container, localhost is the container itself
2. **host.docker.internal is pre-configured** - No need to modify /etc/hosts
3. **Ports must be exposed on host** - The service must be listening on the host's network interface
4. **Use environment variables** - They're already set for commonly used services

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection refused" | Check if service is running on host: `docker ps` |
| "Name resolution failed" | Use `host.docker.internal` explicitly |
| "Port not found" | Verify port in service configuration |
| "Permission denied" | Check if service binds to 127.0.0.1 only |

## Quick Test

```bash
# Test MetaMCP connectivity from inside container
curl -s http://host.docker.internal:12008/health
# Expected response: {"status":"ok"} or similar

# Your container is named after the project folder
# Example: opencode-my-project, claude-test-app
docker ps | grep opencode
```
