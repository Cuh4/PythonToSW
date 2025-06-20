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
from urllib.parse import (
    quote,
    unquote
)

from uuid import uuid4

# // Main
def generate_uuid() -> str:
    """
    Generate a random UUID.
    
    Returns:
        str: The generated UUID as a string.
    """
    
    return str(uuid4())

def url_encode(string: str) -> str:
    """
    URL encode a string.
    
    Args:
        string (str): The string to URL encode.
        
    Returns:
        str: The URL encoded string.
    """

    return quote(string)

def url_decode(string: str) -> str:
    """
    URL decode a URL encoded string.
    
    Args:
        string (str): The URL encoded string to decode.
        
    Returns:
        str: The decoded string.
    """

    return unquote(string)