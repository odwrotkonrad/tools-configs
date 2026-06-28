import pytest


##[>] 🤖🤖🤖
@pytest.fixture
def tree_script(load_script):
    """The render-dirs-tree script loaded as a module."""
    return load_script("render-dirs-tree")


@pytest.fixture
def script(tree_script):
    return tree_script


##[<] 🤖🤖🤖
