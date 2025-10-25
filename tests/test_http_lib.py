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

from string import (
    ascii_letters,
    punctuation,
    digits,
    whitespace
)

from urllib.parse import quote

from PythonToSW import http

# // Main
@pytest.fixture(scope = "module") # change to "function" if randomness is added to the code below or something
def full() -> str:
    """
    Creates a string with all ASCII letters, punctuation, digits, and whitespace
    
    Returns:
        str: The full string containing all characters
    """
    
    return ascii_letters + punctuation + digits + whitespace

def test_encode(full: str):
    """
    Tests if URL encoding a string works
    
    Args:
        full (str): The string to encode
    """    
    
    assert http.url_encode(full) == quote(full), "URL encoding did not return expected result"
    
def test_decode(full: str):
    """
    Tests if URL decoding a string works
    
    Args:
        full (str): The string to decode
    """
    
    assert http.url_decode(http.url_encode(full)) == full, "URL decoding did not return expected result"