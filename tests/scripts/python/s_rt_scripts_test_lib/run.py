import inspect
import re

import pytest
import yaml


def run(module, argv):
    module.sys.argv = [module.__name__, *argv]
    if inspect.signature(module.main).parameters:
        out, error = module.main(
            *module.lib_ipt.validate_input(module.Parameters, argv)
        )
        if error:
            print(module.Errors.message(error), file=module.sys.stderr)
            module.sys.exit(error.code)
        else:
            print(out, end="")
    else:
        module.main()


def assert_exit(module, argv, code):
    with pytest.raises(SystemExit) as exc:
        run(module, argv)
    assert exc.value.code == code


def match_line(actual, expected):
    if (
        len(expected) >= 2
        and expected.startswith("/")
        and expected.endswith("/")
    ):
        return re.fullmatch(expected[1:-1], actual) is not None
    return actual == expected


def assert_output(actual_lines, expected_lines):
    assert len(actual_lines) == len(expected_lines), (
        actual_lines,
        expected_lines,
    )
    for actual, expected in zip(actual_lines, expected_lines):
        assert match_line(actual, expected), (actual, expected)


def run_case(script, capsys, case, tmp_path):
    args = list(case.get("args", []))
    if "config" in case or "config_raw" in case:
        cfg = tmp_path / "config.yml"
        cfg.write_text(
            case["config_raw"]
            if "config_raw" in case
            else yaml.safe_dump(case["config"])
        )
        args = [str(cfg), *args]

    code = case.get("exit", 0)
    if code == 0:
        run(script, args)
        assert_output(
            capsys.readouterr().out.strip().splitlines(), case.get("output", [])
        )
    else:
        with pytest.raises(SystemExit) as exc:
            run(script, args)
        assert exc.value.code == code
