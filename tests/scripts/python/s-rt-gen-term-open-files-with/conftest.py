import importlib.util
from pathlib import Path
from types import SimpleNamespace

import pytest

HERE = Path(__file__).resolve().parent
SCRIPT = (
    HERE.parents[3]
    / "root-ln/usr/local/scripts/python/s-rt-gen-term-open-files-with"
)
MOCK = HERE / "mock"
MOCK_LANGUAGES = (MOCK / "languages.yml").read_text()


def _load():
    spec = importlib.util.spec_from_loader("gen_term", loader=None, origin=str(SCRIPT))
    module = importlib.util.module_from_spec(spec)
    exec(compile(SCRIPT.read_text(), str(SCRIPT), "exec"), module.__dict__)
    return module


@pytest.fixture
def gen_term(monkeypatch, tmp_path):
    """gen_term module with a tmp cache and the mock terminal config.

    `requests.get` is mocked to return the trimmed mock/languages.yml fixture
    instead of hitting the network. `module.fetches` records each requested url.
    """
    module = _load()

    cache = tmp_path / "linguist"
    monkeypatch.setattr(module, "CACHE_DIR", cache)
    monkeypatch.setattr(module, "DEFAULT_CONFIG", str(MOCK / "term.yml"))

    fetches = []

    def fake_get(url, timeout=None):  # noqa: ARG001
        fetches.append(url)
        return SimpleNamespace(text=MOCK_LANGUAGES, raise_for_status=lambda: None)

    monkeypatch.setattr(module.requests, "get", fake_get)

    module.cache_dir = cache
    module.fetches = fetches
    return module
