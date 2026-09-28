# P4 MCP tool map

Server name: `perforce-p4-mcp`. Package: `p4mcp-server` (Perforce, via `uvx`).

Write tools are available only when the server is started without `--readonly`. This PoC starts it that way so checkout and submit work. Still submit only when the user asked.

## Read

| Need | Tool | Action |
| --- | --- | --- |
| Server and user | `query_server` | `server_info`, `current_user` |
| Workspaces | `query_workspaces` | `list`, `get`, `status` |
| Changelists | `query_changelists` | `list`, `get` |
| File contents, history, blame, search | `query_files` | `content`, `history`, `info`, `diff`, `annotations`, `search`, `grep` |
| Shelves | `query_shelves` | `list`, `diff`, `files` |

## Write

| Need | Tool | Action |
| --- | --- | --- |
| Checkout / add / delete / sync / revert | `modify_files` | `edit`, `add`, `delete`, `move`, `revert`, `sync`, `reconcile`, `resolve` |
| Create or submit a changelist | `modify_changelists` | `create`, `update`, `submit`, `move_files` |
| Shelve | `modify_shelves` | `shelve`, `unshelve`, `delete` |

## CLI equivalents

| MCP | CLI |
| --- | --- |
| `modify_files` `edit` | `p4 edit <path>` |
| `modify_files` `add` | `p4 add <path>` |
| `modify_files` `sync` | `p4 sync` |
| `modify_files` `revert` | `p4 revert <path>` |
| `modify_changelists` `submit` | `p4 submit -c <id>` |
| `query_files` `annotations` | `p4 annotate -u <path>` |
| `query_files` `history` | `p4 filelog <path>` |
| `query_changelists` `get` | `p4 describe -du <id>` |

`query_reviews` and `modify_reviews` need P4 Code Review (Swarm). This local server does not have Swarm. Do not call review tools here.

## Login

The MCP process uses the same ticket as the CLI. Refresh with `p4 login` when `p4 login -s` says the ticket expired. The Helix Authentication Extension on this server is installed but has no identity-provider URL, and `auth.sso.allow.passwd` is on, so password tickets work.
