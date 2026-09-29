---
name: p4-helix
description: Use when working in a Perforce Helix workspace, including checkout, sync, shelve, submit, file history, blame, changelists, or any p4 command. Use before editing a file that is already in the depot.
---

# P4 Helix workflow

This workspace is Perforce, not Git. The connection is read from `.p4config` (`P4PORT`, `P4USER`, `P4CLIENT`). That file is the switch between this local server and a company Helix server. Do not hardcode `localhost` or a username in a command when `.p4config` is present.

`P4USER` must be a standard user. A service user cannot run the MCP commands. Do not put `P4PASSWD` in `.p4config`. If `p4 login -s` fails, stop and tell the user to run `p4 login`. On an `ssl:` port, a trust error means they must run `p4 trust` once in this directory before logging in.

## Prefer the MCP server

When the `perforce-p4-mcp` server is connected, use its tools. The action map is in [references/tool-map.md](references/tool-map.md).

If that server is not connected, use the `p4` CLI from the workspace root. Do not invent a Git workflow as a substitute.

## Start of a task

1. Run `p4 info` and `p4 login -s`.
2. If the login check fails, stop. Tell the user to run `p4 login` in a terminal. Do not ask for a password, and do not put a password or ticket in a file or a changelist.
3. Confirm the client with `p4 client -o`. Trust `Root` and `View` over the folder you happen to have open.

## Read-only files

The workspace uses `noallwrite`. Depot files are read-only on disk until they are opened.

- File already in the depot: `p4 edit <path>` before any change. MCP action: `modify_files` / `edit`.
- New file: create it, then `p4 add <path>`. MCP action: `modify_files` / `add`.
- Rename: `p4 move <from> <to>`. Do not delete and re-add.
- Remove: `p4 delete <path>`.
- Gave up on the edit: `p4 revert <path>`.

If a write fails because the file is read-only, open it for edit and retry. Do not clear the read-only attribute by hand.

## Sync before editing

Run `p4 sync` at the start of a task that will change depot files. If `p4 sync` reports files you also have open, stop and resolve before editing further.

## Submit only when asked

Submit only when the user explicitly asks to submit in the current request. Shelve when they ask to shelve.

Before submit:

1. `p4 opened` and `p4 diff -du`.
2. Show the file list and a changelist description.
3. Submit that changelist only.

Description format:

```
<area>: <what changed>

<why>
```

Examples: `batch: rename helloStep log line`, `p4: add Claude Code MCP config`.

Never submit `target/`, `logs/`, `.p4config`, tickets, or password files. `.p4ignore` already excludes the local ones; do not force-add them.

Never submit a file under `//depot/poc/main/...` or `//depot/poc/dev/...` as part of a feature. Follow `p4-sdlc`: implement on `//depot/poc/features/<feature-name>/...`, shelve, and wait for the user to review before integrating back.

## Leave the workspace usable

- One pending changelist per task. Put unrelated files in a different changelist or revert them.
- Do not `p4 obliterate`, `p4 client -d`, or change protections, typemap, or triggers unless the user explicitly asks.
- Do not run `p4 set` in a way that changes the user's global `P4CLIENT` or `P4PORT`. This workspace is selected by `.p4config`.

## Related skills

- `p4-sdlc` for every feature. It creates the branch and blocks a merge until the user reviews.
- `understand-codebase` before editing an existing Java, Spring Boot, or Spring Batch tree.
- `p4-resolve` when `p4 sync` leaves files that must be resolved.
- `p4-shelve` when the work should be shelved instead of submitted.
