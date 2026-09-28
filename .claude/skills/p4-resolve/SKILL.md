---
name: p4-resolve
description: Use when Perforce sync, integrate, or unshelve leaves files that must be resolved, or when the user asks to merge or resolve conflicts. Use together with the p4-helix skill.
---

# Resolve Perforce files

Follow `p4-helix` for login and client checks. This skill only covers conflicts.

## See what is unresolved

```
p4 resolve -n
```

If that prints nothing, there is nothing to resolve. Do not run a resolve that accepts a side "just in case".

## Safe order

1. `p4 resolve -am` for files that merge without overlap.
2. Run `p4 resolve -n` again.
3. For each remaining file, show the depot path and open the working file. Keep both sides where the logic differs, and delete the conflict markers (`>>>>`, `====`, `<<<<`).
4. `p4 resolve -n` must be empty before you call the file done.

## Which side wins

Accept theirs (`p4 resolve -at`) or yours (`p4 resolve -ay`) only when the user names that side for those files. Say which files will lose edits before you run it.

Do not `p4 revert` a file to get rid of a conflict unless the user says to drop their edits.

## After resolve

Show `p4 opened` and `p4 diff -du` for the resolved files. Submit only when the user asked to submit in this turn.
