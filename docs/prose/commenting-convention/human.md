# Comments Convention

Comments advertise themselves to a reader with a label prefix, to facilitate reader decision whether it'd like to invest energy into consuming parcticular information, helping with prose-in-code postprocessing and programmatic retrieval. Comments answers questions readers may be curious about. Questions types have choosen constant prefix.

## Notation

| Question | Prefix    | Description                         |
| -------- | --------- | ----------------------------------- |
| Where?   | `[where]` | Related reads, sources, references  |
| What?    | `[what]`  | What it is, what its purpose is     |
| Why?     | `[why]`   | Why it exists, why chosen over else |


Presenting understanding[what], reasoning[why], and sources[where] behind code allows further examination of why a bug might be introduced, and gives an opportunity to review not just the code written but the conceptual foundation behind it.

Unprefixed comments purpose is open and not defined.

### AI-Generated Content

AI-generated content is wrapped in a section whose name is one or more 🤖, encoding how much **more** human attention the human wants to give it despite being AI-generated: 🤖🤖🤖 a lot more, 🤖🤖 some more, 🤖 a little more.

### Sectioning

Contents of a file might be divided into sections and subsections. A section starts with `[>]` and ends with `[<]`; both carry the section name. Nesting is expressed by repeating the file's comment leader (its first character), with the **top level carrying the fewest** extra leaders and each deeper level one more, so the extra-leader count equals the section's depth from the top. Example for leader `#`: top `##[>] x`, nested `###[>] x`, deeper `####[>] x`; for leader `//`: `///[>] x`, `////[>] x`.

| Description        | Token | Depth                                  |
| ------------------ | ----- | -------------------------------------- |
| Section start      | `[>]` | leader + N extra leaders, N = depth    |
| Section end        | `[<]` | leader + N extra leaders, N = depth    |


## Examples

### Inline

```sh
$ foo 123       #[where] http://foo.bar.io
$ foo 123       #[where] $ man 5 foo
$ param=foo     #[why] foo was set over bar because it improves developer experience
$ cmd -f        #[what] -f means foo
```

### Block

```sh
#>[where]
# http://foo.bar.io
#   pages descriptions and encoding
# $ man 5 foo
#   sections DESCRIPTION, ENCODING
#/[where]
foo 123
```

```sh
#>[why]
#   bar
#   is
#   better
#   than
#   foo
#/[why]
param=foo
```

```sh
#>[what]
#   source is available but I'm putting a dump
#   of my current understanding of a topic
#   to enable peer correction and learnings
#   because "what is" could differ by person
#/[what]
param=bar
```

### Sections

```sh
##[>] foo
foo_a=1
foo_b=2
  ###[>] bar
  bar_a=1
  bar_b=2
  ###[<] bar
##[<] foo
```
