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
import os

# // Main
def quick_read(path: str, mode: str = "r"):
    """
    Read a file quickly, creating the directories if they don't exist.
    
    Args:
        path (str): The path to the file to read.
        mode (str, optional): The mode to open the file in. Defaults to "r".
        
    Returns:
        str: The content of the file.
    """

    with open(path, mode) as file:
        return file.read()
    
def quick_write(path: str, content: str, mode: str = "w"):
    """
    Write content to a file quickly, creating the directories if they don't exist.
    
    Args:
        path (str): The path to the file to write.
        content (str): The content to write to the file.
        mode (str, optional): The mode to open the file in. Defaults to "w".
    """

    directory = os.path.dirname(path)

    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok = True)
    
    with open(path, mode) as file:
        file.write(content)