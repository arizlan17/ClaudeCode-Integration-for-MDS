# Using Claude Code with P4 Helix

This workspace is how Claude Code reads, checks out, and submits files in Perforce. Open the folder `D:\P4 imp` in Claude Code. That folder is the Helix client `p4_imp_poc`.

## How this works

Claude Code does not talk to Helix by itself. Three local pieces sit between the chat and the depot.

```text
You, in Claude Code
        |
        |  reads CLAUDE.md, .claude/skills, .claude/agents
        |
        |  starts perforce-p4-mcp from .mcp.json
        v
p4mcp-server, started by scripts/start-p4mcp.cmd
        |
        |  P4PORT, P4USER, and P4CLIENT from .p4config, plus the p4 login ticket
        v
Helix server at P4PORT
        |
        v
Client from .p4config  ->  this folder
Depot path mapped by that client
```

| Piece | Role |
| --- | --- |
| `.mcp.json` | Tells Claude Code to start the official Perforce MCP server, with checkout and submit turned on |
| `p4 login` ticket | How the MCP server authenticates. Claude never asks you to paste a password into chat |
| `.p4config` | Tells the `p4` command, when run in this folder, to use client `p4_imp_poc` |
| `CLAUDE.md` | Rules Claude follows in this workspace: Perforce instead of Git, edit before write, submit only when you ask |
| `.claude/skills/` | Short procedures Claude follows for Helix, Java, Spring Boot, and Spring Batch |
| `.claude/agents/` | Named helpers for read-only lookup, submit, resolve, review, and code changes |

