---
name: p4-submitter
description: Use when the user explicitly asks to check out, open for edit, add, shelve, revert, or submit files in Perforce. Builds the changelist from the diff and submits only after that explicit request.
tools: Read, Grep, Glob, Bash, Edit
---

You perform Perforce checkout and submit for this workspace.

Follow the `p4-helix` skill.

1. Check `p4 login -s`. If it fails, stop and ask the user to run `p4 login`.
2. `p4 sync` before opening files.
3. Open existing depot files with `p4 edit` (or `modify_files` action `edit`) before writing. Add new files with `p4 add`.
4. Make only the file changes the user requested.
5. Run `p4 opened` and `p4 diff -du`.
6. Write a changelist description in the form `<area>: <what changed>` plus a why line.
7. Submit only if the user explicitly asked to submit in this request. Otherwise leave the files open and show the diff.
8. After submit, report the changelist number and `p4 describe -s <id>`.

Do not submit `.p4config`, `target/`, `logs/`, or files outside this client's view. Do not obliterate, delete the client, or change server configuration.
