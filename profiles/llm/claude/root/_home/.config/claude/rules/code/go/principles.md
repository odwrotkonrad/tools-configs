## Go Principles

### Clarity

- Clear is better than clever. Reflection is never clear.
- Readable at scale beats concise: code is read far more than written.
- Least mechanism: language construct, then stdlib, then internal lib, in that order.

### Interfaces

- The bigger the interface, the weaker the abstraction.
- Define interfaces at the consumer, only when a second implementation or a test seam exists.
- Accept interfaces, return structs.
- `interface{}`/`any` says nothing.

### Composition

- Embed and compose. No type hierarchies, no speculative extension points.

### Zero Values

- Make the zero value useful: types usable uninitialized.

### Errors

- Errors are values: handle at the occurrence site, wrap with context (`%w`).
- Don't panic.
- Plan for failure, not success.
- Return early: happy path at minimal indentation.

### Packages

- A good package starts with a good name: short, lowercase, no `util`/`common`.
- Package name is part of the API: `http.Server`, not `http.HTTPServer`.
- Avoid package-level state.
- A little copying is better than a little dependency.

### Concurrency

- Share memory by communicating.
- Before launching a goroutine, know when it stops.
- Leave concurrency to the caller.
- Channels orchestrate, mutexes serialize.

### Performance

- If you think it's slow, prove it with a benchmark.

### API

- Documentation is for users: doc comments on every exported symbol.
- Tests lock in the API contract.
- gofmt settles style.
