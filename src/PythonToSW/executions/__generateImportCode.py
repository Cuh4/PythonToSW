# ----------------------------------------
# [PythonToSW] Generate Import Code
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
import os
import pyperclip

# ---- // Main
contents = []

for file in os.listdir("."):
    # ignore folders
    if os.path.isdir(file):
        continue
    
    # ignore non .py files
    if not file.endswith(".py"):
        continue
    
    # ignore init and tools
    if file.startswith("__"):
        continue
    
    # read
    content = open(file, "r").read()
    
    # get the class name
    pos = content.find("class ") + 6
    className = ""

    while content[pos]:
        if content[pos] == "(":
            break
        
        className += content[pos]
        pos += 1
    
    # format into import statement
    contents.append(f"from PythonToSW.executions.{os.path.splitext(file)[0]} import {className}")
    
# convert contents to string
contents = "\n".join(contents)

# print and copy
print(contents)
pyperclip.copy(contents)