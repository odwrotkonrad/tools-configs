#[≟] Project's Makefile
WRAPPERS := run-sync run-repo-gen-files run-host-setup
COMMANDS := run-repo-tests run-repo-typecheck run-host-upsert-configs run-repo-upsert-git-hooks run-host-restart-services run-host-delete-broken-links run-host-install-all run-host-mk-dirs
FILES := docs/data/dirs.gen.md README.md
SCRIPTS := root-ln/usr/local/scripts
MYPY := mypy --config-file root-ln/Users/ko/.config/mypy/config
.PHONY: $(WRAPPERS) $(COMMANDS) $(FILES)

#[…] wrappers
run-sync: .env run-host-upsert-configs run-host-delete-broken-links run-repo-upsert-git-hooks
run-host-setup: run-host-mk-dirs run-host-upsert-configs run-host-install-all

run-repo-gen-files: $(FILES)
#[⫶] wrappers

#[…] commands
run-host-upsert-configs:
	sudo $(CURDIR)/$(SCRIPTS)/shell/s-rt-load-configs

run-host-delete-broken-links:
	sudo $(CURDIR)/$(SCRIPTS)/shell/s-rt-clean-broken-links

run-host-mk-dirs:
	sudo $(CURDIR)/$(SCRIPTS)/installs/s-rt-mk-dirs

run-repo-tests:
	pytest tests/scripts/python

run-repo-typecheck:
	$(MYPY) --scripts-are-modules $(SCRIPTS)/python/s-rt-*
	$(MYPY) $(SCRIPTS)/python/s_rt_scripts_lib

run-repo-upsert-git-hooks:
	lefthook install --force

run-host-install-all:
	./$(SCRIPTS)/installs/s-rt-install-all

#[≟] reload running service launchagents
run-host-restart-services:
	./$(SCRIPTS)/shell/s-rt-reload-services

#[⫶] commands

#[…] files
.env: .env.example
	cp $< $@

docs/data/dirs.gen.md:
	./$(SCRIPTS)/python/s-rt-generate-tree > $@

README.md:
	./$(SCRIPTS)/python/s-rt-gen-markdown docs/templates/README.tmpl.md > $@
#[⫶] files
