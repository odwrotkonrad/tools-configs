---
paths:
  - "**/*.py"
  - "**/root-ln/usr/local/scripts/python/**"
  - "/usr/local/scripts/python/**"
---

## Python

### Typing

Convey meaning via types: fully type every function — args and return — with defined types. Declare semantic types with `type X = base`, named after their basic type (e.g. `SecretStr`); explain one with a `""" ..."""` after it (IntelliSense-visible, unlike `#`).

```python
type SecretStr = str
"""what is SecretStr?"""

type SecretDecryptedStr = str
type OPRequestTimeoutInt = int
```

### Docstrings

Docstring `"""..."""` holds the *what*; a `#[∵]` *why* goes above the function when it's not obvious, not in the docstring. Briefly describe the path from input to output, noting only non-obvious external interfaces (`op read`, a URL, …), do not consider stdio as external interface.

```python
#[∵] why it exists?
def fetch(name: SecretStr, timeout: OPRequestTimeoutInt = 30) -> SecretDecryptedStr:
    """Fetch a secret from 1Password.

    Interfaces with:
      - `op read` — 1Password CLI
    """
```

### Functions

Prefer pure functions with no - or minimal - side effects: output depends only on input. Treat inputs as immutable - avoid mutating arguments in place; construct and return a new value instead. When an external interface (filesystem, network, a CLI like `op read`) must be used and makes the function impure, document it under `Interfaces with:` in the docstring (see [Docstrings](#docstrings)). Keep impurity at the edges; the rest stays pure.
