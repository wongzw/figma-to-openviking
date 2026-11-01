# Setup (first run)

Do only the items whose check failed in SKILL.md step 0. Each ends with its own check.

## 1. Figma MCP

The official Figma MCP server gives the agent `whoami`, `get_metadata`, `use_figma` and `download_assets`.

| Agent | Install |
|---|---|
| Claude app / claude.ai | Settings → Connectors → Figma → Connect, then sign in |
| Claude Code | `claude mcp add --transport http figma https://mcp.figma.com/mcp`, then `/mcp` → figma → Authenticate |
| Codex | `codex mcp add figma --url https://mcp.figma.com/mcp`, then sign in when prompted |

Check: `whoami` returns the user's handle. The account needs at least view access to the file; if a read fails with a permission error, ask the file owner to share it.

## 2. OpenViking CLI

```bash
pip install openviking        # or: uv tool install openviking
ov --version
```

The package is published by volcengine (github.com/volcengine/openviking). Connect it to the user's OpenViking service. The user gets an API key from the OpenViking console's API Key page and enters it themselves; it is read from the terminal so it never lands in shell history or the agent transcript:

```bash
read -rs OV_KEY && printf '%s' "$OV_KEY" | ov config add ov-service --api-key-stdin --activate; unset OV_KEY
```

For a self-hosted server: `ov config add custom --name local --url http://127.0.0.1:1933 --activate`.

Never ask the user to paste the key into chat, and never print `~/.openviking/ovcli.conf`.

Check: `ov health` shows `Connected (Healthy)`. Then confirm write access in the user's personal space:

```bash
ov mkdir viking://user/<me>/resources/_ov-write-check && ov rm viking://user/<me>/resources/_ov-write-check --recursive
```

Write access to a shared destination is tested by the pilot run (SKILL.md step 5). If the pilot can't write there, ask an admin for access or choose the personal destination.

## 3. Local tools

`curl` and `python3` (3.8+, standard library only). macOS has both. Behind a corporate HTTPS proxy, if curl fails with certificate errors, point it at the proxy's CA bundle: `export SSL_CERT_FILE=/path/to/ca.pem`.
