import os
from pathlib import Path

import pygit2
import pytest
from s_rt_scripts_test_lib.cases import cases
from s_rt_scripts_test_lib.cases import load_cases
from s_rt_scripts_test_lib.run import match_line
from s_rt_scripts_test_lib.run import run
from s_rt_scripts_test_lib.test_show_usage import test_show_usage  # noqa: F401

# […] 🤖🤖🤖
FIXTURE = Path(__file__).parent / "fixture"
CASES = load_cases(__file__, "cases.yml")
TRACKED = (".hidden/note.md", "docs/data/x.yml", "src/lib/a.py", "README.md")


def make_repo(tmp_path):
    pygit2.init_repository(str(tmp_path))
    repo = pygit2.Repository(str(tmp_path))
    for rel in TRACKED:
        path = tmp_path / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("x\n")
        repo.index.add(rel)
    repo.index.write()
    return repo


def assert_exit(tree_script, args, case, capsys):
    with pytest.raises(SystemExit) as exc:
        run(tree_script, args)
    assert exc.value.code == case["exit"]
    if "stderr" in case:
        assert match_line(capsys.readouterr().err.strip(), case["stderr"])


@cases(CASES)
def test_case(tree_script, capsys, case, tmp_path):
    if "input" in case:
        assert_exit(tree_script, case["input"], case, capsys)
        return

    make_repo(tmp_path)
    expected = (FIXTURE / "expected.tree").read_text()
    match case["case"]:
        case "generate":
            out, err = tree_script.generate(str(tmp_path))
            assert err is None
            assert out == expected
        case "check_match":
            good = tmp_path / "good.tree"
            good.write_text(expected)
            out, err = tree_script.check(str(good), str(tmp_path))
            assert (out, err) == ("", None)
        case "check_differs":
            stale = tmp_path / "stale.tree"
            stale.write_text("stale/\n")
            cwd = os.getcwd()
            os.chdir(tmp_path)
            try:
                assert_exit(tree_script, ["--check", str(stale)], case, capsys)
            finally:
                os.chdir(cwd)
        case "check_missing":
            assert_exit(
                tree_script,
                ["--check", str(tmp_path / "nope.tree")],
                case,
                capsys,
            )


# [⫶] 🤖🤖🤖
