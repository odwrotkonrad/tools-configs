import os
from pathlib import Path
from typing import ClassVar

from pydantic import BaseModel
from pydantic import TypeAdapter
from pydantic import ValidationError
from pydantic import model_validator
import yaml

from s_root_scripts_lib import errors as err

type RawConfigDict = dict[str, object]
"""the untyped mapping parsed from a YAML config file."""


##[>] 🤖🤖
class BaseConfig(BaseModel):
    """Reads the system + user /etc/custom/<NAME> YAML files into `data`."""

    NAME: ClassVar[str]

    @classmethod
    def custom_paths(cls) -> list[Path]:
        """The standardized /etc/custom/<NAME> then $XDG/custom/<NAME> pair."""
        xdg = os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")
        return [Path("/etc/custom") / cls.NAME, Path(xdg) / "custom" / cls.NAME]

    @staticmethod
    def _parse(path: Path) -> RawConfigDict:
        """Parse one YAML file to a dict, raising err.Error on a syntax error."""
        try:
            return yaml.safe_load(path.read_text()) or {}
        except yaml.YAMLError as exc:
            raise err.Error(err.Errors.CONFIG, path=str(path), reason=exc)

    @staticmethod
    def _merge(base: RawConfigDict, over: RawConfigDict) -> RawConfigDict:
        """Deep-merge `over` into `base` in place, `over` winning on leaves."""
        for key, value in over.items():
            existing = base.get(key)
            if isinstance(value, dict) and isinstance(existing, dict):
                BaseConfig._merge(existing, value)
            else:
                base[key] = value
        return base

    @model_validator(mode="after")
    def fill(self) -> "BaseConfig":
        """Read and merge the system + user config for `NAME` into `data`."""
        paths = type(self).custom_paths()
        existing = [p for p in paths if p.is_file()]
        if not existing:
            raise err.Error(err.Errors.FILE_NOT_FOUND, path=str(paths[0]))
        raw: RawConfigDict = {}
        for path in existing:
            self._merge(raw, self._parse(path))
        adapter: TypeAdapter[object] = TypeAdapter(
            type(self).model_fields["data"].annotation
        )
        try:
            object.__setattr__(self, "data", adapter.validate_python(raw))
        except ValidationError as exc:
            raise err.Error(
                err.Errors.CONFIG, path=str(existing[0]), reason=exc
            ) from exc
        return self


##[<] 🤖🤖
