# ----------------------------------------
# [PythonToSW] Helpers
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
A module containing helper functions used throughout this package.

Copyright (C) 2024 Cuh4

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

# ---- // Imports
import urllib.parse
import xmltodict
import os

# ---- // Main
def URLDecode(string: str) -> str:
    """
    URL decode a URL encoded string.

    Args:
        string: (str) The URL encoded string to decode.
        
    Returns:
        (str) The decoded string.
    """

    return urllib.parse.unquote(string)

def XMLEncode(dictionary: dict) -> str:
    """
    URL encode a string.

    Args:
        string: (str) The string to URL encode.
        
    Returns:
        (str) The URL encoded string.
    """

    return xmltodict.unparse(dictionary)

def XMLDecode(string: str) -> dict:
    """
    Decode an XML string into a dictionary.

    Args:
        string: (str) The XML string to decode.
        
    Returns:
        (dict) The result of the XML decoding.
    """

    return xmltodict.parse(string)

def quickRead(path: str, mode: str = "r"):
    """
    Read a file.

    Args:
        path: (str) The path to the file to read.
        mode: (str = "r") The mode to open the file in.

    Returns:
        (str) The content of the file.
    """

    with open(path, mode) as f:
        return f.read()
    
def quickWrite(path: str, content: str, mode: str = "w"):
    """
    Write to a file, creating the directories if they don't exist.

    Args:
        path: (str) The path to the file to write to.
        content: (str) The content to write to the file.
        mode: (str = "w") The mode to open the file in.
        
    Returns:
        (int) The result of the write operation.
    """

    directory = os.path.dirname(path)

    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok = True)
    
    with open(path, mode) as f:
        return f.write(content)