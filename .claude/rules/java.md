---
paths:
  - "**/*.java"
---

# Java

Follow the `java-change` skill.

- `p4 edit` a file that is already in the depot before changing it. `p4 add` a new class after the file exists.
- Change only the behavior that was asked for. Leave the rest of the file as it is.
- Keep public method names, job names, and bean names stable unless the user asked to rename them.
- Do not upgrade Java or a dependency as part of the edit.
