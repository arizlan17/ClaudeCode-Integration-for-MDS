---
name: spring-batch-on-p4
description: Use when changing Java, Spring Boot, or Spring Batch code in a Perforce workspace, including jobs, steps, readers, writers, processors, and application.yml. Use together with the p4-helix skill.
---

# Spring Batch on P4 Helix

Follow the `p4-helix` skill for every file operation. This skill only adds the Java rules.

## Layout

The PoC sample is `sample/batch-hello`. An existing service keeps its own module layout. Typical paths:

- Job and step config: `src/main/java/**/**/*JobConfig.java`
- Application entry: `src/main/java/**/*Application.java`
- Config: `src/main/resources/application.yml`
- Tests: `src/test/java/**`

Do not reformat unrelated classes. Do not upgrade Spring Boot or Java as a side effect of a behavior change.

## Before editing

1. `p4 sync` the module you are changing.
2. `p4 edit` each depot file you will change. New classes are `p4 add` after they exist.
3. Read the existing job config and `application.yml` before adding a step. Match the `JobBuilder` / `StepBuilder` style already in that module (Spring Batch 5 on Boot 3).

## Change rules

- One job class owns one job. Add a step to the existing job config instead of creating a second `@SpringBootApplication`.
- Name jobs and steps in camelCase and keep the name stable. Batch metadata in the database keys off that name.
- Chunk steps must set a chunk size and name the reader, processor, and writer. Tasklet steps are for single actions, as in `HelloJobConfig`.
- Keep secrets out of `application.yml`. Use placeholders the service already uses.
- Leave `target/` unversioned. It is in `.p4ignore`.

## After editing

From the module directory, if `mvn` is on the PATH:

```
mvn -q -DskipTests compile
```

If Maven is not installed, say so. Do not claim the job runs.

## Changelist text

```
batch: <job name> <what changed>

<why this step or reader changed>
```

Submit only when the user asked. See `p4-helix`.

## Related skills

- `java-change` for any Java edit in this workspace.
- `java-test` when the change needs a test.
- `debug-spring-batch` when a job or step fails. Do that before rewriting the job.
