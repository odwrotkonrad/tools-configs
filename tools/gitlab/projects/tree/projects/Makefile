##[>] 🤖🤖
#[what] Workspace parent Makefile: delegate child-repo targets from any cloned parent dir
#[where] che-linked onto $HOME/projects, $HOME/projects/gitlab, $HOME/projects/gitlab/konradodwrot
#[why] run e.g. `make init-note` or `make notes-render-templates` from a parent dir instead of `make -C konradodwrot/notes <target>`
SHELL := zsh
.SHELLFLAGS := -c

#[what] cloned repo paths (workspace-root-relative), mirroring the $GITLAB_GROUPS clone
#   (konradodwrot:konradodwrot;restricted:restricted). A <name>-<target> passthrough uses
#   the path's last segment as <name> (all basenames unique here).
REPOS := \
  konradodwrot/configs \
  konradodwrot/conventions \
  konradodwrot/go-modules \
  konradodwrot/notes \
  konradodwrot/resume-md-pdf \
  konradodwrot/workspace \
  konradodwrot/infra/oci-images \
  restricted/infra \
  restricted/sandbox

#[what] workspace root: the dir holding konradodwrot/notes, found near $(CURDIR)
#[why] the same file is linked above (~/projects), at (~/projects/gitlab), and below
#   (~/projects/gitlab/konradodwrot) the workspace root; probe $(CURDIR), then its
#   descendants down to the linked depths, then ancestors, first hit wins
ROOT := $(shell c=$(CURDIR); for d in $$c $$c/gitlab $$c/gitlab/konradodwrot $${c:h} $${c:h:h}; do [[ -d $$d/konradodwrot/notes ]] && { print -r -- $$d; break }; done)

#[what] resolve a repo name (basename) to its absolute cloned dir under the workspace root
repo_dir = $(ROOT)/$(filter %/$(1) $(1),$(REPOS))

##[>] Passthrough [genai-include]
#[what] <repo>-<target> delegates <target> to that child repo, e.g. `make notes-render-templates`
$(foreach p,$(REPOS),$(eval $(notdir $(p))-%: ; @$$(MAKE) -C $$(call repo_dir,$(notdir $(p))) $$*))
##[<] Passthrough

##[>] Notes [genai-include]
#[what] hot alias: initialize today's dated note in konradodwrot/notes (= notes-init-note)
init-note:
	@$(MAKE) -C $(call repo_dir,notes) init-note
##[<] Notes

.PHONY: init-note
##[<] 🤖🤖
