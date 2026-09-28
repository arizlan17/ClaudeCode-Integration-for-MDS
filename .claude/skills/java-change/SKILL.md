---
name: java-change
description: Use when editing Java source in this Perforce workspace, including bug fixes, methods, classes, and refactors. Use together with the p4-helix skill before the first edit.
---

# Change Java on P4

Follow `p4-helix` for checkout. This skill is how to change the code.

## Before editing

1. Read the class you will change and search for its callers. A rename or signature change is a wider edit than it looks.
2. `p4 sync` the files, then `p4 edit` each depot file. New classes are `p4 add` after the file exists.
3. Match the style already in the file: indentation, imports, logging, and null checks. Do not reformat the rest of the file.

## While editing

- Make the smallest change that does the job.
- Do not change a public method, job name, or bean name unless the user asked.
- Do not upgrade Java, Spring Boot, or a dependency as part of a behavior change.
- Do not add a new library if the module can do the work with what it already has.
- Leave generated output and `target/` unversioned.

## After editing

If `mvn` is on the PATH, from the module directory:

```
mvn -q -DskipTests compile
```

If Maven is missing, say so. Do not claim the code compiles.

If the class has tests, or the user asked for tests, follow `java-test`. Show `p4 diff -du`. Submit only when the user asked.
