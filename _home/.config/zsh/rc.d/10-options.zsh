#> https://zsh.sourceforge.io/Doc/Release/Options.html


typeset -a opts_disabled=(
  AUTO_CD                      #[DF] #[?] to avoid confusion, for better completion control
  AUTO_NAME_DIRS               #[DF] #[?] to not create named dirs by accident
  BEEP                         #[?] to reduce interruptions
  BSD_ECHO                     #[DF]
  CDABLE_VARS                  #[DF]
  CHASE_LINKS                  #[DF] #[O] predictability is important
  CORRECT                      #[O] reliance on completions should be enough
  CORRECT_ALL                  #[?] to avoid questions and streamline workflow #[O] not useful when advanced completions are on
  CSH_JUNKIE_HISTORY           #[DF]
  CSH_JUNKIE_LOOPS             #[DF]
  HIST_BEEP                    #[DF] #[?] to reduce interruptions
  HIST_EXPIRE_DUPS_FIRST       #[DF] #[O] history completeness and chronological order is important
  HIST_FIND_NO_DUPS            #[DF] #[O] history search predictability is important
  HIST_IGNORE_ALL_DUPS         #[DF] #[O] history completeness is important
  HIST_IGNORE_DUPS             #[DF] #[O] history completeness is important
  HIST_IGNORE_SPACE            #[DF] #[O] completeness is important
  HIST_NO_FUNCTIONS            #[DF] #[O] history completeness is important
  HIST_NO_STORE                #[DF] #[O] history completeness is important
  HIST_REDUCE_BLANKS           #[DF] #[O] history accuracy is important
  HIST_SAVE_NO_DUPS            #[DF] #[O] history completeness is important
  IGNORE_BRACES                #[DF] #[O] brace expansion is cool file{1,2}.txt > file1.txt file2.txt
  INC_APPEND_HISTORY           #[DF]
  KSH_ARRAYS                   #[DF] #[?] because consistency with shell parameters is cool
  KSH_AUTOLOAD                 #[DF]
  KSH_GLOB                     #[DF]
  POSIX_BUILTINS               #[DF]
  PROMPT_BANG                  #[DF] #[?] because I do not currently use "!" in PS to access history event number
  PUSHD_IGNORE_DUPS            #[DF] #[O] dir history completeness is important
  RM_STAR_SILENT               #[DF] #[?] to have safety net while removing files with glob containing *
  SH_FILE_EXPANSION            #[DF]
  SH_GLOB                      #[DF] to enable globbing symbols: | () <>
  SH_OPTION_LETTERS            #[DF] to have zsh as option reference
  SH_WORD_SPLIT                #[DF]
  SINGLE_LINE_ZLE              #[DF]
  SHARE_HISTORY                #[DF]
  APPEND_HISTORY
  GLOBAL_RCS
  CLOBBER                      #[?] to avoid accidental file overrides
  GLOB_SUBST                   #[D] 
  GLOB_ASSIGN                  #[D]
  HIST_ALLOW_CLOBBER           #[D]
  HUP
)
for opt in ${opts_disabled}; unsetopt ${opt}


typeset -a opts_enabled=(
  EXTENDED_HISTORY
  INC_APPEND_HISTORY_TIME
  AUTO_PUSHD                   #[?] to retain history of entered directories
  BAD_PATTERN                  #[DF]
  BANG_HIST                    #[?] to enable history search shortcuts: !!, !?, !n, !str
  BARE_GLOB_QUAL               #[DF] #[O] file qualifier in glob is cool
  BG_NICE                      #[DF]
  CD_SILENT                    #[?] to reduce verbosity when changing dirs
  CSH_NULL_GLOB                #[?] more predictive multiple globs behavior passed to same argument list
  EXTENDED_GLOB                #[O] ~ # ^ symbols in globbing are cool
  FUNCTION_ARGZERO             #[DF]
  GLOBAL_EXPORT                #[DF]
  HASH_CMDS                    #[DF]
  HASH_LIST_ALL                #[DF]
  HIST_LEX_WORDS               #[O] accuracy is more important than performance
  HIST_SAVE_BY_COPY            #[DF]
  HIST_VERIFY                  #[?] to allow edit history item before executing it
  INTERACTIVE_COMMENTS         #[?] to have robust copy/paste commands including comments
  KSH_OPTION_PRINT             #[?] to show full list of options on `set -o``
  LOCAL_OPTIONS
  LOCAL_TRAPS
  MULTIOS                      #[DF] to avoid using tee for multiple redirections
  NOMATCH                      #[DF] #[?] if CSH_NULL_GLOB gets unset fallback to this option
  NOTIFY                       #[DF]
  PROMPT_PERCENT               #[DF] % is a special character in prompt expansion
  PROMPT_SUBST                 #[?] to enable advanced PS construction
  PUSHD_SILENT                 #[?] to reduce verbosity when changing dirs
  MONITOR
)
for opt in ${opts_enabled}; setopt ${opt}


unset opts_disabled opts_enabled
