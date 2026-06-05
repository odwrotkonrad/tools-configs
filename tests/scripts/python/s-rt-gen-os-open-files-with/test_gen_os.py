from fixture.src.cases import cases
from fixture.src.cases import load_cases
from fixture.src.run import run_case
from fixture.src.test_help import test_help  # noqa: F401

CASES = load_cases(__file__, "cases.yml")


@cases(CASES)
def test_case(os_script, capsys, case, tmp_path):
    run_case(os_script, capsys, case, tmp_path)
