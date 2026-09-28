---
name: spring-boot-service
description: Use when changing Spring Boot application code that is not a batch job, including controllers, services, configuration properties, profiles, and beans. Use with p4-helix and java-change. For jobs and steps use spring-batch-on-p4 instead.
---

# Spring Boot service changes

Follow `p4-helix` and `java-change`. Batch jobs stay on `spring-batch-on-p4`.

## Find the existing pattern

Read the module before adding a type. Reuse the package layout, injection style, and `application.yml` keys that are already there.

- One `@SpringBootApplication` per service. Do not add a second one.
- Prefer constructor injection. If the file uses field injection, match that file.
- Configuration belongs in `src/main/resources/application.yml`, or the profile file the service already uses (`application-<profile>.yml`).
- Keep secrets out of yaml. Use the placeholder style the service already uses.

## What not to add

- A new Spring starter, database, or security setup, unless the user asked for that dependency.
- A new `application.properties` beside an existing `application.yml`.
- Profile values into the default file. A local override stays local and out of the depot when it has passwords.

## Check

Compile with `mvn -q -DskipTests compile` when Maven is installed. Describe the bean or endpoint you changed, the file, and the config key. Submit only when the user asked.
