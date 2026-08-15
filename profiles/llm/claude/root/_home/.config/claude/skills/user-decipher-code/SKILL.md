---
name: user-decipher-code
description: Make code self-descriptive, understand every symbol and comment, then fold clarifying comments into names and structure, rename, rearrange, cut comments, until reading the code is a pleasure. Use when the user wants code deciphered, made self-explanatory, comments reduced, or symbols renamed for clarity. Keywords: decipher, self-descriptive, self-documenting, rename symbols, reduce comments, clarify code, readable, /user-decipher-code.
argument-hint: "[all-repo|uncommited-changes|diff-from-main|<path>] [lang]"
arguments: [scope, lang]
allowed-tools: "Bash(${CLAUDE_SKILL_DIR}/scripts/*)"
---

# Decipher Code

## Target

Scope: `$scope` (empty → `diff-from-main`). Resolved target files:

!`${CLAUDE_SKILL_DIR}/scripts/resolve-scope.sh $scope`

Code files only: skip docs, data, lockfiles, generated files, content-unchanged renames.

## Language Principles

Lang: `$lang` (empty → none). When set, apply these design principles to every target in that language:

!`${CLAUDE_SKILL_DIR}/scripts/print-lang-principles.sh $lang`

## Procedure

1. Read the targets whole. Go over each symbol and each comment, understand the purpose of every one. Read clarifying comments as evidence: each marks a spot where the code failed to speak for itself.
2. Fold that understanding back into the code:
   - Rename. Give each symbol a name carrying what the comment had to explain: pack max info, `noun_noun_verb`, max 3 parts.
   - Use common conventional names, aggressively: industry-standard idiomatic nomenclature over invented terms (`src`/`dst`, `count`, `path`, `parse`, `render`). Hunt invented nomenclature and replace it: any term coined for this codebase that has an industry-standard equivalent gets the standard name, everywhere it appears. Minimize the vocabulary: reuse one word per concept across all symbols, never synonyms for the same thing.
   - Rearrange. Order and group code so it reads top-down as a narrative: intent first, detail below, related things adjacent.
   - Reduce comments. Once a name or structure says it, delete the comment. Keep only what code cannot express.
3. Re-read as a first-time reader. Any spot needing a comment or a pause to decode: rename or rearrange again.

Goal: reading the code is a pleasure. A reader understands each piece from its name and position alone.

## Constraints

Preserve behavior: same inputs, same outputs, same side effects.

Keep existing comment notation intact where a comment survives: label prefixes (`[where]`, `[why]`, `[what]`), `[>]`/`[<]` section markers, 🤖 marks. Add no new comments.

If tests cover a target, run them after changes.

## Bugs

If the procedure surfaces a bug, notify the user and let them decide the action. In a non-interactive session, intervene with best judgment, e.g. provide a fix, and report what you fixed and why.

## Inconsistencies

If the procedure surfaces an inconsistency (something inaccurate, contradictory, or out of sync with the rest of the repo), notify the user and let them decide the action. In a non-interactive session, intervene: resolve it with best judgment to keep the repository state coherent, and report what you resolved and why.
