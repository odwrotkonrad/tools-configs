import importlib.util
import shutil
from pathlib import Path

import pytest

HERE = Path(__file__).resolve().parent
SCRIPT = HERE.parents[2] / "root/usr/local/scripts_py/s_auth"
MOCK = HERE / "mock"


def _load_s_auth():
    spec = importlib.util.spec_from_loader("s_auth", loader=None, origin=str(SCRIPT))
    module = importlib.util.module_from_spec(spec)
    exec(compile(SCRIPT.read_text(), str(SCRIPT), "exec"), module.__dict__)
    return module


@pytest.fixture
def s_auth(monkeypatch, tmp_path):
    """s_auth module with mock system+user config and `op` mocked out."""
    monkeypatch.setenv("AUTH_ETC_CONFIG", str(MOCK / "system.yml"))

    user_cfg = tmp_path / "custom" / "secrets.yml"
    user_cfg.parent.mkdir(parents=True)
    shutil.copy(MOCK / "user.yml", user_cfg)
    monkeypatch.setenv("XDG_CONFIG_HOME", str(tmp_path))

    module = _load_s_auth()

    reads = []

    def fake_run(cmd, capture_output, text):  # noqa: ARG001
        reads.append(cmd)
        container, field = cmd[-1].split("/")[-2:]  # op://vault/container/field
        return type("R", (), {"returncode": 0, "stdout": f"{container}_{field}_value\n", "stderr": ""})()

    monkeypatch.setattr(module.subprocess, "run", fake_run)
    module.op_reads = reads
    return module


@pytest.fixture
def s_auth_no_config(monkeypatch, tmp_path):
    """s_auth module with both config paths pointing at non-existent files."""
    monkeypatch.setenv("AUTH_ETC_CONFIG", str(tmp_path / "missing.yml"))
    monkeypatch.setenv("XDG_CONFIG_HOME", str(tmp_path))  # no custom/secrets.yml under it
    return _load_s_auth()
