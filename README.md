# .files

My configuration files

## Configured Tools

- asdf - https://asdf-vm.com/
- direnv - https://direnv.net/
- git - https://git-scm.com/
- kitty - https://sw.kovidgoyal.net/kitty/
- ssh - https://man7.org/linux/man-pages/man1/ssh.1.html
- zsh - https://zsh.sourceforge.io/

## Loading Configuration

```sh
# load parts that include load_dotfiles function definition
cp -Rsfv _home/. ${HOME}/

# use the function to load full dotfiles
fn_load_dotfiles
```

## Comments - Information Annotation

Configuration is annotated with comments to justify selection in following format:

### #> - Where can this be read about?

Notation:

```shell
#> <url>
<subject>
```

Example:

```shell
#> https://zsh.sourceforge.io/Doc/Release/Options.html
typeset -a opts_disabled=(
```

### #[?] - Why why was this particular setting chosen?

Notation:

```shell
<subject> #[?] <justification>
```

Example:

```shell
AUTO_CD #[?] to avoid confusion, for better completion control
```

### #[DF] - Explicit Default Setting

Notation:

```shell
<subject> #[DF]
```

Example:

```shell
AUTO_NAME_DIRS #[DF]
```

### #[O] - Opinion

Notation:

```shell
<subject> #[O] <opinion>
```

Example:

```shell
CORRECT_ALL #[O] not useful when advanced completions are on
```

### #[I] - Info - Explanatory Information

Notation:

```shell
<subject> #[I]
```

Example:

```shell
PS1  '%# '  #[I] # for root, % for non root
```

## Contributions

I'd be glad to accept contributions in form of public as well as private criticizm, discussion and questions. I'm actively monitoring:

- gitlab work items
- github issues
- email: odwrotkonrad@gmail.com

## Source Code

- Primary Location: https://gitlab.com/konradodwrot/che/dotfiles.git
- Mirror: https://github.com/odwrotkonrad/dotfiles.git
