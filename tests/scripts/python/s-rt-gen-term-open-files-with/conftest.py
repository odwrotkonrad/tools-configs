from pathlib import Path
from types import SimpleNamespace

import pytest

MOCK = Path(__file__).resolve().parent / "mock"
MOCK_LANGUAGES = (MOCK / "languages.yml").read_text()


def fake_response(url, timeout=None):  # noqa: ARG001
    return SimpleNamespace(text=MOCK_LANGUAGES, raise_for_status=lambda: None)


@pytest.fixture
def term_script(load_script, mocker, tmp_path):
    """term_script module with a tmp cache and the mock terminal config."""
    module = load_script("s-rt-gen-term-open-files-with", alias="term_script")
    cache = tmp_path / "linguist"
    mocker.patch.object(module, "CACHE_DIR", cache)
    mocker.patch.object(module, "DEFAULT_CONFIG", str(MOCK / "term.yml"))
    module.cache_dir = cache
    return module


@pytest.fixture
def script(term_script):
    return term_script


@pytest.fixture(autouse=True)
def mock_fetch(mocker):
    """Patch linguist fetch for every test; fetch-specific tests re-patch to override."""
    return mocker.patch("requests.get", side_effect=fake_response)
