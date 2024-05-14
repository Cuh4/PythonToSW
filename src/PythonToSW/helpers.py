# ----------------------------------------
# [PythonToSW] Helpers
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
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
# URL decode a string
def URLDecode(string: str) -> str:
    return urllib.parse.unquote(string)

# XML encode a dict
def XMLEncode(dictionary: dict) -> str:
    return xmltodict.unparse(dictionary)

# XML decode a string
def XMLDecode(string: str) -> dict:
    return xmltodict.parse(string)

# Quickly read a file
def quickRead(path: str, mode: str = "r"):
    with open(path, mode) as f:
        return f.read()
    
# Quickly write to a file
def quickWrite(path: str, content: str, mode: str = "w"):
    directory = os.path.dirname(path)

    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok = True)
    
    with open(path, mode) as f:
        return f.write(content)