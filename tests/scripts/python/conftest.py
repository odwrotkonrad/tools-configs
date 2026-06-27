import importlib.util
from pathlib import Path
import sys

import pytest

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SCRIPTS_DIRS = (
    REPO / "root/usr/local/scripts/python",
    REPO / "ci/python/scripts",
)

for path in (HERE, *SCRIPTS_DIRS):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))


@pytest.fixture
def load_script():
    """Return a loader for the no-extension scripts under SCRIPTS_DIRS."""
    loaded = []

    def loader(name, alias=None):
        script = next(d / name for d in SCRIPTS_DIRS if (d / name).is_file())
        modname = alias or name.replace("-", "_")
        spec = importlib.util.spec_from_loader(
            modname, loader=None, origin=str(script)
        )
        module = importlib.util.module_from_spec(spec)
        sys.modules[modname] = module
        exec(compile(script.read_text(), str(script), "exec"), module.__dict__)
        loaded.append(modname)
        return module

    yield loader

    for modname in loaded:
        sys.modules.pop(modname, None)
