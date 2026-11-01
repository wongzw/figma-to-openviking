# figma-to-openviking

An agent skill that imports Figma frames into [OpenViking](https://github.com/volcengine/OpenViking) as 2x PNGs, one file per screen, grouped by page and section, with a `manifest.md` that links every file back to its Figma node. Once imported, OpenViking writes a summary for each folder and a description for each screen, so your agent can find the right design instead of guessing.

## What you need

- An agent that supports skills (Claude Code, Codex, …)
- The Figma MCP server connected to that agent
- The OpenViking CLI (`pip install openviking`) connected to your OpenViking service

The skill checks all three on first run and walks you through anything missing ([setup.md](setup.md)).

## Install

```bash
git clone --branch v1.0.1 https://github.com/wongzw/figma-to-openviking.git ~/.claude/skills/figma-to-openviking
```

For other agents, clone into that agent's skills folder.

## Use

Send your agent a Figma link and ask it to import the designs into OpenViking. It will:

1. List the pages and ask which ones to import.
2. Ask where to store them (a shared folder or your personal one) and wait for your yes.
3. Run a 2-frame pilot, read it back, and estimate the token cost of the full import.
4. Import the rest after you confirm, then check that every file landed.

It only reads from Figma, never edits the images, and keeps emails, phone numbers, URLs and keys out of file names and the manifest.

## License

MIT. See [LICENSE](LICENSE).
