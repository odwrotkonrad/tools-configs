---
paths:
  - "**/root-ln/usr/local/scripts/python/**"
  - "/usr/local/scripts/python/**"
---

## Python Scripts

Avoid mutating downstream interfaces. Output results to stdout. Mutating side effects (writes, network, `duti`, …) live in the shell consuming the output.

### Docstrings

Every script opens with a module docstring laid out as:

```
usage: <name> <args>

<one line on what it does>:

1. <step from input ...>
2. <... toward output>
3. print the result to stdout

Interfaces with:
- files: <what it reads/writes>

Exit Codes:
- 21 <domain error>
- 11 <common error reused>
```

The numbered steps trace the input-to-output path; `Interfaces with:` lists the non-obvious external interfaces touched (files, CLIs, URLs — not stdio, see [Docstrings](python.md#docstrings)); `Exit Codes:` lists every code the script can emit (its own domain codes and the common ones it reuses).

### Contract - Schema

The script defines its input above the code, as pydantic models:

- `Action` — the actions the script supports. Every script carries the standard `USAGE` (`--help`/`-h`) and `SCHEMA` (`--json-schema`, prints the JSON Schema of the contract models) alongside its own.

  ```python
  class Action(StrEnum):
      USAGE = "usage"
      SCHEMA = "schema"
      GET = "get"
  ```

- `Config` — the validated config file, when the script reads one. A script with no config file omits the model and passes no `config` builder to `parse_input`; the config slot is then `None`.

  ```python
  class Config(BaseModel):
      root: RootPathStr
      entries: dict[EntryNameStr, EntryStr] = {}
  ```

- `Parameters` — the validated invocation: positional `arguments` and, when the script takes flags, `options`, carrying the `Synopsis` (the input→action grammar: option set + arg count → `Action`) as `ClassVar` metadata. A flag-less script omits the `Options` model and the `options` field. Validate each argument on its field with a `field_validator`; a validator failing a precondition raises `err.ExitError(code)` so the resolved exit code (e.g. `ERR_FILE_NOT_FOUND`) reaches the shell instead of the generic `ERR_ARGS`.

  ```python
  class Arguments(BaseModel):
      group: GroupNameStr
      entry: EntryNameStr

      @field_validator("entry")
      @classmethod
      def entry_exists(cls, value: EntryNameStr) -> EntryNameStr:
          if not Path(value).is_file():
              raise err.ExitError(err.ERR_FILE_NOT_FOUND, path=value)
          return value

  class Options(BaseModel):
      verbose: bool = False

  class Parameters(BaseModel):
      arguments: Arguments
      options: Options
      SYNOPSIS: ClassVar[Synopsis] = Synopsis([
          Pattern(options={"h"}, args=(0, 0), action=Action.USAGE),
          Pattern(options={"help"}, args=(0, 0), action=Action.USAGE),
          Pattern(options={"json-schema"}, args=(0, 0), action=Action.SCHEMA),
          Pattern(options=set(), args=(2, 2), action=Action.GET),
      ])
  ```

A handler returns its result directly (a `str` printed to stdout); there is no `Output` model.

### Contract - Errors

Exit codes are the script's error contract, banded by origin: common codes live in the lib — `usr/local/scripts/python/s_rt_scripts_lib/errors.py` in the `1x` band (`ERR_ARGS`, `ERR_CONFIG`, `ERR_FILE_NOT_FOUND`); a script's own domain errors use the `2x` band, each script numbering from `21`. Reuse the common codes; define domain codes in the script. The module docstring lists them under `Exit Codes:`.

Each code maps to a default, templated message in the lib's `ERRORS` table (placeholders like `{path}` filled from context). Raise `err.ExitError(code, **context)` where the failure is detected — in a `field_validator`, a handler, anywhere. The `__main__` gate is the single place that exits: it wraps `main(*parse_input(...))` in one `except err.ExitError`, writes `e.message` to stderr, and `sys.exit(e.code)`. A script registers its domain codes' messages by merging into `err.ERRORS`, its own entries taking precedence.

```python
from s_rt_scripts_lib import errors as err

ERR_OP = 21
err.ERRORS = {ERR_OP: "op read failed: {ref}"} | err.ERRORS

raise err.ExitError(ERR_OP, ref=secret_ref)   # caught by the gate -> stderr + exit 21
```

### Structure

Common pieces that build this structure live in `s_rt_scripts_lib` (e.g. `parse_input`/`Synopsis` in `cli`, `get_config` in `config`); reuse them rather than reimplementing. The body is divided into labeled `# […] name` / `# [⫶]` sections, in this order:

1. **`# […] errors`** — the script's domain exit codes and their `ERRORS` messages (omit when the script has none).
2. **`# […] types`** — the semantic `type X = base` aliases.
3. **`# […] contract`** — the pydantic models: `Action`, `Arguments`/`Options`, `Parameters`, `Config` ([Contract - Schema](#contract---schema)).
4. **`# […] implementation`** — the handlers and their helpers. Defined here, before `main`, so the gate can call them.
5. **`# […] main`** — `main` then the `if __name__ == "__main__"` gate, last (it runs in source order, so everything it calls must already be defined above).

The gate parses input in the lib (the grammar comes from `Parameters.SYNOPSIS`) → `(Action, Config, Parameters)`, then invokes `main(Action, Config, Parameters)`, the two wrapped in one `except err.ExitError` that writes the message to stderr and exits the code (see [Contract - Errors](#contract---errors)). `main` is a pure dispatch: a `match action` where every action maps to its own function. A handler takes only the exact values it needs — never a whole `Config`/`Parameters`.

```python
from s_rt_scripts_lib import errors as err
from s_rt_scripts_lib.cli import parse_input, schema, usage
from s_rt_scripts_lib.config import get_config

# […] types
type RootPathStr = str
type GroupNameStr = str
type EntryNameStr = str
type EntryStr = str
# [⫶]


# […] contract
class Action(StrEnum): ...
class Config(BaseModel): ...
class Parameters(BaseModel): ...   # carries SYNOPSIS: ClassVar[Synopsis]
# [⫶]


# […] implementation
def get(entry: EntryNameStr, entries: dict[EntryNameStr, EntryStr]) -> EntryStr:
    """[≟] Look up one entry by name."""
    return entries[entry]
# [⫶]


# […] main
def main(action: Action, config: Config, params: Parameters) -> None:
    """[≟] Dispatch the resolved action to its handler."""
    match action:
        case Action.USAGE:
            out = usage(__doc__)
        case Action.SCHEMA:
            out = schema(Config, Parameters)
        case Action.GET:
            out = get(params.arguments.entry, config.entries)
    print(out)


if __name__ == "__main__":
    try:
        config = lambda: get_config("entries.yml", Config)
        main(*parse_input(Parameters, sys.argv[1:], config))
    except err.ExitError as e:
        print(e.message, file=sys.stderr)
        sys.exit(e.code)
# [⫶]
```

A config-less script drops the `Config` model and the builder — `main(action, params)` and `main(action, _, params) = parse_input(Parameters, argv)` (config slot `None`).
