from _harness.lib.cases import cases, load_cases
from _harness.lib.run import run_case
from _harness.lib.test_help import test_help  # noqa: F401

CASES = load_cases(__file__, "cases.yml")


@cases(CASES)
def test_case(os_script, capsys, case, tmp_path):
    run_case(os_script, capsys, case, tmp_path)
