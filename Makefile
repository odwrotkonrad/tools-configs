#[≟] Project's Makefile
WRAPPERS := run-sync run-repo-gen-files
COMMANDS := run-repo-tests run-host-upsert-configs run-repo-upsert-git-hooks run-host-restart-services run-host-delete-broken-links
FILES := docs/data/dirs.yml README.md
.PHONY: $(WRAPPERS) $(COMMANDS) $(FILES)

#[…] wrappers
run-sync: run-host-upsert-configs run-host-delete-broken-links run-repo-upsert-git-hooks

run-repo-gen-files: $(FILES)

#[⫶]

#[…] commands
run-host-upsert-configs:
	sudo $(CURDIR)/root-ln/usr/local/scripts/shell/s-rt-load-configs

run-host-delete-broken-links:
	sudo $(CURDIR)/root-ln/usr/local/scripts/shell/s-rt-clean-broken-links

run-repo-tests:
	/usr/local/bin/python3.14 -m pytest tests/scripts/python

run-repo-upsert-git-hooks:
	lefthook install --force

#[≟] reload running service launchagents
run-host-restart-services:
	./root-ln/usr/local/scripts/shell/s-rt-reload-services

#[⫶]

#[…] files
docs/data/dirs.yml:
	./root-ln/usr/local/scripts/shell/s-rt-generate-yaml-dir-tree > $@

README.md:
	PYTHONPATH=root-ln/usr/local/scripts/python ./root-ln/usr/local/scripts/python/s-rt-gen-markdown docs/templates/README.tmpl.md > $@

#[⫶]
