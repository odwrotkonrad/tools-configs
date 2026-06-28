import inspect
import re

import pytest
import yaml


##[>] 🤖🤖
def run(module, argv):
    module.sys.argv = [module.__name__, *argv]
    if inspect.signature(module.main).parameters:
        input, error = module.Input.validate_input(argv)
        out = None
        if not error:
            out, error = module.main(input)
        if error:
            errors = getattr(module, "Errors", module.lib_err.Errors)
            print(errors.message(error), file=module.sys.stderr)
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


def stage_config(script, mocker, tmp_path, case):
    """Point script.custom_paths at a tmp file holding the case config."""
    custom = tmp_path / "custom"
    custom.mkdir(parents=True, exist_ok=True)
    cfg = custom / script.Config.NAME
    cfg.write_text(
        case["config_raw"]
        if "config_raw" in case
        else yaml.safe_dump(case["config"])
    )
    mocker.patch.object(
        script.Config, "custom_paths", classmethod(lambda cls: [cfg])
    )


def run_case(script, capsys, case, tmp_path, mocker):
    if "config" in case or "config_raw" in case:
        stage_config(script, mocker, tmp_path, case)
    elif case.get("no_config"):
        missing = tmp_path / "custom" / script.Config.NAME
        mocker.patch.object(
            script.Config, "custom_paths", classmethod(lambda cls: [missing])
        )

    args = list(case.get("args", []))
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


##[<] 🤖🤖
