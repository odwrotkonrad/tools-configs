from pathlib import Path

import pytest
from s_rt_scripts_lib import errors as err
from s_rt_scripts_test_lib.cases import cases
from s_rt_scripts_test_lib.cases import load_cases
from s_rt_scripts_test_lib.run import assert_exit
from s_rt_scripts_test_lib.run import run
from s_rt_scripts_test_lib.run import run_case
from s_rt_scripts_test_lib.test_show_usage import test_show_usage  # noqa: F401

CASES = load_cases(__file__, "cases.yml")

LANGUAGES_URL = (
    "https://raw.githubusercontent.com/github-linguist/linguist"
    "/master/lib/linguist/languages.yml"
)


@cases(CASES)
def test_case(term_script, capsys, case, tmp_path, mocker):
    run_case(term_script, capsys, case, tmp_path, mocker)


def out_map(capsys):
    """Parse `ext=opener` output lines into a dict (opener may contain spaces)."""
    lines = capsys.readouterr().out.strip().splitlines()
    return dict(line.split("=", 1) for line in lines)


def test_missing_config(term_script, mocker):
    missing = Path("/nonexistent/term-open-files-with.yml")
    mocker.patch.object(
        term_script.Config, "custom_paths", classmethod(lambda cls: [missing])
    )
    assert_exit(term_script, ["any"], err.Errors.FILE_NOT_FOUND)


def test_invalid_config(term_script, mocker, tmp_path):
    bad = tmp_path / "bad.yml"
    bad.write_text("any: [unclosed\n")
    mocker.patch.object(
        term_script.Config, "custom_paths", classmethod(lambda cls: [bad])
    )
    assert_exit(term_script, ["any"], err.Errors.CONFIG)


def test_network_failure(term_script, mocker):
    def boom(url, timeout=None):  # noqa: ARG001
        raise term_script.requests.RequestException("no host")

    mocker.patch("requests.get", side_effect=boom)
    assert_exit(term_script, ["any"], err.Errors.NETWORK)


BY_TYPE = {
    "programming": ["py"],
    "markup": ["html"],
    "data": ["json", "yml"],
    "prose": ["rst"],
}
CFG = {
    "any": [
        {"opener": "vim", "types": ["programming", "markup", "data", "prose"]}
    ],
    "vscode": [
        {"opener": "code -r", "types": ["programming", "markup", "data"]}
    ],
    "kitty": [
        {"opener": "bat", "types": ["data"]},
        {"opener": "nvim", "types": ["prose"]},
    ],
}


def sections(term_script, cfg):
    return {
        name: [term_script.OpenerRule(**rule) for rule in rules]
        for name, rules in cfg.items()
    }


def merge(term_script, cfg, terminal, by_type=BY_TYPE):
    secs = sections(term_script, cfg)
    return {
        **term_script.get_extensions_for_terminal(secs, by_type, "any"),
        **term_script.get_extensions_for_terminal(secs, by_type, terminal),
    }


@pytest.mark.parametrize(
    ("terminal", "opener"),
    [("vscode", "code -r"), ("kitty", "vim"), ("any", "vim")],
)
def test_terminal_selects_opener(term_script, terminal, opener):
    assert merge(term_script, CFG, terminal)["py"] == opener


def test_partial_override_merges_per_type(term_script):
    assert merge(term_script, CFG, "kitty") == {
        "py": "vim",
        "html": "vim",
        "json": "bat",
        "yml": "bat",
        "rst": "nvim",
    }


def test_last_opener_wins_on_collision(term_script):
    secs = sections(
        term_script,
        {
            "vscode": [
                {"opener": "code -r", "types": ["data"]},
                {"opener": "code -w", "types": ["data"]},
            ]
        },
    )
    assert (
        term_script.get_extensions_for_terminal(secs, BY_TYPE, "vscode")["json"]
        == "code -w"
    )


def test_fetches_and_caches_languages(term_script, mock_fetch, capsys):
    run(term_script, ["any"])
    aliases = out_map(capsys)
    mock_fetch.assert_called_once_with(LANGUAGES_URL, timeout=30)
    assert (term_script.cache_dir / "languages.yml").is_file()
    assert aliases.get("py") == "vim"
    assert aliases.get("yml") == "vim"
    assert aliases.get("yaml") == "vim"


def test_cached_languages_skips_fetch(term_script, mock_fetch, capsys):
    term_script.cache_dir.mkdir(parents=True, exist_ok=True)
    (term_script.cache_dir / "languages.yml").write_text(
        "Python:\n  type: programming\n  extensions: ['.py']\n"
    )
    run(term_script, ["any"])
    mock_fetch.assert_not_called()
    assert out_map(capsys)["py"] == "vim"
