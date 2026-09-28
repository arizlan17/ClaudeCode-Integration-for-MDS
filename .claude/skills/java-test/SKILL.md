---
name: java-test
description: Use when adding, updating, or running JUnit tests for Java, Spring Boot, or Spring Batch in this Perforce workspace. Use together with p4-helix and java-change.
---

# Java tests on P4

Follow `p4-helix` and `java-change`. Read an existing test in the same module and copy its style before writing a new one.

## Where tests go

`src/test/java/` mirrors the main package. A new test file is `p4 add` after it exists. An existing test is `p4 edit` before you change it.

## What to write

- JUnit 5, unless the module's tests are still JUnit 4. Do not mix both in one new test.
- One behavior per test method. Name the method for the case, in the style the module already uses.
- Spring Batch tests use the helper the module already uses (`@SpringBatchTest`, `JobLauncherTestUtils`, or a plain unit test of the processor). Do not introduce a second test stack.
- Do not add Mockito, Testcontainers, or an in-memory database if the module does not already depend on them. Ask before adding a test dependency.

## Run

From the module, if `mvn` is on the PATH:

```
mvn -q test -Dtest=TheTestClass
```

Report the command and whether it passed. If Maven is missing, say the tests were not run. Do not claim they passed.

Submit only when the user asked.
