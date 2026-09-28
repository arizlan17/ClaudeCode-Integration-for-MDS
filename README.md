# Claude Code + P4 Helix proof of concept

Local Helix Core is already installed on this machine. This workspace is the depot path `//depot/poc/...`, client `p4_imp_poc`, user `arizlan`, server `localhost:1666`.

Claude Code talks to Helix through the official [P4 MCP server](https://github.com/perforce/p4mcp-server). Checkout and submit are enabled (the server is not started with `--readonly`).

## What is in this workspace

| Path | Purpose |
| --- | --- |
| `.mcp.json` | Claude Code MCP server entry |
| `.cursor/mcp.json` | Same server for Cursor |
| `config/claude_desktop_config.fragment.json` | Fragment to merge into Claude Desktop, if you install it |
| `.p4config.template` | Connection template. The real `.p4config` stays local |
| `CLAUDE.md` | Rules Claude Code loads for this workspace |
| `.claude/skills/` | Helix, Java, Spring Boot, and Spring Batch procedures |
| `.claude/agents/` | Reader, submitter, resolver, reviewer, and the two dev agents |
| `sample/batch-hello/` | Small Spring Batch job used to prove add and submit |
| `docs/USING-CLAUDE-CODE.md` | How the connection works, how to connect, and how to use it |
| `docs/ENTERPRISE.md` | How to point the same MCP server at a company Helix server |
| `docs/WALKTHROUGH.md` | What was set up on this machine, and how it was proved |

## Open it in Claude Code

The full steps are in `docs/USING-CLAUDE-CODE.md`. Short version:

1. `p4 login` if `p4 login -s` says the ticket expired.
2. Open `D:\P4 imp` in Claude Code.
3. Approve the `perforce-p4-mcp` project MCP server when prompted.
4. Ask: "What Perforce server and client am I connected to?"
