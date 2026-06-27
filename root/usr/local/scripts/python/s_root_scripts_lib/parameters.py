from enum import StrEnum
import re
from typing import ClassVar

from pydantic import BaseModel
from pydantic import model_validator

from s_root_scripts_lib import errors as err
from s_root_scripts_lib.options import ScriptBaseOptions

USAGE = "usage"
"""the base usage action value, shared by every script's Action."""


##[>] 🤖🤖
class BaseAction(StrEnum):
    """The action base; each script's Action extends it with its own members."""


class Pattern(BaseModel):
    """One synopsis line: options == set, args within min..max -> action."""

    options: frozenset[str] = frozenset()
    args: tuple[int, int] = (0, 0)
    action: str

    def matches(self, options: frozenset[str], nargs: int) -> bool:
        lo, hi = self.args
        return options == self.options and lo <= nargs <= hi


class BaseParameters(BaseModel):
    """The invocation validated from argv; subclasses add `arguments`/`SYNOPSIS`."""

    action: BaseAction
    options: ScriptBaseOptions = ScriptBaseOptions()
    ARGUMENTS: ClassVar[type[BaseModel] | None] = None
    SYNOPSIS: ClassVar[list[Pattern]] = [
        Pattern(options=frozenset({"h"}), args=(0, 0), action=USAGE),
        Pattern(options=frozenset({"help"}), args=(0, 0), action=USAGE),
    ]

    @classmethod
    def action_for(cls, options: frozenset[str], nargs: int) -> str | None:
        """The action of the first SYNOPSIS pattern matching options + arg count."""
        for pattern in cls.SYNOPSIS:
            if pattern.matches(options, nargs):
                return pattern.action
        return None

    @staticmethod
    def _split_argv(argv: list[str]) -> tuple[set[str], list[str]]:
        """Bucket argv into an options set and a positional argument list."""
        options: set[str] = set()
        args: list[str] = []
        for tok in argv:
            if m := re.match(r"^-(\w)$|^--([\w-]+)$", tok):
                options.add(m.group(1) or m.group(2))
            else:
                args.append(tok)
        return options, args

    @model_validator(mode="before")
    @classmethod
    def from_argv(cls, data: object) -> object:
        """Shape an argv list into `action`/`options`/`arguments`; pass a dict through."""
        if not isinstance(data, list):
            return data
        options, args = cls._split_argv(data)
        action = cls.action_for(frozenset(options), len(args))
        if action is None:
            raise err.Error(err.Errors.ARGS, args=data)
        options_model = cls.model_fields["options"].annotation
        opt_names = set(
            options_model.model_fields if options_model is not None else {}
        )
        shaped = {
            "action": action,
            "options": dict.fromkeys(options & opt_names, True),
        }
        if args and cls.ARGUMENTS is not None:
            shaped["arguments"] = dict(zip(cls.ARGUMENTS.model_fields, args))
        return shaped


##[<] 🤖🤖
