---
paths:
  - "**/*Job*.java"
  - "**/*Step*.java"
  - "sample/**/*.java"
---

# Spring Batch

Follow the `spring-batch-on-p4` skill. If the job is failing, follow `debug-spring-batch` before rewriting it.

- Keep the job name and step name stable. Batch metadata keys off those names.
- Add a step to the existing job configuration. Leave the existing `@SpringBootApplication` class as the only one.
- A tasklet is for one action, as in `helloStep`. A chunk step names its reader, processor, writer, and chunk size.
- The sample job in this workspace is `helloJob` / `helloStep` under `sample/batch-hello`.
