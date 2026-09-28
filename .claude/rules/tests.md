---
paths:
  - "**/src/test/**/*.java"
---

# Tests

Follow the `java-test` skill.

- Match the test style already in the module. Use JUnit 5 unless that module's tests are still JUnit 4.
- One behavior per test method.
- `p4 edit` an existing test before changing it. `p4 add` a new test after the file exists.
- Run `mvn -q test -Dtest=TheTestClass` when Maven is installed. If Maven is missing, say the test was not run.
