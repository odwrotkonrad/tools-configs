---
paths:
  - "**/root/usr/local/scripts/python/**"
  - "/usr/local/scripts/python/**"
  - "**/ci/python/scripts/**"
---

<!-- ##[>] 🤖🤖 -->
## Python Scripts

- Output results to stdout.
- Keep external writes (files, network) in the consuming shell, never in the script.

### Docstrings

- Open every script with a module docstring (see Example).
- Trace input-to-output as numbered steps.
- List invocation forms under `Examples:`, one `$ <script> ...` per synopsis plus `$ <script> --help`.
- List non-obvious external interfaces, split by direction, omitting empty sections and stdio:
  - `Upstream Interfaces with:` for consumers of the printed output (`$ duti`, `$ alias -s`).
  - `Downstream Interfaces with:` for sources read/invoked (config files, URL, cache).
- List every exit code under `Exit Codes:`.

### Input

- Validate input before `main`.
- Model input with pydantic above the code:
  - `Parameters(lib_param.BaseParameters)`: base carries `options`, resolved `action`, base `SYNOPSIS`. Subclass adds `arguments`, extends `SYNOPSIS` via `[*lib_param.BaseParameters.SYNOPSIS, ...]`, adds own `Options` when flags exist.
  - `Action(lib_param.BaseAction)`: add own actions. Base `USAGE` (`--help`/`-h`) is default.
  - `Config(lib_cfg.BaseConfig)` (only with a config file): set `NAME` ClassVar (`/etc/custom/<NAME>`) and typed `data` field. Base reads+merges system+user files on construction.
  - `Input(lib_input.BaseInput)`: set `PARAMS` (and `CONFIG`) ClassVars and matching `params`/`config` fields. Set `ARGUMENTS` on a `Parameters` with positional args.
- Make `data` a plain typed field (`dict[...]` or `BaseModel`), attribute access (`config.data.field`). Pass `config.data` to handlers.
- Validate natively: `Input.validate_input(argv)` → `(input, error)`. Builds `params` (`from_argv` resolves action, shapes fields) and `config`.
- Validate/prepare with pydantic validators. Reject by raising domain `err.Error` (subclasses `Exception`, propagates unwrapped). `validate_input` catches it (stray `ValidationError` → `Errors.ARGS`), keeping the rest exception-free.
- Declare unused slots as `None` (no `Options` for flag-less, no `Config` for config-less).
- Keep `Config.data` a plain typed field, never `RootModel`.
- Let handlers return results directly, no `Output` model.

### Errors

- Treat exit codes as the contract, banded by origin.
- Reuse `1x` lib codes from `root_scripts_lib/errors.py`: `Errors.ARGS`, `Errors.CONFIG`, `Errors.FILE_NOT_FOUND`, `Errors.NETWORK`.
- Define domain errors in the `2x` band, numbering each script from `21`.
- Declare a local `Errors(lib_err.Errors)`: add `2x` codes, extend `MESSAGES` as `lib_err.Errors.MESSAGES | {domain codes}` (own entries win), keep `lib_err.Errors.MESSAGES` untouched.
- Return an `Error` (code + context, e.g. `{path}`) from where the failure is detected, alongside output. `main` propagates it to the gate, which resolves via `Errors.message(error)`.
- Call `sys.exit` only in the `__main__` gate.

### Structure

- Reuse `root_scripts_lib`: `BaseInput`/`usage`, `BaseParameters`/`BaseAction`/`Pattern`, `ScriptBaseOptions`, `BaseConfig`.
- Divide body into labeled `##[>] name` / `##[<]` sections, in order:
  1. `##[>] errors`: domain codes + `MESSAGES` (omit if none).
  2. `##[>] types`: `type X = base` aliases.
  3. `##[>] contract`: pydantic models: `Action`, `Arguments`/`Options`, `Parameters`, `Config`.
  4. `##[>] implementation`: handlers + helpers, before `main`.
  5. `##[>] main`: `main` then `if __name__ == "__main__"` gate, last.
- Make `main(input)` pure dispatch: `match input.params.action`, each action → its own function.
- Keep the `main` pipeline flat (input-to-output path).
- Make every function return `(output, Error | None)`. `main` returns the action's resolved tuple.
- Define functions at module level (no nesting).
- Pass handlers exactly what they need (not whole `Config`/`Parameters`).
- Exit from the `__main__` gate: `input, error = Input.validate_input(sys.argv[1:])`, on no error run `main`, print output to stdout, or error to stderr + `sys.exit(error.code)`.

## Example - Script

```python
"""usage: get <group> <entry>

Get one entry's value from the config:

1. read and merge the system + user config
2. look up <entry> under <group>
3. print the value to stdout

Examples:

    $ get colors background
    $ get --help

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
from root_scripts_lib import config as lib_cfg
from root_scripts_lib import errors as lib_err
from root_scripts_lib import input as lib_input
from root_scripts_lib import parameters as lib_param

##[>] errors
class Errors(lib_err.Errors):
    NO_ENTRY = 21
    MESSAGES = lib_err.Errors.MESSAGES | {NO_ENTRY: "entry not found: {entry}"}
##[<] errors


##[>] types
type GroupNameStr = str
type EntryNameStr = str
type EntryStr = str
##[<] types


##[>] contract
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
##[<] contract


##[>] implementation
def get(
    entry: EntryNameStr, entries: dict[EntryNameStr, EntryStr]
) -> tuple[EntryStr | None, lib_err.Error | None]:
    """Look up one entry by name."""
    if entry not in entries:
        return None, lib_err.Error(Errors.NO_ENTRY, entry=entry)
    return entries[entry], None
##[<] implementation


##[>] main
def main(input: Input) -> tuple[str | None, lib_err.Error | None]:
    """[what] Dispatch the resolved action to its handler."""
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
##[<] main
```

## Testing

- Test every script under `tests/scripts/python/<script-name>/`.
- Declare cases as data in a sibling `cases.yml`: `name`, `input`/`args`, expected `exit`, expected `stdout` (fixture filename) or `stderr`.
- Group cases into `##[>] positive` / `##[>] error` sections.
- Load with `load_cases`, drive one parametrized `test_case` via `@cases(...)` (ids from `name`).
- Reuse `root_scripts_test_lib`: `load_cases`/`cases`, `run`, `match_line`.
- Reuse shared `test_show_usage` (asserts `--help`/`-h` prints docstring, exits `0`).
- Wrap expected `stderr`/`stdout` in `/.../ ` for regex (via `match_line`). Bare string matches exactly.
- Prefer fixture files under `fixture/` (staged into `tmp_path` per case).
- Keep cases in `cases.yml`, not the test body.
<!-- ##[<] 🤖🤖 -->
