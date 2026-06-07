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
- **Do** show the invocation forms under `Examples:`, one `$ <script> ...` line per distinct synopsis (each domain form plus `$ <script> --help`).
- **Do** list non-obvious external interfaces touched (files, CLIs, URLs) split into two sections by data-flow direction:
  - **`Upstream Interfaces with:`** — what the script is invoked for: the intended consumer of the printed output (e.g. `$ duti`, `$ alias -s`).
  - **`Downstream Interfaces with:`** — what the script invokes or reads: the sources it pulls from (config files, a fetched URL, an on-disk cache).
  - omit either section when the script has no interface in that direction.
- **Do** list every exit code the script can emit (its own domain codes and the common ones it reuses) under `Exit Codes:`.

**Don't:**

- **Don't** list stdio as an external interface (see [Docstrings](python.md#docstrings)).

### Input

**Do:**

- **Do** validate input before invoking the `main` function.
- **Do** validate input with pydantic models defined above the code: a `Parameters(lib_param.BaseParameters)` subclass (the base carries the standard `options`, the resolved `action`, and the base `SYNOPSIS`; the subclass adds `arguments`, extends the pattern list via `[*lib_param.BaseParameters.SYNOPSIS, ...]`, and, when the script takes flags, its own `Options`), a `Config(lib_cfg.BaseConfig)` (when the script uses a config file), and an `Input(lib_input.BaseInput)` wrapper declaring concrete `params`/`config` field types.
- **Do** declare an `Action(lib_param.BaseAction)` subclass adding its own actions; the base carries `USAGE` (`--help`/`-h`), which is also the default `action`.
- **Do** declare a `Config(lib_cfg.BaseConfig)` model for the config file, when the script uses one: set the `NAME` ClassVar (its `/etc/custom/<NAME>` filename) and the typed `data` field (its schema); `BaseConfig` reads and merges the system + user files into `data` on construction.
- **Do** make `data` a plain typed field (a `dict[...]` or a `BaseModel`) reached by attribute access (`config.data[...]`, `config.data.field`); a handler takes `config.data`, not the `Config`.
- **Do** declare an `Input(lib_input.BaseInput)` wrapper: set the `PARAMS` (and, with a config, `CONFIG`) model ClassVars and the matching `params`/`config` fields (`config: Config | None = None`, or `config: None = None` with no config). Likewise set `ARGUMENTS` on a `Parameters` that takes positional args. `Input.validate_input(argv)` builds it natively and returns `(input, error)`.
- **Do** use pydantic's validators (e.g. `field_validator`, `model_validator`) to validate and prepare models; a validator rejecting a value raises the domain `err.Error` directly (it subclasses `Exception`, so pydantic propagates it unwrapped), which `Input.validate_input` catches and returns (a stray pydantic `ValidationError` maps to the generic `ERR_ARGS`), so the rest of the script stays exception-free.
- **Do** validate the invocation natively: `Input.validate_input(argv)` calls `Input.model_validate(argv)`, whose `from_argv` validator builds `params` (its `from_argv` resolves the `action` and shapes the fields) and `config` (when the action consumes it); declare `arguments` as `Arguments | None = None` (the base USAGE action carries no positional args, so the slot is `None` then and the handler reads it only when present).

**Don't:**

- **Don't** build models for input the script doesn't use (e.g. `Options` for a flag-less script, `Config` for one with no config file); the unused slot is then `None`.
- **Don't** wrap `Config.data` in a `RootModel` (it adds a `.root` hop); a plain typed field validates natively and reads directly.
- **Don't** add an `Output` model; a handler returns its result directly.

### Errors

**Do:**

- **Do** treat exit codes as the script's error contract, banded by origin.
- **Do** reuse the common codes from the lib `Errors` class — `usr/local/scripts/python/s_rt_scripts_lib/errors.py` in the `1x` band (`Errors.ARGS`, `Errors.CONFIG`, `Errors.FILE_NOT_FOUND`, `Errors.NETWORK`).
- **Do** define a script's own domain errors in the `2x` band, numbering each script from `21`.
- **Do** list every code under `Exit Codes:` in the module docstring.
- **Do** declare the script's contract as a local `Errors(lib_err.Errors)` subclass: add the `2x` domain codes and extend `MESSAGES` as a new dict from `lib_err.Errors.MESSAGES | {domain codes}` (the script's own entries taking precedence); never reassign or mutate `lib_err.Errors.MESSAGES`.
- **Do** return an `Error` (carrying the exit code and the context, e.g. `{path}`) from where the failure is detected (a handler, a helper), alongside the output; the gate resolves its message via the script's `Errors.message(error)`.

**Don't:**

- **Don't** raise exceptions to signal failures; return an `Error` instead and let `main` propagate it to the gate (see [Structure](#structure)).
- **Don't** call `sys.exit` outside the `__main__` gate.

### Structure

**Do:**

