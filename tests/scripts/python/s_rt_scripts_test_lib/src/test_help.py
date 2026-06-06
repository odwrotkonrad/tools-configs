import pytest

from s_rt_scripts_test_lib.cases import cases
from s_rt_scripts_test_lib.cases import load_cases
from s_rt_scripts_test_lib.run import run

HELP = load_cases(__file__, "../cases.yml")


@cases(HELP)
def test_help(script, capsys, case):
    with pytest.raises(SystemExit) as exc:
        run(script, case["args"])
    assert exc.value.code == case["exit"]
    assert capsys.readouterr().out.strip() == script.__doc__.strip()
