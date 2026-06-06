from s_rt_scripts_test_lib.cases import cases
from s_rt_scripts_test_lib.cases import load_cases
from s_rt_scripts_test_lib.run import run

HELP = load_cases(__file__, "cases.yml")


@cases(HELP)
def test_help(script, capsys, case):
    try:
        run(script, case["args"])
    except SystemExit as exc:
        assert exc.code == case["exit"]
    else:
        assert case["exit"] == 0
    assert capsys.readouterr().out.strip() == script.__doc__.strip()
