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
import xmltodict

# // Main
def encode(dictionary: dict) -> str:
    """
    XML encode a dictionary into an XML string.

    Args:
        dictionary (dict): The dictionary to encode.
        
    Returns:
        str: The encoded XML string.
    """

    return xmltodict.unparse(dictionary, pretty = True)

def decode(string: str) -> dict:
    """
    Decode an XML string into a dictionary.

    Args:
        string (str): The XML string to decode.
        
    Returns:
       dict: The decoded dictionary.
    """

    return xmltodict.parse(string)