The MCP server is [p4mcp-server](https://github.com/perforce/p4mcp-server). This workspace starts it without `--readonly`, so it can check out and submit. The skills still wait for you to ask before they submit.

Depot files are read-only on disk until they are opened with `p4 edit`. Claude is instructed to open a file before changing it, and to `p4 add` a new file. `target/`, `logs/`, and `.p4config` stay out of the depot.

The Helix Authentication Extension is installed, but it has no identity-provider URL. Login stays a normal `p4 login` ticket. That is what the MCP server can use. A browser single-sign-on prompt is not something the MCP process can complete.

## Connect Claude Code

Do this once per machine, and again whenever the ticket expires.

1. Confirm Helix from PowerShell:

```powershell
cd "D:\P4 imp"
p4 login -s
p4 info
```

`p4 info` should show user `arizlan` and client `p4_imp_poc`. The server may print its address as `kubernetes.docker.internal:1666`. That is this same local service on port `1666`.

If `p4 login -s` fails, run `p4 login` in that terminal and enter the password there.

2. Install Claude Code if the `claude` command is missing, then sign in.

3. In Claude Code, open the folder `D:\P4 imp`. Do not open `D:\Perforce\claude_workspace`. That directory is a different client and a different set of files.

4. When Claude Code asks you to trust project MCP servers, approve `perforce-p4-mcp`.

That server is defined in `.mcp.json`. It runs `scripts/start-p4mcp.cmd`, which reads `.p4config` and then starts `p4mcp-server`. The username and server address are not stored in `.mcp.json`. To use a company Helix server, change `P4PORT`, `P4USER`, and `P4CLIENT` in `.p4config`, then run `p4 trust` if the port starts with `ssl:` and `p4 login`. See `docs/ENTERPRISE.md`.

5. Ask Claude:

> Use the Perforce MCP tools. What server, user, and client are connected, and what is the latest changelist under //depot/poc/?

A good answer names user `arizlan`, client `p4_imp_poc`, and a changelist on `//depot/poc/`.

P4V can use the same server: `localhost:1666`, user `arizlan`, workspace `p4_imp_poc`.

## How to use it

Talk to Claude in this folder the way you would on a normal code task. `CLAUDE.md` and the skills apply on their own. Name an agent when you want that role.

### Everyday prompts

Read history, without changing files:

> Use p4-reader. Who last changed HelloJobConfig.java, and what did that changelist do?

Change a batch job and leave it open for you to look at:

> Use spring-batch-dev. In helloJob, change the log line to include the step name. Do not submit.

Submit work you already asked for:

> Submit the opened files. Description: batch: helloStep log line names the step.

Shelve instead of submitting:

> Shelve the open files so I can pick them up on another machine. Do not submit.

After a sync reports conflicts:

> Use p4-resolver. Resolve the unresolved files. Do not accept theirs or yours unless I say so.

Review a diff:

> Use java-reviewer. Review the pending changelist and list the problems.

### What a skill is

A skill is a written procedure in `.claude/skills/<name>/SKILL.md`. Claude Code reads it and follows those steps while it does your task in the main chat.

You usually do not call a skill by name. Claude picks it up when your request matches the skill description. Asking to change a Java class loads `java-change`. Asking to fix a failed batch job loads `debug-spring-batch`. `CLAUDE.md` also tells Claude which skills belong to this workspace.

Use a skill, by just describing the work, when you want the normal chat to do the task and follow the team rules: check out before editing, keep the diff small, do not submit until you say so.

| Skill | Claude uses it when you ask to |
| --- | --- |
| `p4-helix` | Check out, sync, diff, or submit any file |
| `p4-resolve` | Merge files after a sync or unshelve |
| `p4-shelve` | Shelve work, or unshelve a changelist |
| `java-change` | Edit a Java class or method |
| `java-test` | Add or run a JUnit test |
| `spring-batch-on-p4` | Change a job, step, reader, writer, or processor |
| `debug-spring-batch` | Find out why a job or step failed, before rewriting it |
| `spring-boot-service` | Change a controller, service, bean, or `application.yml` |

### What an agent is

An agent is a separate worker defined in `.claude/agents/<name>.md`. It gets its own instructions and a limited set of tools. A reader agent can run Perforce queries and cannot submit. A dev agent can edit files. The main chat hands the task to that worker and brings the result back.

Name an agent when you want that boundary. A review should not quietly edit the code. A history question should not check files out. A batch change should follow the batch rules, and a service change should follow the service rules.

How to call one: start the message with `Use <agent>.` and then say what you want.

> Use java-reviewer. Review the pending changelist and list the problems.

> Use p4-reader. Who last changed HelloJobConfig.java?

You can still do the same work without naming an agent. Naming one keeps the task inside that role.

| Agent | Use it when | What it will do |
| --- | --- | --- |
| `p4-reader` | You want history, blame, or the contents of a changelist | Reads Helix and leaves the files alone |
| `p4-submitter` | You want files checked out and, if you said so, submitted | Opens the files, writes the description, submits only if you asked |
| `p4-resolver` | A sync or unshelve left conflicts | Merges the files and stops before submit |
| `java-reviewer` | You want a review of a Java, Spring Boot, or Spring Batch diff | Reports problems and does not edit |
| `spring-batch-dev` | You want a job or step implemented or changed | Checks out the files and edits the batch code |
| `spring-boot-dev` | You want a controller, service, bean, or config change | Checks out the files and edits the service code |

### Which one to pick

| You want | Do this |
| --- | --- |
| Claude to follow the rules while you describe the task in normal chat | Just describe the task. The matching skill applies. |
| A lookup that must not change files | `Use p4-reader.` |
| A code review that must not change files | `Use java-reviewer.` |
| A batch change, with checkout handled for you | `Use spring-batch-dev.` |
| A Spring Boot service change, with checkout handled for you | `Use spring-boot-dev.` |
| Someone to finish a merge | `Use p4-resolver.` |
| Someone whose only job is the changelist | `Use p4-submitter.` |

An agent still follows the skills. `spring-batch-dev` follows `p4-helix`, `java-change`, and `spring-batch-on-p4`. The agent is the role. The skill is the procedure that role uses.

### Rules

Rules in `.claude/rules/` load when Claude works on a matching file. You do not call them. They are shorter than skills and apply on top of `CLAUDE.md`.

| Rule file | Loads for |
| --- | --- |
| `.claude/rules/java.md` | `**/*.java` |
| `.claude/rules/spring-batch.md` | job and step classes, and `sample/**/*.java` |
| `.claude/rules/config.md` | yaml and properties files |
| `.claude/rules/tests.md` | `**/src/test/**/*.java` |

`.claude/settings.json` denies reads of `.p4config`, `.env`, `secrets/`, and key or certificate files, so those contents are not sent to the Claude API. `.p4ignore` keeps the same paths out of the depot.

The sample job is `sample/batch-hello` (`helloJob` / `helloStep`). A real service keeps its own module layout. Copy the Claude files into that service's client root using `docs/ADOPT-EXISTING-CODEBASE.md`.

## What Claude can do in Perforce

With `perforce-p4-mcp` approved, Claude Code can read, change, and submit files. In Helix, submit is the push. There is no separate push command.

| You ask for | Helix action |
| --- | --- |
| Read a file, its history, or blame | `query_files` |
| List or describe changelists | `query_changelists` |
| Check out and edit a depot file | `p4 edit`, then the file is changed |
| Add a new file | `p4 add` |
| Rename | `p4 move` |
| Shelve or unshelve | `p4 shelve` / `p4 unshelve` |
| Sync | `p4 sync` |
| Resolve a conflict | `p4 resolve` |
| Submit | `p4 submit` |

Changelist 12 is the proof: `HelloJobConfig.java` was checked out and submitted through this server. Depot files stay read-only until that checkout.

## What Claude will not do unless you ask

- Submit a changelist.
- Shelve, or delete a shelf.
- Accept "theirs" or "yours" for a whole conflict.

These stay out of Claude's work even if you ask in a normal coding task. Ask for them in plain words if you really want them, and only an admin should do the server ones:

- `p4 obliterate`
- Changing protections, triggers, or the server-wide typemap
- Pointing the authentication extension at an identity provider
- Review comments and votes. Those need P4 Code Review (Swarm), which this local server does not have.

## If a tool call fails

| What you see | What to do |
| --- | --- |
| Ticket expired, or "user not logged in" | Run `p4 login` in `D:\P4 imp`, then retry the prompt |
| MCP server missing or still starting | Approve `perforce-p4-mcp`. The first start can take a minute while `uvx` fetches the package |
| File is read-only and the edit did not save | Tell Claude to `p4 edit` that file and retry. Do not clear the read-only flag yourself |
| Client unknown | You opened a folder that is not this client. Open `D:\P4 imp` |
| Wrong files, or `app.py` | That file belongs to client `claude_workspace`, not this proof of concept |

Check the connection from PowerShell:

```powershell
cd "D:\P4 imp"
p4 login -s
p4 info
p4 opened
powershell -File scripts\check-enterprise.ps1
```

## Claude Desktop

Claude Desktop is a different app. It can start the same MCP server if you merge `config/claude_desktop_config.fragment.json` into `%APPDATA%\Claude\claude_desktop_config.json` and restart Desktop. It does not load `CLAUDE.md`, the skills, or the agents. Use Claude Code for those.

Cursor uses `.cursor/mcp.json`, which points at the same Perforce server. Skills and agents in `.claude/` are for Claude Code.
