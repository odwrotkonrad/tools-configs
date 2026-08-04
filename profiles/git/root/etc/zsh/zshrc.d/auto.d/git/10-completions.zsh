##[>] 🤖🤖
fn-git-headrefs-recency() { "$@" --sort=-committerdate }
zstyle ':completion:*:(headrefs|branchrefs|remote-branch-refs(|-noprefix))' command '- fn-git-headrefs-recency'
zstyle ':completion:*:(heads-(local|remote)|branch-names|remote-branch-names(|-noprefix))' sort false

__git_heads_local() {
  local f gitdir
  declare -a heads

  gitdir=$(_call_program gitdir git rev-parse --git-dir 2>/dev/null)
  if __git_command_successful $pipestatus; then
    for f in HEAD FETCH_HEAD ORIG_HEAD MERGE_HEAD; do
      [[ -f $gitdir/$f ]] && heads+=$f
    done
  fi
  heads+=(${(f)"$(_call_program headrefs git for-each-ref --format='"%(refname:short)"' refs/heads refs/bisect refs/stash 2>/dev/null)"})
  __git_command_successful $pipestatus || return 1

  __git_describe_commit heads heads-local "local head" "$@"
}
##[<] 🤖🤖
