---
name: user-humanize-prose
description: Rewrite AI-written prose shorter, terser, more abrupt, human, idiomatic. Use when the user wants prose tightened, humanized, or de-AI-flavored, in chat replies, docs, commit text, MR descriptions, README sections, code comments. Keywords: humanize, tersify, shorten, tighten, abrupt, de-AI, idiomatic, natural, /user-humanize-prose.
argument-hint: "[session|selection|uncommited-changes|diff-from-main|all-repo-prose]"
arguments: [scope]
allowed-tools: "Bash(${CLAUDE_SKILL_DIR}/scripts/*)"
---

# Humanize Prose

## Target

Scope: `$scope` (empty → `diff-from-main`). Resolved target files:

!`${CLAUDE_SKILL_DIR}/scripts/resolve-scope.sh $scope`

For `session` scope: rewrite prose you wrote this session (the last response, or the file the user points at). For `selection` scope: rewrite the selected text, the IDE selection in context, or the text pasted with the command. If it comes from a file, edit that file in place at the selection only. Otherwise: rewrite the prose files from the list above (markdown, docs) and the comments in code files, skip content-unchanged renames.

In code files, rewrite comment prose only: leave code untouched. Apply the same rules to every comment kind (inline, block, doc comments, config annotations). Delete comments that restate the code or add nothing. Preserve comment notation: label prefixes (`[where]`, `[why]`, `[what]`), `[>]`/`[<]` section markers, 🤖 marks.

Rewrite each target in place, same medium.

## Instructions

Rewrite aggressively. Never preserve wording, sentence order, or structure out of caution: if a sentence can be tighter, rewrite it. "Already decent" is not a reason to skip. Apply all of:

- Shorten. Cut filler, hedges, preamble, postamble, restated context. Keep only what changes what the reader does or knows.
- Deduplicate. Remove redundant prose: points repeated in other words. Say it once, in the best spot.
- Cut the obvious. Remove information the reader already knows or can infer: from context, the surrounding text, or competence in the field.
- Tersify. Fewest words per sentence. Drop qualifiers ("quite", "essentially", "it's worth noting"). One idea per sentence.
- Abrupt. Start with the point. No warm-ups, no transitions, no recaps.
- Humanize. Kill AI tells: "delve", "leverage", "robust", "seamless", "comprehensive", "it's important to", bullet-mania, mirrored triads, em-dash chains, over-parallel structure. Vary sentence length. Write like a practitioner in a hurry, not a brochure.
- Idiomatic. Use the field's standard terms: what a working engineer, ops person, or writer would actually say. Common name over invented paraphrase.

## Constraints

Preserve facts, code, commands, paths, numbers, meaning. Never trade correctness for brevity.

Output only the rewritten prose. No commentary unless asked.

## Inconsistencies

Surfaced an inconsistency (inaccurate, contradictory, out of sync with the repo): tell the user, let them decide. Non-interactive session: resolve it with best judgment, keep the repo coherent, report what and why.
