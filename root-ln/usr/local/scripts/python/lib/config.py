import sys
from pathlib import Path

import yaml
from pydantic import ValidationError

from lib.errors import ERR_CONFIG, ERR_CONFIG_NOT_FOUND


def merge(base, over):
    for key, value in over.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            merge(base[key], value)
        else:
            base[key] = value
    return base


def validate(raw, model):
    try:
        return model.model_validate(raw)
    except ValidationError:
        sys.exit(ERR_CONFIG)


def parse(path):
    try:
        return yaml.safe_load(path.read_text()) or {}
    except yaml.YAMLError:
        sys.exit(ERR_CONFIG)


def load_yaml(path, model):
    if not path.is_file():
        sys.exit(ERR_CONFIG_NOT_FOUND)
    return validate(parse(path), model)


def load_merged(paths, model):
    existing = [Path(p) for p in paths if Path(p).is_file()]
    if not existing:
        sys.exit(ERR_CONFIG_NOT_FOUND)
    raw = {}
    for path in existing:
        merge(raw, parse(path))
    return validate(raw, model)
