# Walkthrough

## Already on this machine

These were present before this workspace was filled in. Nothing was reinstalled.

| Piece | What it is |
| --- | --- |
| P4 CLI | `C:\Program Files\Perforce\p4.exe`, 2026.1 |
| P4V | `C:\Program Files\Perforce\p4v.exe` |
| P4 Server | Windows service `Perforce`, P4D 2026.1, root `D:\p4\`, port `1666` |
| Login | User `arizlan`, ticket already valid. `security` is 4, so a ticket is required |
| Helix Authentication Extension | Installed and enabled (`Auth::loginhook` 2026.1). `Auth-Protocol` and `Service-URL` are empty, so it is not sending anyone to an identity provider. `auth.sso.allow.passwd=1`, so password tickets still work |
| uv | `C:\Users\arizlan\.local\bin\uvx.exe`, used to run the MCP server |
| Claude Code config | `%USERPROFILE%\.claude` exists. The `claude` command is not on PATH. Perforce was not in Claude's MCP list |
| Claude Desktop | Not installed (`%APPDATA%\Claude` is missing) |

There is a separate client, `claude_workspace`, rooted at `D:\Perforce\claude_workspace`, with `//depot/app.py` and `//depot/app02.py`. This proof of concept does not change those files. It uses a new client and the depot path `//depot/poc/...`.

## What this workspace adds

1. Client `p4_imp_poc`, root `D:\P4 imp`, view `//depot/poc/...`.
2. `.p4config` so any `p4` command run in this folder selects that client. The file is not submitted.
3. `.mcp.json` so Claude Code starts `p4mcp-server` with write tools on.
4. The same MCP entry for Cursor, and a fragment for Claude Desktop.
5. `CLAUDE.md`, two skills, and three agents aimed at Java / Spring Batch work.
6. `sample/batch-hello`, a Spring Boot 3.4 / Spring Batch 5 job, submitted to the depot.

The server is started without `--readonly`, so Claude can check out and submit. The skills still refuse to submit unless you ask in that turn.

## Prove the depot from a terminal

From `D:\P4 imp`:

```powershell
p4 info
p4 login -s
p4 changes -m 5 //depot/poc/...
p4 files //depot/poc/sample/batch-hello/...
```

`p4 info` should show client `p4_imp_poc`. The server may advertise its address as `kubernetes.docker.internal:1666`. That is this same local service.

P4V: Open Connection, server `localhost:1666`, user `arizlan`, workspace `p4_imp_poc`.

## Already proved from this setup

- Change 11 added this workspace to `//depot/poc/...`.
- Change 12 checked out `HelloJobConfig.java` and submitted it through `p4mcp-server` 2026.4 (`modify_files` action `edit`, then `modify_changelists` action `submit`). The log line now says `Hello from the P4 Helix PoC job helloJob`.
- `query_server` returned user `arizlan`, client `p4_imp_poc`, root `D:\P4 imp`, and the server log said `connected` in read-write mode.

`uvx p4mcp-server --version` prints `2026.4.3078076`. That download is already done.

## Prove it again inside Claude Code

The `claude` command is not on PATH on this machine, even though `%USERPROFILE%\.claude` exists. Install or open Claude Code, then open the folder `D:\P4 imp`.

On first open, approve the project MCP server `perforce-p4-mcp`.

Prompts, in order:

1. Read. "Use the Perforce MCP tools. What server, user, and client are connected, and what is the latest changelist under //depot/poc/?"
2. Checkout and submit. "Check out HelloJobConfig.java, change the log line to say the changelist was submitted from Claude Code, and submit it. Description: batch: helloJob log line marks the Claude Code submit."

`p4 describe -du <new-changelist>` should show only that Java file.

The file is read-only on disk until checkout. If a save fails, Claude must `p4 edit` first. That rule is in `CLAUDE.md` and the `p4-helix` skill.

## Agents

In Claude Code you can ask for an agent by name:

- `p4-reader` for history, blame, and what changed. It does not open or submit files.
- `p4-submitter` when you want a changelist created and submitted.
- `spring-batch-dev` when the change is a job, step, reader, writer, or `application.yml`.

## Claude Desktop

The original ask included Claude Desktop. It is not installed here. After you install it, merge `config/claude_desktop_config.fragment.json` into `%APPDATA%\Claude\claude_desktop_config.json` and restart Desktop. Desktop does not load this folder's `CLAUDE.md` or `.claude/agents` the way Claude Code does. Use Claude Code for the skills and agents.

## What was left unchanged

- P4D, P4, and P4V were not reinstalled.
- The authentication extension was not pointed at an identity provider. There is no IdP on this machine, and a half-configured SSO login would block the ticket Claude uses. See `docs/HELIX-AUTH-EXTENSION.md`.
- `p4-config/typemap.txt` was not loaded. A typemap is server-wide and would also affect `//depot/app.py`.
- This config was not copied into other existing codebases. See `docs/ADOPT-EXISTING-CODEBASE.md`.
- MCP usage telemetry is off. `--allow-usage` is omitted.
