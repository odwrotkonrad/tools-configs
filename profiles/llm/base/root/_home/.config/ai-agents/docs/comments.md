<!-- ##[>] 🤖 -->
## Comments

### 🤖 Mark AI-Generated Code

Wrap AI-generated code in a comment section, every file type (code, config, YAML, TOML, JSON5, Makefiles, shell, dotfiles).

Mark = requested human attention, not a record. Carefully reviewed code may carry none. Encode in 🤖 count, more = more review:

- 🤖🤖🤖 a lot more
- 🤖🤖 some more (default, creator corrects)
- 🤖 a little more

Lower confidence → more 🤖. Match count to attention wanted.

Before writing/editing ANY file, check it is marked, add if not. Catch an unmarked block → mark immediately, unasked.

```sh
##[>] 🤖🤖
foo_a=1
foo_b=2
##[<] 🤖🤖
```
When in doubt: MARK IT.


### 🛑 No Comments

Emit zero comments in AI-generated code: no explanatory, convention-label, header/banner, schema-note, TODO/FIXME, docstring, inline, or commented-out code. Every file type. Put explanations in chat.

🚫 NEVER clarify code with comments. ZERO. No doc comments on types/functions, no field annotations, no allowed-value lists, no restating the line below. "Documents the API" is NOT permission: names and types ARE the docs. Unclear name → rename, NEVER annotate. Every clarifying comment is a defect: delete on sight.

🚫 Labeled comments (`[why]`, `[what]`, `[where]`) are comments. The label notation defines HOW a requested comment is written, NEVER a license to write one. "This context matters", "future reader needs this", "non-obvious decision" → chat, commit message, or docs file. NEVER a comment. No justification exists that permits an unrequested comment.

Before writing/editing ANY file, check for a comment: delete it, move to chat. Catch an added comment → remove immediately, unasked. Re-check your OWN output before finishing: any comment you emitted (except 🤖 marks) is a task failure, fix it before reporting done.

Add comments ONLY when the current request explicitly says "comment" (or equivalent). A comment-full file, convention doc, or "explain/document/annotate" request is NOT permission. Surrounding commented code, repo convention docs, or "important context" are NOT permission either.

ONE exception: the marking section above is MANDATORY, never overridden by this rule.

When in doubt: NO COMMENTS.
