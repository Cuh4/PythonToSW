# ----------------------------------------
# [PythonToSW] Helpers
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

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