# Comments Conventions

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
