Feature: zsh config

Scenario: PS1 shows the abbreviated cwd and stack paths render home-aware
  Given the current directory is under $HOME
  And the directory stack holds paths under $HOME
  When I press TAB
  Then the PWD group heading is the glob-depth notation *
  And PS1 shows the cwd abbreviated home-aware, keeping the last two segments full, collapsing earlier segments to their first letter, and showing $HOME as ~
  And each Stack entry displays a ~-prefixed path for $HOME

Scenario: PS1 abbreviates HOME only, never named dirs
  Given a named dir (hash -d) points at a directory under $HOME
  And the current directory is inside that named dir's target
  When PS1 renders
  Then the cwd shows ~ only for the $HOME segment
  And the named dir is not collapsed to its ~name form
  And non-tail segments shrink to their first character
  And the last two segments stay full
