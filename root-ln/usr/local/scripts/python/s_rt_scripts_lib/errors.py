##[>] 🤖🤖
class Error(Exception):
    """An error carrying its exit code and context; returned or raised."""

    def __init__(self, code: int, **context: object) -> None:
        super().__init__()
        self.code = code
        self.context = context


class Errors:
    """The exit-code contract: codes and their templated messages."""

    ARGS = 11
    CONFIG = 12
    FILE_NOT_FOUND = 13
    NETWORK = 14

    MESSAGES = {
        ARGS: "invalid arguments: {args}",
        CONFIG: "invalid config: {path}: {reason}",
        FILE_NOT_FOUND: "file not found: {path}",
        NETWORK: "network fetch failed: {url}",
    }

    @classmethod
    def message(cls, error: Error) -> str:
        f_msg = cls.MESSAGES.get(error.code, str(error.code))
        try:
            return f_msg.format(**error.context)
        except (KeyError, IndexError):
            return f_msg


##[<] 🤖🤖
