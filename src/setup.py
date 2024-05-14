# ----------------------------------------
# [PythonToSW] Matrix
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
from setuptools import setup, find_packages

# ---- // Main
setup(
    name= "PythonToSW",
    version = "1.0.0",
    author = "Cuh4",
    description = "A package that allows you to create addons in Stormworks with Python, handled through HTTP.",
    long_description = open("../README.md", encoding = "utf-8").read(),
    packages = find_packages(),
    license = "Apache License 2.0",
    
    classifiers = [
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],

    python_requires = ">=3.12",
)