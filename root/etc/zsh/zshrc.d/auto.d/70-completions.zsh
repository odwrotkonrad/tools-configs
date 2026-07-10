zstyle ':completion:*:*:make:*' tag-order 'targets'
zstyle ':completion:*' verbose false  # do not show descriptions
zstyle ':completion:*' menu select    # cycle through options in menu
zstyle ':completion:*' file-sort modification


# if nothing on the left on cursor, start completion instead of insering tab
zstyle ':completion:*' insert-tab false

# categorize different type of matches into groups, e.g files into group, commands into group etc.
zstyle ':completion:*:*:*:*:descriptions' format '%B## %d %b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

# generate completions in order stopping at first that generate matches
# 1. smart case matches - lowercase -> case insensitive, otherwise case sensitive
# 2. separator aware smart case matches - f.b -> foo.bar, o.a -> foo.bar
# 3. fuzzy match
zstyle ':completion:*' matcher-list \
  'm:{[:lower:]}={[:upper:]}' \
  'm:{[:lower:]}={[:upper:]} l:|=* r:|[._-]=* r:|=*' \
  'r:|?=** m:{[:lower:]}={[:upper:]}'

zstyle ':completion:::::' completer _expand_alias _expand _complete _match _approximate _ignored

zstyle ':completion:*' list-dirs-first true

zstyle ':completion:*' use-cache off
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

##[>] 🤖🤖
zstyle ':completion:*:*:touch:argument-1:*' format ''
##[<] 🤖🤖
