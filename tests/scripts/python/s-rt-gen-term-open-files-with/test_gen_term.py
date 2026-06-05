from pathlib import Path

import pytest
import yaml

HERE = Path(__file__).parent
OUTPUT_CASES = yaml.safe_load((HERE / "test_main_cases.yml").read_text())
ERROR_CASES = yaml.safe_load((HERE / "test_error_cases.yml").read_text())


def run(gen_term, argv):
    gen_term.sys.argv = ["s-rt-gen-term-open-files-with", *argv]
    gen_term.main()


def out_map(capsys):
    """Parse `ext=opener` output lines into a dict (opener may contain spaces)."""
    lines = capsys.readouterr().out.strip().splitlines()
    return dict(line.split("=", 1) for line in lines)


@pytest.mark.parametrize("case", OUTPUT_CASES, ids=lambda c: c["name"])
def test_output(gen_term, capsys, case):
    run(gen_term, case["args"])
    assert capsys.readouterr().out.strip().splitlines() == case["out"]


@pytest.mark.parametrize("case", ERROR_CASES, ids=lambda c: c["name"])
def test_exit_code(gen_term, monkeypatch, tmp_path, case):
    if "config" in case:
        monkeypatch.setattr(gen_term, "DEFAULT_CONFIG", case["config"])
    if "bad_config" in case:
        bad = tmp_path / "bad.yml"
        bad.write_text(case["bad_config"])
        monkeypatch.setattr(gen_term, "DEFAULT_CONFIG", str(bad))
    if case.get("fetch") == "fail":
        def failed_get(url, timeout=None):  # noqa: ARG001
            raise gen_term.requests.RequestException("no host")

        monkeypatch.setattr(gen_term.requests, "get", failed_get)
    with pytest.raises(SystemExit) as exc:
        run(gen_term, case["args"])
    assert exc.value.code == case["exit"]


BY_TYPE = {"programming": ["py"], "markup": ["html"], "data": ["json", "yml"], "prose": ["rst"]}
CFG = {
    "any": [{"opener": "vim", "types": ["programming", "markup", "data", "prose"]}],
    "vscode": [{"opener": "code -r", "types": ["programming", "markup", "data"]}],
    "kitty": [{"opener": "bat", "types": ["data"]}, {"opener": "nvim", "types": ["prose"]}],
}


def merge(gen_term, cfg, terminal, by_type=BY_TYPE):
    return {
        **gen_term.get_extensions_for_terminal(cfg, by_type, "any"),
        **gen_term.get_extensions_for_terminal(cfg, by_type, terminal),
    }


@pytest.mark.parametrize(("terminal", "opener"), [("vscode", "code -r"), ("kitty", "vim"), ("any", "vim")])
def test_terminal_selects_opener(gen_term, terminal, opener):
    assert merge(gen_term, CFG, terminal)["py"] == opener


def test_partial_override_merges_per_type(gen_term):
    assert merge(gen_term, CFG, "kitty") == {
        "py": "vim", "html": "vim", "json": "bat", "yml": "bat", "rst": "nvim",
    }


def test_last_opener_wins_on_collision(gen_term):
    cfg = {"vscode": [{"opener": "code -r", "types": ["data"]}, {"opener": "code -w", "types": ["data"]}]}
    assert gen_term.get_extensions_for_terminal(cfg, BY_TYPE, "vscode")["json"] == "code -w"


def test_fetches_and_caches_languages(gen_term, capsys):
    run(gen_term, ["any"])
    aliases = out_map(capsys)
    assert gen_term.fetches == [gen_term.LANGUAGES_URL]
    assert (gen_term.cache_dir / "languages.yml").is_file()
    assert aliases.get("py") == "vim"
    assert aliases.get("yml") == "vim"
    assert aliases.get("yaml") == "vim"


def test_cached_languages_skips_fetch(gen_term, capsys):
    gen_term.cache_dir.mkdir(parents=True, exist_ok=True)
    (gen_term.cache_dir / "languages.yml").write_text(
        "Python:\n  type: programming\n  extensions: ['.py']\n"
    )
    run(gen_term, ["any"])
    assert gen_term.fetches == []
    assert out_map(capsys)["py"] == "vim"
