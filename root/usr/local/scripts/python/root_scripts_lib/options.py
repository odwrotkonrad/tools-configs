from pydantic import BaseModel


class ScriptBaseOptions(BaseModel):
    """Options every script carries; scripts subclass to add their own."""

    help: bool = False
