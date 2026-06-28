import pytest


@pytest.fixture
def os_script(load_script):
    """The get-os-open-files-with script loaded as a module."""
    return load_script("get-os-open-files-with")


@pytest.fixture
def script(os_script):
    return os_script
