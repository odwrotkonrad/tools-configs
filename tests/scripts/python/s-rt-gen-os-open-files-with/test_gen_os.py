from pathlib import Path

import pytest
import yaml

HERE = Path(__file__).parent
OUTPUT_CASES = yaml.safe_load((HERE / "test_main_cases.yml").read_text())
ERROR_CASES = yaml.safe_load((HERE / "test_error_cases.yml").read_text())
HELP_CASES = yaml.safe_load((HERE / "test_help_cases.yml").read_text())


def run(gen_os, argv):
    gen_os.sys.argv = ["s-rt-gen-os-open-files-with", *argv]
    gen_os.main()


@pytest.mark.parametrize("case", OUTPUT_CASES, ids=lambda c: c["name"])
def test_output(gen_os, case):
    assert list(gen_os.handler_lines(case["config"])) == case["out"]


@pytest.mark.parametrize("case", HELP_CASES, ids=lambda c: c["name"])
def test_help_output(gen_os, capsys, case):
    with pytest.raises(SystemExit) as exc:
        run(gen_os, case["args"])
    assert exc.value.code == 0
    assert case["contains"] in capsys.readouterr().out


@pytest.mark.parametrize("case", ERROR_CASES, ids=lambda c: c["name"])
def test_exit_code(gen_os, tmp_path, case):
    args = case["args"]
    if "bad_config" in case:
        bad = tmp_path / "bad.yml"
        bad.write_text(case["bad_config"])
        args = [str(bad)]
    with pytest.raises(SystemExit) as exc:
        run(gen_os, args)
    assert exc.value.code == case["exit"]
