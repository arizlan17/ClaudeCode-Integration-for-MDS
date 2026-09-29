---
name: p4-sdlc
description: Use when starting a feature, creating a Helix branch, or integrating work back to main or dev. Use together with p4-helix. Do not submit feature work onto main or dev.
---

# Helix feature branch

Follow `p4-helix` for login and checkout. This skill is the SDLC. Git and GitHub are not used.

Read `.claude/helix-lines.local` in the workspace you have open. It sets the three depot lines for this client. A different folder on a different drive has its own file. Do not reuse `//depot/poc` unless that file says so.

Protected lines are `MAIN/...` and `DEV/...` from that file.

A feature branch is `FEATURES/<feature-name>/...`. `<feature-name>` is short, lowercase, and uses hyphens. Branch from `DEV` when that path has files. Otherwise branch from `MAIN`.

If `p4 streams` shows a stream depot for this project, create a task stream from `DEV` or `MAIN` instead of a folder branch, then use a client bound to that stream.

## Before editing code

1. Run `p4 login -s`. If it fails, stop and tell the user to run `p4 login`.
2. Follow `understand-codebase` when the tree already has modules, jobs, or services.
3. Read `p4 client -o`. The client root must be the folder you are editing. If the view is only `MAIN` or `DEV`, do not edit those files for the feature.
4. Create the feature path by branching the source line. Use the paths from `helix-lines.local`:

```
p4 populate -d "branch: <feature-name> from <source>" <SOURCE>/... <FEATURES>/<feature-name>/...
```

`<SOURCE>` is the `DEV` path when it has files, otherwise the `MAIN` path. If `populate` is refused because the source path has no files yet, `p4 add` the new files only under `FEATURES/<feature-name>/...`. Do not put those files under `MAIN` or `DEV`.

5. Edit only files under that feature path, even when the client maps a wider depot.
6. `p4 sync` that feature path, then `p4 edit` or `p4 add` only those files.

## While the feature is open

- One pending changelist for the feature.
- Submit is allowed on the feature path only when the user asked to submit in this turn.
- Do not submit a file whose depot path is under `main` or `dev`.

## Review before merge

Integrate back to `dev` or `main` only after the user approves in this turn.

1. `p4 shelve` the feature changelist. Follow `p4-shelve`.
2. Show `p4 describe -s` and `p4 diff -du`.
3. Stop. Ask the user to review. Do not integrate yet.
4. After the user approves, integrate the feature into the target line and resolve with `p4-resolve`.
5. Submit the integrate changelist only when the user also asked to submit it.

Do not open a GitHub pull request. Do not `git commit`.
