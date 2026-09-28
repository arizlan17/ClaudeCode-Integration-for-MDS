# Claude Code on P4 Helix

This directory is the Perforce workspace `p4_imp_poc`. Depot path: `//depot/poc/...`. It is not a Git repository.

## Version control

- Use Perforce. Do not run git commands here.
- Connection comes from `.p4config` in this directory.
- Files that are already in the depot are read-only until `p4 edit`.
- New files: `p4 add`. Renames: `p4 move`.
- Prefer the `perforce-p4-mcp` tools when that MCP server is connected. Use the `p4` CLI when it is not.
- Submit only when the user explicitly asks to submit in this turn.
- Do not ask for a password, and do not write tickets or `.p4config` into the depot.
- Leave `target/`, `logs/`, and `.p4config` unversioned.

## Product

The ongoing work is Java, Spring Boot, and Spring Batch. The proof-of-concept job is `sample/batch-hello`. Match the existing module when you are in a real service.

Skills to follow:

- `p4-helix` for every file operation. `p4-resolve` and `p4-shelve` for those cases.
- `java-change` for Java edits. `java-test` when tests are involved.
- `spring-batch-on-p4` for jobs and steps. `debug-spring-batch` when a job fails.
- `spring-boot-service` for application code that is not a batch job.

## If login fails

Stop and tell the user to run `p4 login` in a terminal.
