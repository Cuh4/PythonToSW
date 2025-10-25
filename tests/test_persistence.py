"""
----------------------------------------------
PythonToSW: A Python package that allows you to make Stormworks addons with Python.
https://github.com/Cuh4/PythonToSW
----------------------------------------------

Copyright (C) 2025 Cuh4

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

# // Imports
import pytest

from PythonToSW import Persistence
from typing import Generator
import os

from uuid import uuid4

# // Main
@pytest.fixture(scope = "function")
def persistence() -> Generator[Persistence, None, None]:
    """
    Creates a Persistence instance, and cleans it up post-test.
    
    Returns:
        Generator[Persistence, None, None]: A generator that yields a Persistence instance
    """    
    
    persistence = Persistence(f"dump/{uuid4()}.json")
    yield persistence

    persistence.clear()
    os.remove(persistence.path)

def test_setget(persistence: Persistence):
    """
    Tests if we can set and get items in persistence
    
    Args:
        persistence (Persistence): The Persistence instance
    """    
    
    persistence["foo"] = "g"
    assert persistence["foo"] != None, "setitem and/or getitem failed"
    assert persistence["foo"] == "g", "get method failed, value should be 'g'"

    persistence.set("bar", "g")
    assert persistence.get("bar") != None, "set and/or get methods failed"
    assert persistence.get("foo") == "g", "get method failed, value should be 'g'"

    assert "foo" in persistence, "Key 'foo' should be in persistence data"
    assert persistence
    
def test_saveget(persistence: Persistence):
    """
    Tests if we can save the default argument in `.get()` method
    
    Args:
        persistence (Persistence): The Persistence instance
    """    
    
    persistence.get("key", "default", save_default = True)
    assert persistence.get("key") == "default", "get method with default value failed, should return 'default'"

def test_del(persistence: Persistence):
    """
    Tests if we can delete items in persistence
    
    Args:
        persistence (Persistence): The Persistence instance
    """

    persistence["greg"] = "bar"
    del persistence["greg"]

    assert "foo" not in persistence, "Key 'foo' should not be in persistence data after deletion"
    
def test_iteration(persistence: Persistence):
    """
    Tests if we can iterate over the keys in persistence
    
    Args:
        persistence (Persistence): The Persistence instance
    """
    
    # add some data to iterate over
    for i in range(5):
        persistence[f"key_{i}"] = f"value_{i}"
    
    # iterate
    length = len(persistence)
    count = 0
    
    for _ in persistence:
        count += 1
        
    assert count == length, "Iteration failed, length and count should be equal"
    
    # iterate over keys
    for key in persistence.keys():
        pass # just to check if it works and doesn't error
    
    # iterate over values
    for value in persistence.values():
        pass # just to check if it works and doesn't error
    
def test_methods(persistence: Persistence):
    """
    Tests if we can use the methods in persistence
    
    Args:
        persistence (Persistence): The Persistence instance
    """
    
    persistence.set("new_key", "new_value")
    assert persistence.get("new_key") == "new_value", "set and get methods failed"
    
    # Test delete
    persistence.delete("new_key")
    assert persistence.get("new_key") is None, "delete method failed, key should not exist anymore"