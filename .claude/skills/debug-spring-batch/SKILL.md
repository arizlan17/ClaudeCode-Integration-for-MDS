---
name: debug-spring-batch
description: Use when a Spring Batch job or step fails, skips rows, exits non-zero, or restarts incorrectly. Diagnose before editing. Use with p4-helix when a code change follows.
---

# Debug a Spring Batch job

Start read-only. Do not rewrite the job until the failing step is identified.

## Gather

1. The job name, step name, job parameters, and the exception or exit description.
2. Whether this is a reader, processor, writer, or parameter problem. The stack trace says which class. Read that class.
3. `application.yml` for the datasource and `spring.batch.jdbc.initialize-schema`. Do not print passwords.

The sample job in this workspace is `helloJob` / `helloStep` in `sample/batch-hello`. A real service uses its own job names. Keep those names stable. The job repository keys restart off the job name and identifying parameters.

## Decide

- A failed chunk: fix the item or the reader/processor/writer. Do not raise the chunk size to hide the error.
- A skip or retry: only add it if the module already has a skip or retry policy, or the user asked for one. Name which exceptions are skipped.
- A restart that runs the wrong step: check identifying parameters and whether the step is marked restartable. Do not change the job name to force a fresh run.
- A schema error on an empty database: check `initialize-schema` before changing Java.

## Then change

Follow `spring-batch-on-p4` and `java-change`. `p4 edit` the files, make the smallest fix, and compile if Maven is available. Submit only when the user asked.
