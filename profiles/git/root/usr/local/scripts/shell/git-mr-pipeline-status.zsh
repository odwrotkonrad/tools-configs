#!/usr/bin/env zsh
#>[what] 🤖🤖
#   Find the open MR created from the current branch (fallback: most recently
#   updated open MR) and print its last pipeline status as bold markdown
#   sections: MR, repo (open MR list on >1), branch sync, pipeline (url,
#   status), stages with wall time and each job (emoji, duration, link).
#   in-progress pipeline: wait until it fails or succeeds (default), poll 10s,
#   job-level progress on stderr; --no-wait reports immediately, running jobs
#   show 🕐 with time elapsed.
#   Usage: git-mr-pipeline-status [--wait|--no-wait] [--branch=<branch>]
#   Downstream: glab, jq, git.
#/[what] 🤖🤖

##[>] 🤖🤖
emulate -LR zsh
set -e
set -o pipefail

b=$'\e[1m' n=$'\e[0m'

wait_flag=1
sel_branch=
for arg { case $arg {
  --wait) wait_flag=1 ;;
  --no-wait) wait_flag=0 ;;
  --branch=*) sel_branch=${arg#*=} ;;
  *) print -ru2 -- "usage: ${0:t} [--wait|--no-wait] [--branch=<branch>]"; exit 2 ;;
} }
: ${sel_branch:=$(git rev-parse --abbrev-ref HEAD)}

mrs_json=$(glab mr list -F json)
mr_count=$(jq length <<< $mrs_json)
if (( mr_count == 0 )) { print -r -- "no open MRs"; exit 0 }

mr_iid=$(jq -r --arg cb $sel_branch \
  '. as $all | [$all[] | select(.source_branch == $cb)]
  | if length > 0 then .[0].iid else ($all | sort_by(.updated_at) | last | .iid) end' <<< $mrs_json)
mr_json=$(glab mr view $mr_iid --output json)
jq -r --arg b $b --arg n $n '"\($b)# MR: !\(.iid)\($n)", "name: \(.title)", "url: \(.web_url)"' <<< $mr_json

print -r -- $'\n'"$b## Repo$n"
glab api projects/:id | jq -r '"repo: \(.path_with_namespace)", "url: \(.web_url)"'
if (( mr_count == 1 )) {
  print -r -- "open mr count: $mr_count"
} else {
  print -r -- $'\n'"$b### ⚠️  Open MR count: $mr_count$n"
  jq -r --arg cb $sel_branch \
    'sort_by(.updated_at) | reverse
    | map(select(.source_branch == $cb)) + map(select(.source_branch != $cb))
    | to_entries[]
    | (if .key > 0 then "" else empty end),
      "name: \(.value.title)", "url: \(.value.web_url)", "update-time: \(.value.updated_at)",
      (if .value.source_branch == $cb then "current: true" else empty end)' <<< $mrs_json
}

branch=$(jq -r .source_branch <<< $mr_json)
print -r -- $'\n'"$b## Branch$n"
print -r -- $branch
git fetch -q --prune origin
if ! git rev-parse -q --verify refs/heads/$branch >/dev/null; then
  print -r -- "origin - local: ⚠️ no local branch"
  ref=origin/$branch
elif ! git rev-parse -q --verify refs/remotes/origin/$branch >/dev/null; then
  print -r -- "origin - local: ⚠️ no origin branch"
  ref=$branch
else
  read ahead behind <<< $(git rev-list --left-right --count $branch...origin/$branch)
  if (( ahead && behind )) {
    print -r -- "origin - local: ⚠️ diverged (local +$ahead, remote +$behind)"
  } elif (( ahead )) {
    print -r -- "origin - local: ⚠️ local ahead ($ahead)"
  } elif (( behind )) {
    print -r -- "origin - local: ⚠️ remote ahead ($behind)"
  } else {
    print -r -- "origin - local: ✅ synced"
  }
  ref=$branch
fi
read files adds dels <<< $(git diff --numstat origin/main...$ref | awk '{f++; a+=$1; d+=$2} END {print f+0, a+0, d+0}')
print -r -- "line changes: +$adds -$dels (~$files files)"
print -r -- "commit count: $(git rev-list --count origin/main..$ref)"

pipe_id=$(jq -r '.head_pipeline.id // empty' <<< $mr_json)
if [[ -z $pipe_id ]] { print -r -- $'\n'"$b## Pipeline$n"$'\n'"none"; exit 0 }

jq_defs='def emo: {success:"✅",failed:"❌",canceled:"🚫",skipped:"⏭️ ",manual:"⚙️ ",running:"🕐"}[.] // "⏳";
def pad2: tostring | if length < 2 then "0" + . else . end;
def dur: if . == null then " -    "
  else (round | "\(. / 60 | floor | tostring | if length < 2 then " " + . else . end)m\(. % 60 | pad2)s") end;
def ts: sub("\\.[0-9]+";"") | fromdateiso8601;
def job_dur: if .status == "running" and .started_at then now - (.started_at | ts) else .duration end;
def stage_dur: [.[] | select(.started_at)]
  | if length == 0 then null
    else ([.[] | .finished_at // (now | todate) | ts] | max) - ([.[].started_at | ts] | min) end;'

pipe_json=$(glab api projects/:id/pipelines/$pipe_id)
if (( wait_flag )) {
  typeset -A job_reported
  while [[ $(jq -r .status <<< $pipe_json) == (created|preparing|pending|waiting_for_resource|running) ]] {
    jobs_json=$(glab api "projects/:id/pipelines/$pipe_id/jobs?per_page=100")
    for line in ${(f)"$(jq -r "$jq_defs"'sort_by(.id)[]
        | select(.status | IN("success","failed","canceled","skipped"))
        | "\(.id)\t\(.status | emo) \(job_dur | dur) \(.name)"' <<< $jobs_json)"}; do
      job_id=${line%%$'\t'*}
      (( ${+job_reported[$job_id]} )) && continue
      job_reported[$job_id]=1
      print -ru2 -- "done: ${line#*$'\t'}"
    done
    running=$(jq -r "$jq_defs"'[sort_by(.id)[] | select(.status == "running")
      | "\(.name) \(job_dur | dur | gsub("^ +| +$"; ""))"] | join(", ")' <<< $jobs_json)
    print -ru2 -- "waiting: ${running:-no job running yet}"
    sleep 10
    pipe_json=$(glab api projects/:id/pipelines/$pipe_id)
  }
}

jq -r --arg b $b --arg n $n "$jq_defs"'
  "", "\($b)## Pipeline\($n)", "\(.status | emo) \(if .status == "success" then "" else "\(.status) " end)\(.duration | dur)", "url: \(.web_url)"' <<< $pipe_json
glab api "projects/:id/pipelines/$pipe_id/jobs?per_page=100" |
  jq -r --arg b $b --arg n $n "$jq_defs"'sort_by(.id) | . as $jobs
    | "", "\($b)## Stages\($n)", "",
      ((map(.stage) | reduce .[] as $s ([]; if index($s) == null then . + [$s] else . end))[] as $stage
        | ($jobs | map(select(.stage == $stage))) as $stage_jobs
        | "\($b)### \($stage) \($stage_jobs | stage_dur | dur | gsub("^ +| +$"; ""))\($n)",
          ($stage_jobs[] | "\(.status | emo) \(job_dur | dur) \(.name)\({manual:" (manual trigger)",canceled:" (canceled)"}[.status] // "")", "url: \(.web_url)", ""))'
##[<] 🤖🤖
