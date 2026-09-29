# Claude Code on P4 Helix

This folder is a Perforce client root. The server, user, and client name come from `.p4config` in this folder. Depot lines for main, dev, and features come from `.claude/helix-lines.local`. It is not a Git repository.

## Version control

- Use Perforce. Do not run git commands and do not open a GitHub pull request.
- Connection comes from `.p4config` in this directory.
- Files that are already in the depot are read-only until `p4 edit`.
- New files: `p4 add`. Renames: `p4 move`.
- Prefer the `perforce-p4-mcp` tools when that MCP server is connected. Use the `p4` CLI when it is not.
- Submit only when the user explicitly asks to submit in this turn.
- Feature work follows `p4-sdlc`. The depot lines for this folder are in `.claude/helix-lines.local`. Do not submit feature work onto the MAIN or DEV paths in that file. Create a path under FEATURES first. Shelve and wait for the user to review before integrating back.
- Do not ask for a password, and do not write tickets or `.p4config` into the depot.
- Leave `target/`, `logs/`, and `.p4config` unversioned.

## Product

The ongoing work is Java, Spring Boot, and Spring Batch. Match the existing module in this client. If the service is still on Spring Boot 2, say so here so job configs are not rewritten to the Boot 3 API.

Skills to follow:

- `p4-helix` for every file operation. `p4-sdlc` for features. `p4-resolve` and `p4-shelve` for those cases.
- `understand-codebase` before changing an existing module.
- `java-change` for Java edits. `java-test` when tests are involved.
- `spring-batch-on-p4` for jobs and steps. `debug-spring-batch` when a job fails.
- `spring-boot-service` for application code that is not a batch job.

## If login fails

Stop and tell the user to run `p4 login` in a terminal.
