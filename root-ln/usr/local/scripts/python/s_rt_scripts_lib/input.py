import json
import re
from typing import ClassVar

from pydantic import BaseModel
from pydantic import RootModel
from pydantic import ValidationError

from s_rt_scripts_lib import errors as err
from s_rt_scripts_lib.config import get_config as get_config

OPT = re.compile(r"^-(\w)$|^--([\w-]+)$")


# […] 🤖🤖
class BaseAction:
    """Actions every script carries: --help/-h, --json-schema, and abort.

    Scripts subclass to add their domain actions; `validate_input` returns
    ABORT on a rejected invocation.
    """

    USAGE = "usage"
    SCHEMA = "schema"
    ABORT = "abort"


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


class BaseParameters(BaseModel):
    """The invocation shape every script carries; scripts subclass.

    Provides the base options and the base input->action grammar; a subclass
    adds its `arguments` and merges its own patterns into `SYNOPSIS`.
    """

    options: ScriptBaseOptions = ScriptBaseOptions()
    SYNOPSIS: ClassVar[Synopsis] = BASE_SCRIPT_SYNOPSIS


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
    """Resolve argv against the synopsis to (action, options, args, error).

    Returns err.Error(ERR_ARGS, args=argv) as the fourth element when no
    pattern matches; the action is then BaseAction.ABORT.
    """
    options, args = split_argv(argv)
    action = synopsis.action(frozenset(options), len(args))
    if action is None:
        return (
            BaseAction.ABORT,
            options,
            args,
            err.Error(err.Errors.ARGS, args=argv),
        )
    return action, options, args, None


def build_params(model, options, args):
    """Construct a Parameters model from the resolved invocation.

    Maps positional `args` onto the `arguments` submodel's fields in order, and
    `options` flags onto the `options` submodel when the model declares one.
    Returns (params, None); a ValidationError from a field validator is raised
    here and caught by validate_input.
    """
    fields = model.model_fields
    arg_names = list(fields["arguments"].annotation.model_fields)
    kwargs = {"arguments": dict(zip(arg_names, args))}
    if "options" in fields:
        opt_names = set(fields["options"].annotation.model_fields)
        kwargs["options"] = {n: True for n in options if n in opt_names}
    return model(**kwargs)


def from_validation_error(exc, args):
    """Recover the domain err.Error a validator carried, else ERR_ARGS.

    A field validator signals a domain failure by raising
    ValueError(err.Error(...)); pydantic wraps it, and its payload surfaces
    here. When no such payload is present, fall back to ERR_ARGS.
    """
    for detail in exc.errors():
        cause = (detail.get("ctx") or {}).get("error")
        payload = getattr(cause, "args", (None,))[0] if cause else None
        if isinstance(payload, err.Error):
            return payload
    return err.Error(err.Errors.ARGS, args=args)


def validate_input(model, argv, config=None):
    """Resolve argv to (action, config, params) via model.SYNOPSIS.

    `config` is an optional zero-arg builder for the Config instance; when
    omitted the config slot stays None. On a bad invocation or a failed field
    validation the action is BaseAction.ABORT and the params slot carries the
    resolved err.Error, so main's ABORT arm surfaces it.
    """
    action, options, args, error = resolve(model.SYNOPSIS, argv)
    if error is not None:
        return BaseAction.ABORT, None, error
    if not args:
        return action, None, None
    cfg = config() if config is not None else None
    try:
        params = build_params(model, options, args)
    except ValidationError as exc:
        return BaseAction.ABORT, None, from_validation_error(exc, args)
    return action, cfg, params


def usage(doc):
    """The stripped module docstring, or "invalid usage" when it is empty."""
    return (doc or "").strip() or "invalid usage"


def schema(*models):
    """Pretty-printed JSON Schema of each contract model, blank-line joined."""
    return "\n\n".join(
        json.dumps(model.model_json_schema(), indent=2) for model in models
    )


# [⫶] 🤖🤖
