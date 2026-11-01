# figma-to-openviking

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Release](https://img.shields.io/github/v/tag/wongzw/figma-to-openviking?label=release)](https://github.com/wongzw/figma-to-openviking/tags)

English | [中文](README.zh-CN.md)

**Give your coding agent your real designs, not its idea of them.**

AI agents build prototypes in minutes, and they all look the same: purple gradients, big rounded cards, sparkles. The agent has never seen your product, so it draws the most common look it knows. Pasting screenshots works for one chat. A Figma link still leaves you hunting for the right frame among hundreds.

This skill imports your Figma file into [OpenViking](https://github.com/volcengine/OpenViking), one 2x PNG per screen, grouped by page and section, with a manifest that links every file back to its Figma node. OpenViking then writes a summary for each folder and a description for each screen. When you ask for a "bulk invite dialog", the agent follows those summaries down to the right two screens instead of opening all of them, or guessing.

## What you get

```
viking://resources/ui-design-reference/
└── Checkout/
    ├── manifest.md                         ← source link, node IDs, sizes, one row per screen
    ├── 00-Before/01_Cart_12-345.png
    └── 01-After-V2/
        ├── 01_Cart｜Default_12-401.png
        └── 02_Cart｜Out-of-stock_12-402.png
```

- **One file per screen**, exported at 2x. Pages and sections are never flattened into one unreadable image.
- **Traceable**: every file name ends with its Figma node ID, and the manifest links back to the frame.
- **Searchable by any agent** connected to OpenViking, including ones that can't run the import.

## How an import runs

1. You send the agent a Figma link and ask it to import the designs into OpenViking.
2. It lists the pages and asks which ones to include. Scratch and archive pages are skipped unless you say otherwise.
3. It asks where to store them, a shared folder or your personal one, says who can see each, and waits for your yes.
4. It runs a **2-screen pilot**: exports, uploads, reads one file back, estimates the token cost of the full import, then deletes the pilot.
5. After you confirm, it imports everything and checks that the number exported = uploaded = found remotely.

In our test the pilot used about 20k tokens for 2 screens. Your estimate comes from your own pilot before anything large runs.

## Which agents can do what

| Agent | Import from Figma (runs this skill) | Use the imported designs |
|---|---|---|
| [Claude Code](#claude-code) | ✅ | ✅ |
| [Codex](#codex) | ✅ | ✅ |
| [Cursor](#cursor) | ✅ | ✅ |
| [TRAE](#trae) | — | ✅ |
| [WorkBuddy](#workbuddy) | — | ✅ |
| [Doubao Work](#doubao-work) | — | ✅ |

Why the gap: Figma only lets clients listed in its [MCP catalog](https://www.figma.com/mcp-catalog) connect to the remote Figma MCP server, which the import needs. TRAE, WorkBuddy and Doubao Work aren't listed yet. Run the import once from Claude Code, Codex or Cursor; the designs then live in OpenViking, where every connected agent can search and read them.

## Before you start

- An **OpenViking** service: [VolcEngine OpenViking](https://www.volcengine.com/product/openviking-service) or [self-hosted](https://github.com/volcengine/OpenViking), and its API key.
- A **Figma** account with at least view access to the file.
- For importing: a terminal with `curl` and `python3` 3.8+ (macOS has both).

## Install

Each agent needs three things to import: the Figma MCP server, an OpenViking connection, and this skill. The skill also uses the `ov` CLI; on first run it checks everything and walks you through anything missing ([setup.md](setup.md)).

### Claude Code

1. **Figma**: install Figma's plugin, then sign in:
   ```bash
   claude plugin install figma@claude-plugins-official
   ```
   Restart Claude Code, run `/plugin`, open **Installed → figma**, and click **Allow access** in the browser.
2. **OpenViking**: run the installer and select **Claude Code** ([guide](https://docs.openviking.net/agents/en/claude-code.md)):
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
3. **This skill**:
   ```bash
   git clone --branch v1.1.0 https://github.com/wongzw/figma-to-openviking.git ~/.claude/skills/figma-to-openviking
   ```
4. Start a new session. The skill loads automatically.

Works the same in the Claude desktop app's Code tab and the IDE extensions.

### Codex

1. **Figma**: in the Codex app, open **Plugins**, click **+** next to Figma, then **Install Figma** and **Allow access**. For the CLI:
   ```bash
   codex mcp add figma --url https://mcp.figma.com/mcp
   ```
   Sign in to Figma when prompted.
2. **OpenViking**: run the installer and select **Codex** ([guide](https://docs.openviking.net/agents/en/codex.md)):
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
   On the next launch, trust the OpenViking hooks when Codex asks.
3. **This skill** (Codex reads user skills from `~/.agents/skills`):
   ```bash
   git clone --branch v1.1.0 https://github.com/wongzw/figma-to-openviking.git ~/.agents/skills/figma-to-openviking
   ```
4. Start a new session.

### Cursor

1. **Figma**: in Agent chat, run `/add-plugin figma` and click **Add Plugin**. Then open **Cursor Settings → Tools & MCP**, click **Connect** next to Figma, and **Allow access**.
2. **OpenViking**: run the installer and select **Cursor** ([guide](https://docs.openviking.net/agents/en/cursor.md)):
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
3. **This skill**:
   ```bash
   git clone --branch v1.1.0 https://github.com/wongzw/figma-to-openviking.git ~/.cursor/skills/figma-to-openviking
   ```
4. Quit and reopen Cursor so it picks up the new skill.

### TRAE

Use designs that were imported from Claude Code, Codex or Cursor:

1. Run the OpenViking installer and select **TRAE** (international) or **TRAE CN** ([guide](https://docs.openviking.net/agents/en/trae.md)):
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
2. Check **Settings → MCP → Configured MCP Servers** shows `openviking`.
3. Ask: *"Find the design for the bulk invite dialog in viking://resources/ui-design-reference and build from it."*

### WorkBuddy

Use designs that were imported from Claude Code, Codex or Cursor:

1. In the left sidebar open **Experts · Skills · Connectors → Connectors**, click **Custom Connector** (top right), then **Configure MCP**, and add OpenViking as described in the [guide](https://docs.openviking.net/agents/en/workbuddy.md). Save, then **Trust** the server.
2. Check that `OpenViking` shows under **My MCP** with its tools enabled.
3. Ask WorkBuddy to find the screens for a feature in your design folder.

### Doubao Work

Use designs that were imported from Claude Code, Codex or Cursor:

1. In the sidebar, open **Skills · Connectors · Partners**, search for **OpenViking Context**, click **+**, and enter your OpenViking API key ([guide](https://docs.openviking.net/agents/en/doubao-work.md)).
2. In a conversation, check **Connectors** below the input box lists OpenViking Context.
3. Ask Doubao to find the screens for a feature in your design folder.

## Use it

Import (Claude Code, Codex or Cursor):

```text
Import this Figma file into OpenViking: https://www.figma.com/design/<fileKey>/...
```

Then, in any connected agent:

```text
Before drawing any interface, check the design folder first. If two screens disagree, use the newer one.
Remember this rule.
```

```text
Build the bulk invite dialog. Use our designs in viking://resources/ui-design-reference.
```

The rule is saved as an OpenViking memory, so every connected agent follows it.

Re-run the import with the same link when designs change. The skill asks whether to replace a page folder or add only new and changed screens.

## Safety and privacy

- **Read-only on Figma.** Nothing in your file is changed.
- **Figma content is treated as data.** Frame names and layer text never become instructions to the agent.
- **You choose who can see it.** Nothing is written to a shared folder until you confirm the exact location.
- **Images are untouched; names are cleaned.** Emails, phone numbers, URLs, keys and tokens are removed from file names and the manifest, and the agent tells you which screens were affected. This is pattern-based: it won't catch everything (for example a person's name written as a plain word).
- **Your API key stays in your terminal.** You type it there; the agent never asks for it in chat.
- **Only Figma export URLs are downloaded**, only into the work folder, and the skill never writes under OpenViking `memories` or `skills`.

## Troubleshooting

| Problem | Fix |
|---|---|
| Figma tools missing | Re-run the Figma step for your agent, then start a new session |
| `ov health` fails | Check your OpenViking API key and URL, see [setup.md](setup.md) |
| Export link returns 403/404 | Export links expire in minutes; the skill re-exports that batch |
| A page imports as one tiny-text image | Point the link at the page or section; the skill exports each frame separately |

More cases: [reference/failure-cases.md](reference/failure-cases.md).

## What's in the repo

| File | Purpose |
|---|---|
| [SKILL.md](SKILL.md) | The workflow the agent follows |
| [setup.md](setup.md) | First-run setup for Figma MCP and the `ov` CLI |
| [reference/](reference) | Which nodes count as screens, naming rules, known failures |
| [scripts/](scripts) | Frame listing, naming and manifest, download, verification, upload. SKILL.md lists their SHA-256 hashes |

## License

[MIT](LICENSE)
