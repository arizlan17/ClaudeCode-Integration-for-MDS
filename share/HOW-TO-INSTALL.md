# Claude + Helix connector

Share this folder with developers. It connects Claude Code to the Helix server they already use, including Helix Auth. It does not contain a server address, a user name, or a password.

Each person installs it into their own client root. That root can be any drive and any workspace.

## What each developer needs

- P4 CLI, already able to reach the company Helix server
- Claude Code, signed in
- Python (`py` or `python`)
- `uv` so `uvx` can start the MCP server, or `p4-mcp-server.exe` from your admin

## Install

Unzip this package, then run:

```powershell
powershell -File scripts\install-into-workspace.ps1 `
  -Destination "D:\path\to\their\client\root" `
  -P4Port "ssl:helix.company.com:1666" `
  -P4User "their.standard.user" `
  -P4Client "their_client_name" `
  -MainPath "//depot/service/main" `
  -DevPath "//depot/service/dev" `
  -FeaturesPath "//depot/service/features"
```

Use their real server, user, client, and depot paths. The user must be a standard Helix user.

The installer writes `.p4config` and `.claude\helix-lines.local` only in the destination. Those files stay on that PC.

## Sign in

In the destination folder:

```powershell
p4 trust
p4 login
p4 login -s
powershell -File scripts\check-enterprise.ps1
```

`p4 login` is the existing Helix Auth step. If SSO is on, the browser opens. Claude cannot do that login itself. It uses the ticket `p4 login` stores. When the ticket expires, run `p4 login` again.

Then open that same folder in Claude Code and approve `perforce-p4-mcp`.

## How work is done

Claude reads, checks out, edits, shelves, and submits through Helix. Feature edits go under the FEATURES path, not on MAIN or DEV. Claude shelves the changelist and waits for a person to review before integrating back.

Ask Claude: "Use codebase-reader. Explain this service. Do not edit anything."
