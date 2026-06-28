from pathlib import Path

import pytest
import yaml


def load_cases(anchor_file, name):
    return yaml.safe_load((Path(anchor_file).parent / name).read_text())


def cases(rows):
    return pytest.mark.parametrize("case", rows, ids=lambda c: c["name"])
