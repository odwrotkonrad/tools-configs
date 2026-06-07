---
paths:
  - "**/root-ln/usr/local/scripts/python/**"
  - "/usr/local/scripts/python/**"
---

<!--[…] 🤖🤖 -->

## Python Scripts

**Do:**

- **Do** output results to stdout.
- **Do** keep write operations on external interfaces (files, network, …) in the shell consuming the output.

**Don't:**

- **Don't** perform write operations on external interfaces (files, network, …) from the script.

### Docstrings

**Do:**

- **Do** open every script with a module docstring laid out as shown below.
- **Do** trace the input-to-output path in the numbered steps.
- **Do** list non-obvious external interfaces touched (files, CLIs, URLs) under `Interfaces with:`.
- **Do** list every exit code the script can emit (its own domain codes and the common ones it reuses) under `Exit Codes:`.

**Don't:**

- **Don't** list stdio as an external interface (see [Docstrings](python.md#docstrings)).

### Input

**Do:**

- **Do** validate input before invoking the `main` function.
- **Do** validate input with pydantic models defined above the code: `Parameters` (holding `Arguments`, the `SYNOPSIS` grammar, and, when the script takes flags, `Options`) and `Config` (when the script uses a config file).
- **Do** declare an `Action` enum carrying the standard `USAGE` (`--help`/`-h`) and `SCHEMA` (`--json-schema`, prints the JSON Schema of the contract models) alongside its own actions.
- **Do** declare a `Config` model for the validated config file, when the script uses a config file.
- **Do** store config in a system location and a user location, merging the two with the user config overriding, when the script uses a config file.
- **Do** use pydantic's validators (e.g. `field_validator`, `model_validator`) to validate and prepare models; a validator rejecting a value raises (pydantic's contract) and `validate_input` translates it into an `Error` (e.g. `ERR_FILE_NOT_FOUND` instead of the generic `ERR_ARGS`), so the rest of the script stays exception-free.

**Don't:**

- **Don't** build models for input the script doesn't use (e.g. `Options` for a flag-less script, `Config` for one with no config file); the unused slot is then `None`.
- **Don't** add an `Output` model; a handler returns its result directly.

### Errors

**Do:**

- **Do** treat exit codes as the script's error contract, banded by origin.
- **Do** reuse the common codes from the lib — `usr/local/scripts/python/s_rt_scripts_lib/errors.py` in the `1x` band (`ERR_ARGS`, `ERR_CONFIG`, `ERR_FILE_NOT_FOUND`).
- **Do** define a script's own domain errors in the `2x` band, numbering each script from `21`.
- **Do** list every code under `Exit Codes:` in the module docstring.
- **Do** build the script's `ERRORS` map as a new dict from `lib_err.ERRORS | {domain codes}` (the script's own entries taking precedence); never reassign or mutate `lib_err.ERRORS`.
- **Do** return an `Error` (carrying the exit code and the context, e.g. `{path}`) from where the failure is detected (a handler, a helper), alongside the output; the gate resolves its message against the script's `ERRORS` map.

**Don't:**

- **Don't** raise exceptions to signal failures; return an `Error` instead and let `main` propagate it to the gate (see [Structure](#structure)).
- **Don't** call `sys.exit` outside the `__main__` gate.

### Structure

**Do:**

