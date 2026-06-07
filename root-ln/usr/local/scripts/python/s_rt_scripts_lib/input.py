from typing import ClassVar

from pydantic import BaseModel
from pydantic import ValidationError
from pydantic import model_validator

from s_rt_scripts_lib import errors as err
from s_rt_scripts_lib.config import BaseConfig
from s_rt_scripts_lib.parameters import BaseAction
from s_rt_scripts_lib.parameters import BaseParameters


# […] 🤖🤖
class BaseInput(BaseModel):
    """The validated invocation wrapping its `params` and optional `config`."""

    PARAMS: ClassVar[type[BaseParameters]] = BaseParameters
    CONFIG: ClassVar[type[BaseConfig] | None] = None

    params: BaseParameters
    config: BaseConfig | None = None

    @model_validator(mode="before")
    @classmethod
    def from_argv(cls, data: object) -> object:
        """Build `params` from argv and `config` when the action needs it."""
        if not isinstance(data, list):
            return data
        params = cls.PARAMS.model_validate(data)
        needs_config = (
            cls.CONFIG is not None and params.action != BaseAction.USAGE
        )
        return {
            "params": params,
            "config": cls.CONFIG() if needs_config else None,
        }

    @classmethod
    def validate_input(
        cls, argv: list[str]
    ) -> tuple["BaseInput | None", err.Error | None]:
        """Validate argv into the Input model, returning (input, error)."""
        try:
            return cls.model_validate(argv), None
        except err.Error as error:
            return None, error
        except ValidationError:
            return None, err.Error(err.Errors.ARGS, args=argv)


def usage(doc: str | None) -> str:
    """The stripped module docstring, or "invalid usage" when it is empty."""
    return (doc or "").strip() or "invalid usage"


# [⫶] 🤖🤖
