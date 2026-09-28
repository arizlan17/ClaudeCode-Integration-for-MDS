# Use this setup on an existing Java codebase

The sample under `sample/batch-hello` is only there to prove add and submit. Your services stay where they already are.

## 1. Put the service in a client Claude will open

Claude Code and the MCP server both need the folder you open to be the client root, or to sit inside it.

For a service that is already in Helix:

1. In P4V or `p4 client`, note the client `Root` and `View`.
2. Open that root in Claude Code. Do not open a copy of the files that is outside the client view.

For a service that is not in Helix yet:

1. Create a depot path such as `//depot/<service>/...`.
2. Create a client whose `Root` is the service directory and whose `View` maps only that service.
3. From that directory, `p4 reconcile` and submit the sources. Do not add `target/`, `.idea/`, or local property files that contain passwords.

## 2. Copy the Claude pieces into that client root

Copy these from this proof of concept and then change the user and client name:

- `CLAUDE.md`
- `.mcp.json` (set `P4USER` and `P4CLIENT` to that workspace)
- `.p4ignore`
- `.p4config` from `.p4config.template`
- `.claude/skills/`
- `.claude/agents/`
- `.claude/settings.json`

Leave `.p4config` out of the depot. It is listed in `.p4ignore`.

`P4CONFIG` on this machine is already the filename `.p4config`, so a shell started in the service directory picks up that file.

## 3. Match the skill to the real modules

Edit `.claude/skills/spring-batch-on-p4/SKILL.md` only where the sample paths differ from the real tree. Keep the checkout rule: `p4 edit` before changing a file that is already in the depot.

Spring Batch 5 (`JobBuilder`, `StepBuilder`) is what Boot 3 uses. If a service is still on Boot 2 / Batch 4, say so in `CLAUDE.md` for that client so Claude does not rewrite the job config to the Boot 3 API.

## 4. First session in the real service

1. `p4 login`
2. Open the client root in Claude Code and approve `perforce-p4-mcp`.
3. Ask Claude to describe the latest changelist and to find one job config with `query_files` action `search`.
4. Ask for a one-line comment change, then ask it to submit.

If files are writable without `p4 edit`, the client was created with `allwrite`. This proof of concept uses `noallwrite`, which is the normal Helix default and is what the skills assume.
