## Commenting Guide

### Syntax
[where] - where?
[why] - why?
[what] - what?
[>] [<] - section start, end (leader + N extra leaders, N = depth from top)
🤖 🤖🤖 🤖🤖🤖 - ai gen

### Example

```
foo 123         #[where] $ man 5 foo
param=foo       #[why] foo over bar: better DX
cmd -f          #[what] -f means foo ()
#>[why]
#   foo over bar: better DX
#/[why]
##[>] section 🤖🤖
foo_a=1
###[>] subsection
bar_a=1
###[<] subsection
##[<] section 🤖🤖
```
