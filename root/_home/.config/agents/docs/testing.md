## Tests

Asked for tests: write unit tests, unless told otherwise.

1. Unit - software deliverable (function, class, command, subcommand etc.)
2. Test type is determined by its use of external interfaces and assertion scope.
3. External interface - anything outside the process that a unit within it can communicate with (e.g. services, filesystem, db, OS operations).

## Test Types

- **Unit**: scoped to the deliverable, no external interfaces.
- **Integration**: scoped to the deliverable, with external interfaces.
- **E2E**: assertions scoped beyond the deliverable, with external interfaces.
