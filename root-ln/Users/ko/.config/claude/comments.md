<!--[…] 🤖 -->

## Comments

### Mark AI-Generated Code

> [!CAUTION]
> # 🤖 MARK AI-GENERATED CODE. 🤖
>
> **Do:**
>
> - **Do** mark AI-generated code using comment sections, in **every file
>   type** — code, config, YAML, TOML, JSON5, Makefiles, shell, dotfiles,
>   **everything**.
> - **Do** wrap the code you generate in a comment section so a reader can tell
>   at a glance which parts are AI-generated.
> - **Do** treat the mark as a request for **how much more human attention** the
>   creator should give this code, despite it being AI-generated. The count is
>   the creator's signal, not a record of what already happened: fully
>   AI-generated code that was reviewed carefully may carry **no mark at all**.
> - **Do** encode the requested attention in the **number of 🤖 emojis**, more
>   🤖 meaning more review wanted:
>   - 🤖🤖🤖 — wants **a lot more** review.
>   - 🤖🤖 — wants **some more** review.
>   - 🤖 — wants **a little more** review.
> - **Do** default to **🤖🤖** when marking; the count is ambiguous and the
>   creator will correct it (raising, lowering, or removing the mark).
> - **Do** prefer **more** 🤖 when your confidence in the solution is lower.
> - **Do** check before writing or editing ANY file: *have I marked the
>   AI-generated code with a comment section?* If not — add the section.
> - **Do** mark generated code immediately, without being asked, if you catch
>   yourself having left it unmarked.
>
> **Don't:**
>
> - **Don't** leave AI-generated code unmarked — it is a failure of the task.
> - **Don't** skip the section because the surrounding file is unmarked.
> - **Don't** skip it because terseness seems more helpful — helpfulness is not
>   an exception.
> - **Don't** use a 🤖 count that misrepresents the attention the code wants.
>
> **Example** (default mark — two robots):
>
> ```sh
> #[…] 🤖🤖
> foo_a=1
> foo_b=2
> #[⫶] 🤖🤖
> ```
>
> **This is a HARD STOP. When in doubt: MARK IT.**

### No Comments

> [!CAUTION]
> # 🛑 ZERO COMMENTS. NON-NEGOTIABLE. 🛑
>
> **Don't:**
>
> - **Don't** add any comments to AI-generated code — no explanatory comments,
>   labeled-convention comments, header/banner comments, schema notes,
>   TODO/FIXME, explanatory docstrings, inline notes, or commented-out code.
> - **Don't** add a comment because the surrounding file is full of comments,
>   because it "documents" a convention, or because it seems helpful —
>   helpfulness is not an exception.
> - **Don't** treat silence as permission. The repo convention, a file already
>   having comments, a commenting spec/convention doc, or a request to
>   "explain/document/annotate" is **NOT** permission.
>
> **Do:**
>
> - **Do** treat "no comments" as applying to **every file type** — code,
>   config, YAML, TOML, JSON5, Makefiles, shell, dotfiles, **everything**.
> - **Do** check before writing or editing ANY file: *am I about to emit a
>   comment?* If yes — delete it and put that explanation in **chat** instead.
> - **Do** remove a comment immediately, without being asked, if you catch
>   yourself having added one.
> - **Do** add comments **only** when the user, in their **current** request,
>   **explicitly** asks for them using the word "comment" (or equivalent).
> - **Do** mark AI-generated code with a comment section — this is the **ONE AND
>   ONLY** exception to "zero comments", and it is **MANDATORY, NOT OPTIONAL**.
>   The "no comments" rule **NEVER** overrides it: AI-generated code **MUST
>   ALWAYS** be wrapped in its marking section (see
>   [Mark AI-Generated Code](#mark-ai-generated-code)). **When in doubt: MARK
>   IT.**
>
> **This is a HARD STOP. When in doubt: NO COMMENTS.**

<!--[⫶] 🤖 -->
