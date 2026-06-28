from typing import ClassVar
from typing import Self

from pydantic import BaseModel
from pydantic import ValidationError
from pydantic import model_validator

from root_scripts_lib import errors as err
from root_scripts_lib.config import BaseConfig
from root_scripts_lib.parameters import USAGE
from root_scripts_lib.parameters import BaseParameters


##[>] 🤖🤖
class BaseInput(BaseModel):
    """The validated invocation wrapping its `params` and optional `config`."""

    PARAMS: ClassVar[type[BaseParameters]] = BaseParameters
    CONFIG: ClassVar[type[BaseConfig] | None] = None

    params: BaseParameters
    config: BaseConfig | None = None

    @model_validator(mode="before")
    @classmethod
    def from_argv(cls, data: object) -> object:
        """Build `params` from argv, and `config` only when the action needs it.

        Interfaces with:
          - files: the /etc/custom config (read by `BaseConfig.fill`)
        """
        if not isinstance(data, list):
            return data
        params = cls.PARAMS.model_validate(data)
        shaped: dict[str, object] = {"params": params}
        if cls.CONFIG is not None and params.action != USAGE:
            shaped["config"] = cls.CONFIG()
        return shaped

    @classmethod
    def validate_input(
        cls, argv: list[str]
    ) -> "tuple[Self, None] | tuple[None, err.Error]":
        """Validate argv into the Input model, returning (input, None) or (None, error)."""
        try:
            return cls.model_validate(argv), None
        except err.Error as error:
            return None, error
        except ValidationError:
            return None, err.Error(err.Errors.ARGS, args=argv)


def usage(doc: str | None) -> str:
    """The stripped module docstring, or "invalid usage" when it is empty."""
    return (doc or "").strip() or "invalid usage"


##[<] 🤖🤖
