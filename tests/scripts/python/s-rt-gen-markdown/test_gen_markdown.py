from pathlib import Path

import pytest
from s_rt_scripts_test_lib.cases import cases
from s_rt_scripts_test_lib.cases import load_cases
from s_rt_scripts_test_lib.run import match_line
from s_rt_scripts_test_lib.run import run
from s_rt_scripts_test_lib.test_show_usage import test_show_usage  # noqa: F401

FIXTURE = Path(__file__).parent / "fixture"
CASES = load_cases(__file__, "cases.yml")


def stage_fixtures(tmp_path):
    for src in FIXTURE.iterdir():
        if src.is_file():
            (tmp_path / src.name).write_text(src.read_text())


def build_args(case_input, tmp_path):
    if isinstance(case_input, list):
        return case_input
    stage_fixtures(tmp_path)
    return [str(tmp_path / case_input)]


@cases(CASES)
def test_case(markdown_script, capsys, case, tmp_path):
    args = build_args(case["input"], tmp_path)
    code = case["exit"]
    if code:
        with pytest.raises(SystemExit) as exc:
            run(markdown_script, args)
        assert exc.value.code == code
        if "stderr" in case:
            assert match_line(capsys.readouterr().err.strip(), case["stderr"])
        return
    run(markdown_script, args)
    assert capsys.readouterr().out == (FIXTURE / case["stdout"]).read_text()
