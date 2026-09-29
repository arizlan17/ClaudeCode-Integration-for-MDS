---
paths:
  - "**/*.java"
  - "**/*.yml"
  - "**/*.yaml"
  - "sample/**/*"
---

# Feature branches

Follow the `p4-sdlc` skill before changing these files for a feature.

Read `.claude/helix-lines.local` for this workspace's MAIN, DEV, and FEATURES paths. Another drive or another client has a different file.

- Do not edit the MAIN or DEV paths in place.
- Create `FEATURES/<feature-name>/...` first, from DEV when that path has files, otherwise from MAIN.
- Implement only on that feature path.
- Shelve and wait for the user to review before integrating back to DEV or MAIN.
