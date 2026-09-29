# Enterprise Helix

Claude Code uses the same MCP server for this local proof of concept and for a company Helix server. The server address lives in `.p4config`, which stays on the machine and is not submitted.

Developers who receive the connector zip double-click `Install Claude Helix.cmd` and use the setup window. See `share/HOW-TO-INSTALL.md`. The steps below are the same connection, written as commands.

## Point Claude at the company server

1. Copy `.p4config.template` to `.p4config` if that file is not already in the workspace root.
2. Set the company values:

```text
P4PORT=ssl:helix.example.com:1666
P4USER=your.standard.user
P4CLIENT=your_workspace_name
P4IGNORE=.p4ignore
```

Use `ssl:` when the Helix server requires TLS. On a unicode server, add `P4CHARSET=utf8` (or the charset your admin gives you). Leave `P4CHARSET` unset on a non-unicode server. Do not add `P4PASSWD`.

3. From this directory:

```powershell
p4 trust
p4 login
powershell -File scripts\check-enterprise.ps1
```

`p4 trust` is once per machine for that server. `p4 login` refreshes the ticket Claude uses. The check script reports the port, user type, ticket, and whether the client host matches this PC.

4. Open this folder in Claude Code and approve `perforce-p4-mcp`.

`.mcp.json` starts `scripts/start-p4mcp.cmd`. That launcher loads `.p4config`, refuses a service user, refuses a password stored in the file, and exits if the ticket is missing. It does not send usage telemetry.

## What stays the same

- Checkout and submit stay enabled. Skills still submit only when you ask.
- The Helix user in `.p4config` must be type `standard`.
- SSO in P4V is for people. Claude reuses the ticket from `p4 login`. Keep `auth.sso.allow.passwd=1` until a ticket login works for that user. See `docs/HELIX-AUTH-EXTENSION.md`.
- `.p4config`, `.env`, and `secrets/` are denied to Claude in `.claude/settings.json`, and `.p4ignore` keeps them out of the depot.

## Air-gapped machines

`uvx` downloads `p4mcp-server` from the network the first time. On a machine that cannot do that, install the Windows build of the MCP server and set `P4MCP_BIN` to the full path of `p4-mcp-server.exe` before starting Claude Code. The launcher runs that executable instead of `uvx`.

## Client host

If the client spec has `Host:` set, it must be this computer's name. `scripts/check-enterprise.ps1` compares them. A client created on another PC will not sync here until `Host` is updated or cleared in P4V.

## Admin controls

These are server properties, not files in this workspace. An admin can turn MCP writes off for a group without changing Claude:

```text
p4 property -a -n mcp.toolsets.write -v false -g reviewers
```

Review tools need P4 Code Review (Swarm). They are available with the default server and fail only when called on a server that has no Swarm.
