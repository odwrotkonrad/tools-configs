#[≟] Project's Makefile
.PHONY: docs/dirs.yml load_configuration reload_services clean_broken_links

#[≟] regenerate the repo directory tree doc
docs/dirs.yml:
	./ci/scripts/s_generate_yaml_dir_tree > $@

#[≟] install configuration onto a host
load_configuration:
	sudo /usr/local/scripts/s_load_configs

#[≟] reload running service launchagents
reload_services:
	/usr/local/scripts/s_reload_services

#[≟] remove broken symlinks left in the system by renamed/deleted repo files
clean_broken_links:
	sudo /usr/local/scripts/s_clean_broken_links