- **Do** reuse common pieces from `s_rt_scripts_lib`: `BaseInput`/`usage` in `input`, `BaseParameters`/`BaseAction`/`Pattern` in `parameters`, `ScriptBaseOptions` in `options`, `BaseConfig` in `config`, rather than reimplementing.
- **Do** divide the body into labeled `# […] name` / `# [⫶]` sections, in this order:
  1. **`# […] errors`** — the script's domain exit codes and their `ERRORS` messages (omit when the script has none).
  2. **`# […] types`** — the semantic `type X = base` aliases.
  3. **`# […] contract`** — the pydantic models: `Action`, `Arguments`/`Options`, `Parameters`, `Config` ([Input](#input)).
  4. **`# […] implementation`** — the handlers and their helpers, before `main`, so the gate can call them.
  5. **`# […] main`** — `main` then the `if __name__ == "__main__"` gate, last (it runs in source order, so everything it calls must already be defined above).
- **Do** make `main(input)` a pure dispatch: a `match input.params.action` where every action maps to its own function.
- **Do** keep the `main` pipeline flat so it clearly describes the path from input to output.
- **Do** make every function return its output and an optional `Error` (the exit code with its prepared message); `main` returns the resolved `(output, error)` for the action.
- **Do** exit the script from the `__main__` gate (around `main`): the gate calls `input, error = Input.validate_input(sys.argv[1:])`, then `main(input)` when there is no error, then prints the output to stdout, or the error message to stderr and `sys.exit(error.code)`.
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

Examples:

    $ s-rt-get colors background
    $ s-rt-get --help

Upstream Interfaces with:
- `$ export` — intended consumer of the printed value

Downstream Interfaces with:
- files: entries.yml (system + user)

Exit Codes:
- 21 entry not found
- 11 invalid arguments
"""

import sys
from typing import ClassVar

from pydantic import BaseModel
from pydantic import field_validator
from s_rt_scripts_lib import config as lib_cfg
from s_rt_scripts_lib import errors as lib_err
from s_rt_scripts_lib import input as lib_input
from s_rt_scripts_lib import parameters as lib_param

# […] errors
class Errors(lib_err.Errors):
    NO_ENTRY = 21
    MESSAGES = lib_err.Errors.MESSAGES | {NO_ENTRY: "entry not found: {entry}"}
# [⫶] errors


# […] types
type GroupNameStr = str
type EntryNameStr = str
type EntryStr = str
# [⫶] types


# […] contract
class Action(lib_param.BaseAction):
    GET = "get"


class Config(lib_cfg.BaseConfig):
    NAME: ClassVar[str] = "entries.yml"
    data: dict[EntryNameStr, EntryStr] = {}


class Arguments(BaseModel):
    group: GroupNameStr
    entry: EntryNameStr

    @field_validator("entry")
    @classmethod
    def entry_named(cls, value: EntryNameStr) -> EntryNameStr:
        if not value:
            raise lib_err.Error(Errors.ARGS, arg="entry")
        return value


class Parameters(lib_param.BaseParameters):
    arguments: Arguments | None = None
    ARGUMENTS: ClassVar[type[Arguments]] = Arguments
    SYNOPSIS: ClassVar[list[lib_param.Pattern]] = [
        *lib_param.BaseParameters.SYNOPSIS,
        lib_param.Pattern(options=set(), args=(2, 2), action=Action.GET),
    ]


class Input(lib_input.BaseInput):
    PARAMS: ClassVar[type[Parameters]] = Parameters
    CONFIG: ClassVar[type[Config]] = Config

    params: Parameters
    config: Config | None = None
# [⫶] contract


# […] implementation
def get(
    entry: EntryNameStr, entries: dict[EntryNameStr, EntryStr]
) -> tuple[EntryStr | None, lib_err.Error | None]:
    """Look up one entry by name."""
    if entry not in entries:
        return None, lib_err.Error(Errors.NO_ENTRY, entry=entry)
    return entries[entry], None
# [⫶] implementation


# […] main
def main(input: Input) -> tuple[str | None, lib_err.Error | None]:
    """[≟] Dispatch the resolved action to its handler."""
    match input.params.action:
        case Action.USAGE:
            return lib_input.usage(__doc__), None
        case Action.GET:
            return get(input.params.arguments.entry, input.config.data)


if __name__ == "__main__":
    input, error = Input.validate_input(sys.argv[1:])
    if not error:
        out, error = main(input)
    if error:
        print(Errors.message(error), file=sys.stderr)
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
- **Do** reuse the shared `test_show_usage` to assert `--help`/`-h` prints the module docstring and exits `0`.
- **Do** wrap an expected `stderr`/`stdout` line in `/.../ ` to match it as a regex (via `match_line`); a bare string matches exactly.
- **Do** prefer fixture files under `fixture/` (staged into `tmp_path` per case) for templates.

**Don't:**

- **Don't** hardcode cases in the test body; keep them in `cases.yml`.

<!--[⫶] 🤖🤖 -->
