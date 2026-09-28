---
paths:
  - "**/*.yml"
  - "**/*.yaml"
  - "**/*.properties"
---

# Configuration

Follow the `spring-boot-service` skill when this file belongs to a Spring Boot service.

- Use the yaml or properties file the module already has.
- Keep passwords, tickets, and `P4PASSWD` out of these files. Use the placeholder style the service already uses.
- Keep profile-specific values in `application-<profile>.yml`.
- Leave a local override that contains a password out of the depot.
