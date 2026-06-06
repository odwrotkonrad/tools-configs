from enum import StrEnum
import json
import re
import sys

from pydantic import BaseModel
from pydantic import RootModel
from pydantic import ValidationError

from s_rt_scripts_lib import errors as err

OPT = re.compile(r"^-(\w)$|^--([\w-]+)$")


class BaseAction(StrEnum):
    """Actions every script carries: --help/-h and --json-schema."""

    USAGE = "usage"
    SCHEMA = "schema"


class ScriptBaseOptions(BaseModel):
    """Options every script carries; scripts subclass to add their own."""

    help: bool = False
    json_schema: bool = False


class Pattern(BaseModel):
    """One synopsis line: options == set, args within min..max -> action."""

    options: frozenset[str] = frozenset()
    args: tuple[int, int] = (0, 0)
    action: str

    def matches(self, options, nargs):
        lo, hi = self.args
        return options == self.options and lo <= nargs <= hi


class Synopsis(RootModel[list[Pattern]]):
    """Input shape -> action table; first matching pattern wins."""

    def action(self, options, nargs):
        for pattern in self.root:
            if pattern.matches(options, nargs):
                return pattern.action
        return None

    def __or__(self, other: "Synopsis") -> "Synopsis":
        """Merge two synopses; this one's patterns are matched first."""
        return Synopsis([*self.root, *other.root])


BASE_SCRIPT_SYNOPSIS = Synopsis(
    [
        Pattern(options=frozenset({"h"}), args=(0, 0), action=BaseAction.USAGE),
        Pattern(
            options=frozenset({"help"}), args=(0, 0), action=BaseAction.USAGE
        ),
        Pattern(
            options=frozenset({"json-schema"}),
            args=(0, 0),
            action=BaseAction.SCHEMA,
        ),
    ]
)


def split_argv(argv):
    """Bucket argv into an options set and a positional argument list."""
    options, args = set(), []
    for tok in argv:
        if m := OPT.match(tok):
            options.add(m.group(1) or m.group(2))
        else:
            args.append(tok)
    return options, args


def resolve(synopsis, argv):
    """Resolve argv against the synopsis to (action, options, args).

    Raises err.ExitError(ERR_ARGS, args=argv) when no pattern matches.
    """
    options, args = split_argv(argv)
    action = synopsis.action(frozenset(options), len(args))
    if action is None:
        raise err.ExitError(err.ERR_ARGS, args=argv)
    return action, options, args


def build_params(model, options, args):
    """Construct a Parameters model from the resolved invocation.

    Maps positional `args` onto the `arguments` submodel's fields in order, and
    `options` flags onto the `options` submodel when the model declares one. A
    shape mismatch raises err.ExitError(ERR_ARGS); a field validator's
    err.ExitError propagates with its carried code and context.
    """
    fields = model.model_fields
    arg_names = list(fields["arguments"].annotation.model_fields)
    kwargs = {"arguments": dict(zip(arg_names, args))}
    if "options" in fields:
        opt_names = set(fields["options"].annotation.model_fields)
        kwargs["options"] = {n: True for n in options if n in opt_names}
    try:
        return model(**kwargs)
    except ValidationError:
        raise err.ExitError(err.ERR_ARGS, args=args) from None


def parse_input(model, argv, config=None):
    """Resolve argv to (action, config, params) via model.SYNOPSIS.

    `config` is an optional zero-arg builder for the Config instance (loads files
    / env); when omitted the config slot stays None. `model` is the Parameters
    class carrying SYNOPSIS. Raises err.ExitError on a bad invocation or a failed
    argument validation.
    """
    action, options, args = resolve(model.SYNOPSIS, argv)
    if not args:
        return action, None, None
    cfg = config() if config is not None else None
    return action, cfg, build_params(model, options, args)


def usage(doc):
    """The stripped module docstring, or "invalid usage" when it is empty."""
    return (doc or "").strip() or "invalid usage"


def schema(*models):
    """Pretty-printed JSON Schema of each contract model, blank-line joined."""
    return "\n\n".join(
        json.dumps(model.model_json_schema(), indent=2) for model in models
    )


def dispatch_meta(action, doc, *models):
    """Handle the generic actions: print usage/schema and exit, else return.

    Prints to stdout and exits 0 for the generic USAGE/SCHEMA actions; for any
    other action it returns so the caller dispatches its own actions.
    """
    if action == BaseAction.USAGE:
        print(usage(doc))
        sys.exit(0)
    if action == BaseAction.SCHEMA:
        print(schema(*models))
        sys.exit(0)
