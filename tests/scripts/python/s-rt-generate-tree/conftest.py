import pytest


# […] 🤖🤖🤖
@pytest.fixture
def tree_script(load_script):
    """The s-rt-generate-tree script loaded as a module."""
    return load_script("s-rt-generate-tree")


@pytest.fixture
def script(tree_script):
    return tree_script


# [⫶] 🤖🤖🤖