- **Do** reuse common pieces from `s_rt_scripts_lib` (e.g. `validate_input`/`Synopsis`/`get_config` in `input`) rather than reimplementing.
- **Do** divide the body into labeled `# […] name` / `# [⫶]` sections, in this order:
  1. **`# […] errors`** — the script's domain exit codes and their `ERRORS` messages (omit when the script has none).
  2. **`# […] types`** — the semantic `type X = base` aliases.
  3. **`# […] contract`** — the pydantic models: `Action`, `Arguments`/`Options`, `Parameters`, `Config` ([Input](#input)).
  4. **`# […] implementation`** — the handlers and their helpers, before `main`, so the gate can call them.
  5. **`# […] main`** — `main` then the `if __name__ == "__main__"` gate, last (it runs in source order, so everything it calls must already be defined above).
- **Do** make `main` a pure dispatch: a `match action` where every action maps to its own function.
- **Do** keep the `main` pipeline flat so it clearly describes the path from input to output.
- **Do** make every function return its output and an optional `Error` (the exit code with its prepared message); `main` returns the resolved `(output, error)` for the action.
- **Do** exit the script from the `__main__` gate (around `main`): the gate calls `main(*validate_input(...))`, then prints the output to stdout, or the error message to stderr and `sys.exit(error.code)`.
- **Do** pass a handler only the exact values it needs.

**Don't:**

- **Don't** pass a whole `Config`/`Parameters` to a handler.
- **Don't** nest functions; define them at module level so the pipeline stays flat and readable.
- **Don't** raise exceptions or call `sys.exit` from handlers/helpers; return an `Error` and exit only from the gate.

## Example - Script

```python
"""usage: s-rt-get <group> <entry>

Get one entry's value from the config:

1. read and merge the system + user config
2. look up <entry> under <group>
3. print the value to stdout

Interfaces with:
- files: entries.yml (system + user)

Exit Codes:
- 21 entry not found
- 11 invalid arguments
"""

import sys
from s_rt_scripts_lib import errors as lib_err
from s_rt_scripts_lib import input as lib_ipt

# […] errors
ERR_NO_ENTRY = 21
ERRORS = lib_err.ERRORS | {ERR_NO_ENTRY: "entry not found: {entry}"}
# [⫶] errors


# […] types
type GroupNameStr = str
type EntryNameStr = str
type EntryStr = str
# [⫶] types


# […] contract
class Action(StrEnum):
    USAGE = "usage"
    SCHEMA = "schema"
    GET = "get"


class Config(BaseModel):
    entries: dict[EntryNameStr, EntryStr] = {}


class Arguments(BaseModel):
    group: GroupNameStr
    entry: EntryNameStr

    @field_validator("entry")
    @classmethod
    def entry_named(cls, value: EntryNameStr) -> EntryNameStr:
        if not value:
            raise lib_err.Error(lib_err.ERR_ARGS, arg="entry")   # validate_input -> (_, error)
        return value


class Parameters(BaseModel):
    arguments: Arguments
    SYNOPSIS: ClassVar[lib_ipt.Synopsis] = lib_ipt.Synopsis([
        lib_ipt.Pattern(options={"h"}, args=(0, 0), action=Action.USAGE),
        lib_ipt.Pattern(options={"help"}, args=(0, 0), action=Action.USAGE),
        lib_ipt.Pattern(options={"json-schema"}, args=(0, 0), action=Action.SCHEMA),
        lib_ipt.Pattern(options=set(), args=(2, 2), action=Action.GET),
    ])
# [⫶] contract


# […] implementation
def get(
    entry: EntryNameStr, entries: dict[EntryNameStr, EntryStr]
) -> tuple[EntryStr | None, lib_err.Error | None]:
    """ Look up one entry by name."""
    if entry not in entries:
        return None, lib_err.Error(ERR_NO_ENTRY, entry=entry)
    return entries[entry], None
# [⫶] implementation


# […] main
def main(
    action: Action, config: Config, params: Parameters
) -> tuple[str | None, lib_err.Error | None]:
    """[≟] Dispatch the resolved action to its handler."""
    match action:
        case Action.USAGE:
            return lib_ipt.usage(__doc__), None
        case Action.SCHEMA:
            return lib_ipt.schema(Config, Parameters), None
        case Action.GET:
            return get(params.arguments.entry, config.entries)


if __name__ == "__main__":
    config = lambda: lib_ipt.get_config("entries.yml", Config)
    out, error = main(*lib_ipt.validate_input(Parameters, sys.argv[1:], config))
    if error:
        print(error.message(ERRORS), file=sys.stderr)
        sys.exit(error.code)
    print(out)
# [⫶] main
```

## Testing

**Do:**

- **Do** test every script under `tests/scripts/python/<script-name>/`.
- **Do** declare test cases as data in a `cases.yml` next to the test, one entry per case with a `name`, the `input`/`args`, the expected `exit`, and the expected `stdout` (a fixture filename) or `stderr`.
- **Do** group cases into `#[…] positive` / `#[…] error` labeled sections.
- **Do** load the cases with `load_cases` and drive a single parametrized `test_case` with the `@cases(...)` decorator (ids come from each case's `name`).
- **Do** reuse `s_rt_scripts_test_lib` (`load_cases`/`cases`, `run`, `match_line`).
- **Do** reuse the shared `test_show_usage` to assert `--help`/`-h` prints the module docstring and exits `0`, and the shared `test_schema` to assert `--json-schema` prints the contract's JSON Schema and exits `0`.
- **Do** wrap an expected `stderr`/`stdout` line in `/.../ ` to match it as a regex (via `match_line`); a bare string matches exactly.
- **Do** prefer fixture files under `fixture/` (staged into `tmp_path` per case) for templates and JSON Schema output.

**Don't:**

- **Don't** hardcode cases in the test body; keep them in `cases.yml`.

<!--[⫶] 🤖🤖 -->
