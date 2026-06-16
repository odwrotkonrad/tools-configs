<!--[…] 🤖 -->
## Comments

### 🤖 Mark AI-Generated Code

Wrap AI-generated code in a comment section, every file type (code, config, YAML, TOML, JSON5, Makefiles, shell, dotfiles).

Mark = requested human attention, not a record. Carefully reviewed code may carry none. Encode in 🤖 count, more = more review:

- 🤖🤖🤖 a lot more
- 🤖🤖 some more (default; creator corrects)
- 🤖 a little more

Lower confidence → more 🤖. Match count to attention wanted.

Before writing/editing ANY file, check marked; if not, add. Catch an unmarked block → mark immediately, unasked.

```sh
#[…] 🤖🤖
foo_a=1
foo_b=2
#[⫶] 🤖🤖
```
When in doubt: MARK IT.


### 🛑 No Comments

Emit zero comments in AI-generated code: no explanatory, convention-label, header/banner, schema-note, TODO/FIXME, docstring, inline, or commented-out code. Every file type. Put explanations in chat.

Before writing/editing ANY file, check for a comment; delete it, move to chat. Catch an added comment → remove immediately, unasked.

Add comments ONLY when the current request explicitly says "comment" (or equivalent). A comment-full file, convention doc, or "explain/document/annotate" request is NOT permission.

ONE exception: the marking section above is MANDATORY, never overridden by this rule.

When in doubt: NO COMMENTS.
