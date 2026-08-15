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

## Code

### Operations

- Write upsert, idempotent operations: re-running yields the same end state.

### Documentation

- Prefix shell commands with `$`: `` `$ git status` ``.
- Write docstrings and comments abrupt, terse, specific.

### Variable Naming

- Pack max info into the name.
- Follow `noun_noun_verb`, max 3 parts: `user_email`, `commit_msg_suggest`.

### Conciseness

- Use the runtime's modern, concise syntax.
- Keep code short.
- Split complex-reading code into steps.

### Structure

- Sectionize code via comments.
- Group code by similarity within a section.
- Define processed data up front: JSON schema, docstring, data structures.

### Error Handling

- Treat errors as fatal: let them propagate and crash.
- Add error handling, fallbacks, recovery only when asked.
- Log full error detail: message, cause, context.
- Surface errors and their output.
