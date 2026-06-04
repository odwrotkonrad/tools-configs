from pathlib import Path

import pytest
import yaml

HERE = Path(__file__).parent
OUTPUT_CASES = yaml.safe_load((HERE / "test_main_cases.yml").read_text())
ERROR_CASES = yaml.safe_load((HERE / "test_error_cases.yml").read_text())


def run(s_auth, argv):
    s_auth.sys.argv = ["s_auth", *argv]
    s_auth.main()


@pytest.mark.parametrize("case", OUTPUT_CASES, ids=lambda c: c["name"])
def test_output(s_auth, capsys, case):
    run(s_auth, case["args"])
    assert capsys.readouterr().out.strip().splitlines() == case["out"]


@pytest.mark.parametrize("case", ERROR_CASES, ids=lambda c: c["name"])
def test_exit_code(s_auth, case):
    with pytest.raises(SystemExit) as exc:
        run(s_auth, case["args"])
    assert exc.value.code == case["exit"]


def test_no_args_prints_usage(s_auth, capsys):
    with pytest.raises(SystemExit):
        run(s_auth, [])
    assert "usage: s_auth <service>" in capsys.readouterr().err


@pytest.mark.parametrize("flag", ["-h", "--help"])
def test_help_prints_doc_and_exits_zero(s_auth, capsys, flag):
    with pytest.raises(SystemExit) as exc:
        run(s_auth, [flag])
    assert exc.value.code == 0
    out = capsys.readouterr().out
    assert out.strip() == s_auth.__doc__.strip()


def test_op_failure_exits(s_auth, monkeypatch):
    def boom(cmd, capture_output, text):  # noqa: ARG001
        return type("R", (), {"returncode": 1, "stdout": "", "stderr": "vault locked"})()

    monkeypatch.setattr(s_auth.subprocess, "run", boom)
    with pytest.raises(SystemExit) as exc:
        run(s_auth, ["bar"])
    assert exc.value.code == 1


def test_no_config_file_exits(s_auth_no_config):
    with pytest.raises(SystemExit) as exc:
        run(s_auth_no_config, ["bar"])
    assert exc.value.code == s_auth_no_config.EX_NO_CONFIG
