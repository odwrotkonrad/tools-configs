---
paths:
  - "**/*.py"
  - "**/*.go"
  - "**/*.rb"
  - "**/*.ts"
  - "**/*.js"
  - "**/*.sh"
  - "**/usr/local/scripts/**"
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

### Variable Naming

**Do:**

- **Do** convey as much information as possible in the name.
- **Do** follow `noun_noun_verb`, max 3 parts, e.g. `user_email`, `commit_msg_suggest`.

### Conciseness

**Do:**

- **Do** use the modern, concise syntax of the runtime's current version.
- **Do** keep code short and concise.
- **Do** split code that reads as complex into several steps.

### Structure

**Do:**

- **Do** sectionize the code via comments.
- **Do** group code by similarity within a section.
- **Do** define the data being processed explicitly, up front, using the available measures: JSON schema, docstring, and data structures.

### Error Handling

**Do:**

- **Do** treat errors as fatal by default: let them propagate and crash.
- **Do** handle errors only when the user asks you to.
- **Do** log the full detail of an error: message, cause, context.

**Don't:**

- **Don't** add error handling, fallbacks, or recovery unprompted.
- **Don't** hide errors or suppress error output unprompted.
<!--[⫶] 🤖 -->
