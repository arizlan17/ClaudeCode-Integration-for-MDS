# Claude + Helix connector

Share this folder with developers. It connects Claude Code to the Helix server they already use, including Helix Auth. It does not contain a server address, a user name, or a password.

Each person installs it into their own client root. That root can be any drive and any workspace.

## What each developer needs

- P4 CLI, already able to reach the company Helix server
- Claude Code, signed in
- Python (`py` or `python`)
- `uv` so `uvx` can start the MCP server, or `p4-mcp-server.exe` from your admin

## Install

Unzip this package. Double-click **Install Claude Helix.cmd**.

Fill in the client folder, Helix server, user, client name, and the main, dev, and features depot paths. The user must be a standard Helix user. Then click, in order:

1. **Install**
2. **Trust server** (only needed when the server starts with `ssl:`)
3. **Sign in** — the company browser opens. Finish Helix Auth there. This window cannot sign in by itself.
4. **Check**

The window writes `.p4config` and `.claude\helix-lines.local` only in the client folder. Those files stay on that PC.

Open that same client folder in Claude Code and approve `perforce-p4-mcp`. That approval is one click inside Claude Code.

When the Helix ticket expires, open **Install Claude Helix.cmd** again, choose the same folder, and click **Sign in**.

## How work is done

Claude reads, checks out, edits, shelves, and submits through Helix. Feature edits go under the FEATURES path, not on MAIN or DEV. Claude shelves the changelist and waits for a person to review before integrating back.

Ask Claude: "Use codebase-reader. Explain this service. Do not edit anything."

## Scripted install

The same setup can be run without the window:

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

Then click **Trust server** and **Sign in** in the window, or run `p4 trust` and `p4 login` in the client folder.
