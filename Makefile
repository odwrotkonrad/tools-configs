.PHONY: docs/dirs.yml

docs/dirs.yml:
	zsh ci/scripts/s_generate_yaml_dir_tree > $@
