---
paths:
  - "**/*.py"
  - "**/root-ln/usr/local/scripts/python/**"
  - "/usr/local/scripts/python/**"
---

<!--[…] 🤖 -->
## Python

### General

**Do:**

- **Do** use modern Python 3.14 features when possible.
- **Do** use operators when possible: if an operator does what a function does, use the operator.

```python
merged: dict[str, int] = a | b
a |= b

combined: list[int] = xs + ys
xs += ys
```

### Typing

**Do:**

- **Do** fully type every function (both args and return) with defined types.
- **Do** declare semantic types with `type X = base`, named after their basic type (e.g. `SecretStr`).
- **Do** explain a semantic type with a `"""..."""` after it (IntelliSense-visible, unlike `#`).

**Don't:**

- **Don't** leave any function arg or return untyped.
- **Don't** explain a semantic type with a `#` comment when a `"""..."""` is available.

```python
type SecretStr = str
"""what is SecretStr?"""

type SecretDecryptedStr = str
type OPRequestTimeoutInt = int
```

### Docstrings

**Do:**

- **Do** put the *what* in the docstring `"""..."""`.
- **Do** put a *why* `#[∵]` above the function when it is not obvious and user explicitly asked for explanation comment.
- **Do** describe the path from input to output, as a numbered list.
- **Do** note non-obvious external interfaces (`op read`, a URL, …) under `Interfaces with:`.

**Don't:**

- **Don't** put the *why* in the docstring.
- **Don't** note `stdio` as an external interface.

**Example:**

```python
#[∵] why it exists?
def f(arg: InT, opt: OptT = default) -> OutT:
    """<what it does>.

    1. <step from input>.
    2. <transform>.
    3. <return output>.

    Interfaces with:
      - `$ <cmd>` — <external interface>
      - <url> — <external interface>
    """
```

### Functions

**Do:**

- **Do** prefer pure functions with no (or minimal) side effects: output depends only on input.
- **Do** treat inputs as immutable: construct and return a new value instead of mutating arguments.
- **Do** keep impurity at the edges; the rest stays pure.
- **Do** document an unavoidable external interface (filesystem, network, a CLI like `op read`) under `Interfaces with:` in the docstring (see [Docstrings](#docstrings)).

**Don't:**

- **Don't** mutate arguments in place.
- **Don't** introduce side effects when the work can be done purely.
- **Don't** read global variables in a function body; instead pass what the function needs as arguments.
- **Don't** pass redundant data to a function (e.g. a whole dict); extract and pass exactly what it needs.
<!--[⫶] 🤖 -->
