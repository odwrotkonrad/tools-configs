from pathlib import Path

from fixture.src.cases import cases
from fixture.src.cases import load_cases
from fixture.src.run import assert_exit
from fixture.src.run import run
from fixture.src.test_help import test_help  # noqa: F401

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
        assert_exit(markdown_script, args, code)
        return
    run(markdown_script, args)
    assert capsys.readouterr().out == (FIXTURE / case["stdout"]).read_text()
