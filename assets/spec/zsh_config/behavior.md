Feature: zsh config

Scenario: PS1 shows the abbreviated cwd and stack paths render home-aware
  Given the current directory is under $HOME
  And the directory stack holds paths under $HOME
  When I press TAB
  Then the PWD group heading is the glob-depth notation *
  And PS1 shows the cwd abbreviated home-aware, keeping the last two segments full, collapsing earlier segments to their first letter, and showing $HOME as ~
  And each Stack entry displays a ~-prefixed path for $HOME
