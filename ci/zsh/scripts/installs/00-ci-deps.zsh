#!/bin/zsh
#[what] ci build deps bootstrap: che installed/upgraded via the pages-hosted install.sh (os/arch resolved there), MR pipelines preferring an open go-modules MR's prerelease over the newest published release, then go via che packages

emulate -LR zsh
setopt errexit

##[>] 🤖🤖
GO_MODULES_API='https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules'
CURL=(curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors)

che_version_latest=$(
  $CURL "${GO_MODULES_API}/packages?package_name=che&package_type=generic&per_page=100" |
    tr ',' '\n' | sed -n 's|.*"version":"\([0-9][0-9.]*\)".*|\1|p' |
    sort -t. -k1,1n -k2,2n -k3,3n | tail -1
)
[[ -n $che_version_latest ]] || { print -u2 'ci-deps: cannot resolve latest che version'; exit 1 }

#[what] newest prerelease whose MR is still open, empty when none resolves
#[why] every lookup is best-effort: a prerelease is a convenience, never a reason to redden a
#   pipeline that is not about che, so any failure falls through to the published release
fn_che_version_prerelease() {
  local packages iid version
  #[why] a real array, not the raw scalar: (Ie) on a scalar matches substrings, so open MR !420 would
  #   wrongly claim !42's prerelease
  local -a open_iids
  open_iids=(${(f)"$($CURL "${GO_MODULES_API}/merge_requests?state=opened&per_page=100" 2> /dev/null |
    sed -n 's|.*"iid":\([0-9]*\).*|\1|p')"}) || return 1
  (( ${#open_iids} )) || return 1

  #[why] created_at desc: the first match walking down is the newest published prerelease
  packages=$($CURL "${GO_MODULES_API}/packages?package_name=che&order_by=created_at&sort=desc&per_page=100" 2> /dev/null |
    tr ',' '\n' | sed -n 's|.*"version":"\(0\.0\.0-mr[0-9]*\)".*|\1|p') || return 1

  for version in ${(f)packages}; do
    iid=${version#0.0.0-mr}
    if (( ${open_iids[(Ie)$iid]} )) {
      print -r -- "$version"
      return 0
    }
  done
  return 1
}

che_version_wanted=$che_version_latest
if [[ $CI_PIPELINE_SOURCE == merge_request_event ]] {
  if che_version_prerelease=$(fn_che_version_prerelease) {
    che_version_wanted=$che_version_prerelease
    print "ci-deps: using che prerelease ${che_version_wanted} (go-modules MR !${che_version_wanted#0.0.0-mr})"
  } else {
    print "ci-deps: no open-MR che prerelease, using released ${che_version_latest}"
  }
}

che_version_installed=''
if { (( ${+commands[che]} )) && che packages --help &> /dev/null } {
  che_version_installed=${${(z)"$(che --version)"}[-1]}
}

fn_che_install() {
  $CURL https://konradodwrot.gitlab.io/go-modules/install.sh | CHE_VERSION=$1 sh
}

#[why] a dev build is a local `make install` from the go-modules checkout, deliberately ahead of any
#   tag: overwriting it with the released binary undoes the developer's build mid-work
if [[ $che_version_installed == dev ]] {
  print 'ci-deps: che is a local dev build, keeping it'
} elif [[ $che_version_installed != $che_version_wanted ]] {
  print "ci-deps: installing che ${che_version_wanted} (had: ${che_version_installed:-none})"
  #[why] a prerelease covers linux/amd64 and darwin/arm64 only, and its package can expire or be
  #   purged: fail over to the released tag instead of taking the pipeline down with a 404
  if { ! fn_che_install $che_version_wanted } {
    [[ $che_version_wanted != $che_version_latest ]] ||
      { print -u2 "ci-deps: cannot install che ${che_version_latest}"; exit 1 }
    print -u2 "ci-deps: che ${che_version_wanted} install failed, falling back to released ${che_version_latest}"
    fn_che_install $che_version_latest
  }
}
unset CHE_PROFILE
che packages install go
##[<] 🤖🤖
