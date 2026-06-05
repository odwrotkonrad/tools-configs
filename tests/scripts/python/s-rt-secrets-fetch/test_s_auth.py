from _harness.lib.cases import cases, load_cases
from _harness.lib.run import assert_exit, run_case
from _harness.lib.test_help import test_help  # noqa: F401
from lib.errors import ERR_CONFIG, ERR_CONFIG_NOT_FOUND

CASES = load_cases(__file__, "cases.yml")


def failed_op(cmd, capture_output, text):  # noqa: ARG001
    return type("R", (), {"returncode": 1, "stdout": "", "stderr": "vault locked"})()


@cases(CASES)
def test_case(secrets_script, capsys, case, tmp_path):
    run_case(secrets_script, capsys, case, tmp_path)


def test_missing_config(secrets_script_no_config):
    assert_exit(secrets_script_no_config, ["bar"], ERR_CONFIG_NOT_FOUND)


def test_invalid_config(secrets_script_bad_config):
    assert_exit(secrets_script_bad_config, ["bar"], ERR_CONFIG)


def test_op_failure(secrets_script, mocker):
    mocker.patch("subprocess.run", side_effect=failed_op)
    assert_exit(secrets_script, ["bar"], secrets_script.ERR_OP)
