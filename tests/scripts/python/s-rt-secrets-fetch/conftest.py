import os
from pathlib import Path
import shutil

import pytest

MOCK = Path(__file__).resolve().parent / "mock"


def fake_op(cmd, capture_output, text):  # noqa: ARG001
    container, field = cmd[-1].split("/")[-2:]  # op://vault/container/field
    return type(
        "R",
        (),
        {
            "returncode": 0,
            "stdout": f"{container}_{field}_value\n",
            "stderr": "",
        },
    )()


@pytest.fixture
def secrets_script(load_script, mocker, tmp_path):
    """secrets_script module with mock system+user config."""
    user_cfg = tmp_path / "custom" / "secrets.yml"
    user_cfg.parent.mkdir(parents=True)
    shutil.copy(MOCK / "user.yml", user_cfg)
    mocker.patch.dict(
        os.environ,
        {
            "AUTH_ETC_CONFIG": str(MOCK / "system.yml"),
            "XDG_CONFIG_HOME": str(tmp_path),
        },
    )
    return load_script("s-rt-secrets-fetch", alias="secrets")


@pytest.fixture
def script(secrets_script):
    return secrets_script


@pytest.fixture(autouse=True)
def mock_op(mocker):
    """Patch the `op` subprocess for every test; failure tests re-patch to override."""
    return mocker.patch("subprocess.run", side_effect=fake_op)


@pytest.fixture
def secrets_script_no_config(load_script, mocker, tmp_path):
    """secrets_script module with both config paths pointing at non-existent files."""
    mocker.patch.dict(
        os.environ,
        {
            "AUTH_ETC_CONFIG": str(tmp_path / "missing.yml"),
            "XDG_CONFIG_HOME": str(tmp_path),  # no custom/secrets.yml under it
        },
    )
    return load_script("s-rt-secrets-fetch", alias="secrets")


@pytest.fixture
def secrets_script_bad_config(load_script, mocker, tmp_path):
    """secrets_script with the etc config pointing at malformed YAML."""
    bad = tmp_path / "bad.yml"
    bad.write_text("foo: [unclosed\n")
    mocker.patch.dict(
        os.environ,
        {
            "AUTH_ETC_CONFIG": str(bad),
            "XDG_CONFIG_HOME": str(tmp_path / "empty"),
        },
    )
    return load_script("s-rt-secrets-fetch", alias="secrets")
