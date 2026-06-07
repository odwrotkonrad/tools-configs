---
paths:
  - "**/*.py"
  - "**/*.go"
  - "**/*.rb"
  - "**/*.ts"
  - "**/*.js"
---

<!--[…] 🤖 -->
## Code

Generic coding guidelines.

### Operations

**Do:**

- **Do** prefer upsert, idempotent operations: re-running yields the same end state.

**Don't:**

- **Don't** write operations that fail or duplicate when run a second time.

### Documenting Commands

**Do:**

- **Do** write shell commands with a `$` prompt prefix, e.g. `` `$ git status` ``.
<!--[⫶] 🤖 -->
