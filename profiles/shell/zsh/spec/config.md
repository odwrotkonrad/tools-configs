<!--[>] 🤖🤖 -->
Feature: zsh config

Scenario: PS1 renders $HOME as ~, abbreviates non-tail segments to their first character, keeps the last two segments full
  Status: implemented
  Given $PWD is under $HOME
  And the directory stack holds paths under $HOME
  When I press TAB
  Then the $PWD group header is the glob-depth notation *
  And PS1 renders $PWD with $HOME as ~, non-tail segments abbreviated to their first character, the last two segments full
  And each Stack entry renders its path with $HOME as ~

Scenario: PS1 renders ~ for $HOME only, never abbreviates a named dir to ~name
  Status: implemented
  Given a named dir (hash -d) points at a directory under $HOME
  And $PWD is inside that named dir's target
  When PS1 renders
  Then $PWD shows ~ only for the $HOME segment
  And the named dir is not abbreviated to its ~name form
  And non-tail segments abbreviate to their first character
  And the last two segments stay full
<!--[<] 🤖🤖 -->
