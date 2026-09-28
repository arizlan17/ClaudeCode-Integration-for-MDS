# Helix Authentication Extension

## Current state

The extension is already installed on this local server:

- Name: `Auth::loginhook`
- Version: 2026.1
- Enabled: true
- `Auth-Protocol`: empty
- `Service-URL`: empty
- `auth.sso.allow.passwd`: 1

An empty service URL means login is not redirected to an identity provider. `p4 login` still issues a ticket, and that ticket is what the P4 MCP server uses. Do not fill in `Service-URL` until the authentication service and an IdP are actually running.

The user `svc_loginhook` exists because the extension package created it. Triggers are empty. There is no extra login trigger to configure for this proof of concept.

## Why Claude should keep using tickets

The extension, when it is fully configured, opens a browser and sends the user to the P4 Authentication Service, then to OIDC or SAML. The MCP server is not a browser. It authenticates with the ticket already stored for `P4USER`.

Keep `auth.sso.allow.passwd=1` while SSO is rolled out so `p4 login` continues to work for Claude. Humans can use SSO from P4V. Claude keeps using the standard user `arizlan` and a ticket.

`P4USER` must stay a `standard` user. A `service` user cannot run the commands the MCP server uses (`p4 describe`, `p4 changes`, and the rest). The launcher `scripts/start_p4mcp.py` refuses to start when the user type is `service`, when `.p4config` contains `P4PASSWD`, or when `p4 login -s` fails.

Company server address, SSL trust, and the ticket check are in `docs/ENTERPRISE.md`.

## When you are ready to turn SSO on

This needs three systems, not only the extension that is already installed. Perforce documents this in the helix-authentication-extension repo and the helix-authentication-service repo.

1. Run the P4 Authentication Service somewhere the Helix server can reach.
2. Register an OIDC or SAML identity provider on that service.
3. Configure the extension, do not reinstall it:

```text
p4 extension --configure Auth::loginhook -o
```

Set `Auth-Protocol` and `Service-URL`, then load the form back with `p4 extension --configure Auth::loginhook -i`.

4. Confirm a browser login from P4V.
5. Confirm `p4 login` still works for `arizlan` while `auth.sso.allow.passwd` is 1.
6. Run `p4 login -s` and then a Claude prompt that calls `query_server`. If the ticket check fails, Claude cannot submit, regardless of the MCP config.

Do not disable password login until that last check passes.
