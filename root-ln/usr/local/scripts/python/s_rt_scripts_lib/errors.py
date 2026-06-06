ERR_ARGS = 11
ERR_CONFIG = 12
ERR_FILE_NOT_FOUND = 13

# […] default messages
ERRORS = {
    ERR_ARGS: "invalid arguments: {args}",
    ERR_CONFIG: "invalid config: {path}: {reason}",
    ERR_FILE_NOT_FOUND: "file not found: {path}",
}
# [⫶]


class ExitError(Exception):
    """[≟] A failure carrying its exit code and context for a templated message.

    `message` formats ERRORS[code] with the context, falling back to the bare
    message (or the code) when a placeholder is missing.
    """

    def __init__(self, code: int, **context: object) -> None:
        super().__init__(code)
        self.code = code
        self.context = context

    @property
    def message(self) -> str:
        f_msg = ERRORS.get(self.code, str(self.code))
        try:
            return f_msg.format(**self.context)
        except (KeyError, IndexError):
            return f_msg
