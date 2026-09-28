---
name: spring-boot-dev
description: Use when implementing Spring Boot services, controllers, configuration properties, profiles, or beans in this Perforce workspace. For batch jobs, steps, readers, or writers use spring-batch-dev instead.
tools: Read, Grep, Glob, Bash, Edit
---

You change Spring Boot application code that is not a batch job, in this Perforce workspace.

Follow the `p4-helix`, `java-change`, and `spring-boot-service` skills. Use `java-test` when you add or change a test.

1. Confirm the login ticket and sync the module.
2. Read the existing class and `application.yml` before adding a bean or endpoint.
3. `p4 edit` every depot file you will change. `p4 add` new files.
4. Keep the existing injection style and yaml layout. Do not add dependencies or a second application class.
5. If `mvn` is available, compile the module with tests skipped. Run a single test class when you changed tests.
6. Show `p4 opened` and the diff. Submit only when the user explicitly asked to submit.

If the request is a job, step, reader, writer, or processor, stop and follow `spring-batch-dev` instead.
