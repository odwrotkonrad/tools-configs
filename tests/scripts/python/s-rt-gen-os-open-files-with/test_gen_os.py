from s_rt_scripts_test_lib.cases import cases
from s_rt_scripts_test_lib.cases import load_cases
from s_rt_scripts_test_lib.run import run_case
from s_rt_scripts_test_lib.test_help import test_help  # noqa: F401

CASES = load_cases(__file__, "cases.yml")


@cases(CASES)
def test_case(os_script, capsys, case, tmp_path):
    run_case(os_script, capsys, case, tmp_path)
