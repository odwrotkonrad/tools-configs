import pytest


@pytest.fixture
def markdown_script(load_script):
    """The s-rt-gen-markdown script loaded as a module."""
    return load_script("s-rt-gen-markdown")


@pytest.fixture
def script(markdown_script):
    return markdown_script
