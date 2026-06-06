#[≟] Project's Makefile
.PHONY: docs readme load_configuration install_git_hooks reload_services clean_broken_links test once on_change

#[≟] run the test suite under the same interpreter as the script shebangs
test:
	/usr/local/bin/python3.14 -m pytest tests/scripts/python

#[≟] regenerate the repo directory tree doc and the README
docs: readme
	./root-ln/usr/local/scripts/shell/s-rt-generate-yaml-dir-tree > docs/dirs.yml

#[≟] render README.md from its markdown template
readme:
	PYTHONPATH=root-ln/usr/local/scripts/python ./root-ln/usr/local/scripts/python/s-rt-gen-markdown docs/templates/README.tmpl.md > README.md

#[≟] install configuration onto a host
load_configuration:
	sudo $(CURDIR)/root-ln/usr/local/scripts/shell/s-rt-load-configs

#[≟] install git hooks from merged lefthook config (user scope ~/.config/lefthook + repo scope ./lefthook.yml)
install_git_hooks:
	lefthook install --force

#[≟] reload running service launchagents
reload_services:
	./root-ln/usr/local/scripts/shell/s-rt-reload-services

#[≟] remove broken symlinks left in the system by renamed/deleted repo files
clean_broken_links:
	sudo $(CURDIR)/root-ln/usr/local/scripts/shell/s-rt-clean-broken-links

#[…] wrappers

#[≟] one-time host setup: load configuration and install git hooks
once: load_configuration install_git_hooks

#[≟] re-sync configs into the system and prune symlinks left dangling by renames
on_change: load_configuration clean_broken_links
#[⫶]
