---
name: p4-shelve
description: Use when the user wants to shelve, unshelve, update a shelf, or share Perforce work without submitting. Use together with the p4-helix skill.
---

# Shelve Perforce work

Follow `p4-helix`. Shelving stores the pending files on the server. It does not submit them.

## Shelve

1. `p4 login -s`, then `p4 opened`.
2. If the files are on the default changelist, create a numbered changelist with a description in the form `<area>: <what changed>` plus a why line. Move the files onto it with `p4 reopen -c <id>`.
3. `p4 shelve -c <id>`.
4. Report the changelist number. Tell the user the files are still open locally unless they asked to revert after shelving.

Replace an existing shelf only when the user asks to update it: `p4 shelve -f -c <id>`.

## Unshelve

1. `p4 unshelve -s <id> -c <target>`.
2. If the command reports files that must be resolved, stop and follow `p4-resolve`.
3. Do not delete the shelf unless the user asks: `p4 shelve -d -c <id>`.

## Do not shelve

`.p4config`, tickets, `target/`, `logs/`, or files outside this client's view.
