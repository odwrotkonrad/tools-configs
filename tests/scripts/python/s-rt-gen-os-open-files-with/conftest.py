import importlib.util
from pathlib import Path

import pytest

HERE = Path(__file__).resolve().parent
SCRIPT = (
    HERE.parents[3]
    / "root-ln/usr/local/scripts/python/s-rt-gen-os-open-files-with"
)
MOCK = HERE / "mock"


def _load():
    spec = importlib.util.spec_from_loader("gen_os", loader=None, origin=str(SCRIPT))
    module = importlib.util.module_from_spec(spec)
    exec(compile(SCRIPT.read_text(), str(SCRIPT), "exec"), module.__dict__)
    return module


@pytest.fixture
def gen_os():
    """The s-rt-gen-os-open-files-with script loaded as a module."""
    return _load()
