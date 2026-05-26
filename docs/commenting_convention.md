# Comments Convention

Comments advertise themselves to a reader with a label prefix, to facilitate reader decision whether it'd like to invest energy into consuming parcticular information, helping with prose-in-code postprocessing and programmatic retrieval. Comments answers questions readers may be curious about. Questions types have choosen constant symbol assigned.

## Notation

| Question | Symbol | Name                | Code Point |
| -------- | ------ | ------------------- | ---------- |
| Where?   | ⌖      | Position Indicator  | U+2316     |
| What?    | ≟      | Questioned Equal To | U+225F     |
| Why?     | ∵      | Because             | U+2235     |

## Examples

### Inline

```sh
$ foo 123       #[⌖] http://foo.bar.io
$ foo 123       #[⌖] $ man 5 foo
$ param=foo     #[∵] foo was set over bar because it improves developer experience
$ cmd -f        #[≟] -f means foo
```

### Block

```sh
#>[⌖]
# http://foo.bar.io
#   pages descriptions and encoding
# $ man 5 foo
#   sections DESCRIPTION, ENCODING
#/[⌖]
foo 123
```

```sh
#>[∵]
#   bar
#   is
#   better
#   than
#   foo
#/[∵]
param=foo
```

```sh
#>[≟]
#   source is available but I'm putting a dump
#   of my current understanding of a topic
#   to enable peer correction and learnings
#   because "what is" could differ by person
#/[∵]
param=bar
```
