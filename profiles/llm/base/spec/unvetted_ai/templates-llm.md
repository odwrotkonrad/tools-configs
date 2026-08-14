<!--[>] 🤖🤖 -->
Feature: llm-git-mr-suggest.zsh

Scenario: big MR area splits into feature subsections
  Status: implemented
  When a `### <scope>` area exceeds ~6 bullets
  Then it splits into `#### <feature>` subsections
  And a flat base description regroups, bullet wording kept
  And small areas stay flat

Feature: llm-git-commit-suggest.zsh

Scenario: big commit area subgroups by feature
  Status: implemented
  When an `area:` group carries several features
  Then each feature gets a `<feature>:` subline
<!--[<] 🤖🤖 -->
