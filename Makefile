#[≟] Project's Makefile
.PHONY: docs/dirs.yml load_configuration install_git_hooks reload_services clean_broken_links test

#[≟] run the test suite under the same interpreter as the script shebangs
test:
	/usr/local/bin/python3.14 -m pytest tests/

#[≟] regenerate the repo directory tree doc
docs/dirs.yml:
	./ci/scripts/s_generate_yaml_dir_tree > $@

#[≟] install configuration onto a host
load_configuration:
	sudo /usr/local/scripts/s_load_configs

#[≟] install git hooks from merged lefthook config (user scope ~/.config/lefthook + repo scope ./lefthook.yml)
install_git_hooks:
	lefthook install --force

#[≟] reload running service launchagents
reload_services:
	/usr/local/scripts/s_reload_services

#[≟] remove broken symlinks left in the system by renamed/deleted repo files
clean_broken_links:
	sudo /usr/local/scripts/s_clean_broken_links
