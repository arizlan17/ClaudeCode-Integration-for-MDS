---
name: understand-codebase
description: Use when the task touches an existing Java, Spring Boot, or Spring Batch project, before editing it. Maps modules, jobs, configuration, and recent Helix history. Use together with p4-helix.
---

# Understand an existing codebase

Do this before the first edit when the tree already contains source. Follow `p4-helix` for read-only Helix commands. Do not `p4 edit`, `p4 add`, or `p4 submit` in this step.

## Map the tree

1. Find modules by `pom.xml` or `build.gradle` files.
2. Find `@SpringBootApplication` classes and `*JobConfig` or `*Job` classes.
3. Read `src/main/resources/application.yml` and any `application-<profile>.yml` next to it. Do not print passwords.
4. Note the package layout and one existing test under `src/test/java` if any exist.

## Read Helix history

From the module path:

```
p4 changes -m 10 <module>/...
p4 filelog -m 5 <the file you expect to change>
```

Report who last changed the area and the changelist descriptions. That is the style and ownership to match.

## Tell the user what you found

Use a short list:

- Module path and build file
- Application class and job names
- Config files
- Where a change of this kind already lives
- Latest relevant changelist

Then follow `p4-sdlc` and create a feature branch before editing. On a new sample with no existing service, say the tree is the proof-of-concept job `sample/batch-hello` and continue to the feature branch.
