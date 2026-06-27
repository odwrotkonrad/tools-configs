from s_root_scripts_test_lib.cases import cases
from s_root_scripts_test_lib.cases import load_cases
from s_root_scripts_test_lib.run import run_case
from s_root_scripts_test_lib.test_show_usage import test_show_usage  # noqa: F401

CASES = load_cases(__file__, "cases.yml")


@cases(CASES)
def test_case(term_script, capsys, case, tmp_path, mocker):
    run_case(term_script, capsys, case, tmp_path, mocker)
