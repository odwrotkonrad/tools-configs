## Tests

Asked for tests: write unit tests, unless told otherwise.

- Unit: software deliverable (function, class, command, subcommand etc.)
- Process: a running instance of a program, as in OS nomenclature.
- External interface: anything outside the process that a unit within it can communicate with (services, filesystem, db, OS operations).

Test type is determined by external interface use and assertion scope.

## Test Types

- **Unit**: scoped to the deliverable, no external interfaces.
- **Integration**: scoped to the deliverable, with direct external interfaces.
- **E2E**: assertions scoped beyond the deliverable, with external interfaces.
