---
name: user-junior-wrote-this-code-refactor-redesign
description: Aggressively refactor and redesign the codebase as if a junior wrote it, grill every design decision, cut code amount, maximize readability, restructure for maintenance and extensibility, everything is an option. Use when the user wants a hard critical rewrite-level cleanup of test or non-test code. Keywords: junior code, aggressive refactor, redesign, grill, rewrite, restructure, cut code, shrink codebase, maintainability, extensibility, /user-junior-wrote-this-code-refactor-redesign.
argument-hint: "<test|nontest>"
arguments: [scope]
---

# Junior Wrote This: Refactor & Redesign

## Scope

Scope: `$scope`, required, one of:

- `nontest`: all non-test code. Test code is read-only context: never edit, move, delete, or rename a test file, fixture, or spec. Adjust NOTHING under test trees; if a redesign breaks tests, change the design of production code and only then report which tests block it.
- `test`: all test code (test files, fixtures, specs, harnesses). Non-test code is read-only context: never edit production code, even one line, even to "unblock" a test redesign; report blockers instead.

Any other value or empty: stop and ask for the scope.

## Stance

Assume a junior wrote every line in scope. Trust nothing:

- Grill the design: every abstraction, layer, interface, dependency, and file split must justify its existence.
- Everything is an option: merge modules, delete layers, invert dependencies, rewrite whole files, redraw package boundaries. Nothing is too dangerous.
- Optimize for two outcomes, in order: less code, more readable code.
- Redesign for easy further maintenance and extensibility: a newcomer should extend the codebase without archaeology.

## Procedure

1. Survey from high level: map the pieces in scope, how they connect, who calls what, where state lives, where duplication and dead weight sit.
2. Judge the design: list what is over-built, under-built, misplaced, duplicated, or dead. Rank by payoff.
3. Decide the target design: how the codebase should look for maintenance and extensibility, not how to minimally patch it.
4. Plan the moves from current to target: order them so the build and tests stay green between steps.
5. Execute aggressively. Prefer deleting and rewriting over decorating.
6. Re-run the survey on the result; repeat until another pass would not shrink or clarify the code.

## Instructions

Apply all of:

- Cut code amount: delete dead code, collapse needless indirection, commonize duplication, replace hand-rolled mechanisms with the standard library.
- Maximize readability: names carry the meaning, flat over nested, one obvious way per task, split complex-reading code into steps.
- Idiomatic, modern syntax of the target language.
- Restructure files and packages so related code lives together and each piece has one reason to change.
- Keep public behavior identical unless the user approved a behavior change: same inputs, same outputs, same side effects.

## Constraints

- Hard scope wall: `nontest` touches zero test code, `test` touches zero non-test code. No exceptions.
- Keep existing comment notation intact: label prefixes (`[where]`, `[why]`, `[what]`), `[>]`/`[<]` section markers, 🤖 marks. Add no new comments.
- Verify continuously: build, lint, and full test suite after every plan step, green before the next step.

## Bugs

Surfaced a bug: tell the user, let them decide. Non-interactive session: use best judgment, fix it, report what and why.

## Inconsistencies

Surfaced an inconsistency (inaccurate, contradictory, out of sync with the repo): tell the user, let them decide. Non-interactive session: resolve it with best judgment, keep the repo coherent, report what and why.
