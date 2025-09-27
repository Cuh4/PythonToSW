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
from setuptools import setup, find_packages

# // Variables
with open(os.path.join(os.path.dirname(__file__), "VERSION"), encoding = "utf-8") as file:
    version = file.read()
    
with open(os.path.join(os.path.dirname(__file__), "README.md"), encoding = "utf-8") as file:
    long_description = file.read()
    
with open(os.path.join(os.path.dirname(__file__), "requirements.txt"), encoding = "utf-8") as file:
    requirements = file.read().splitlines()

# // Main
setup(
    name = "PythonToSW",
    version = version,
    author = "Cuh4",
    description = "A package that allows you to create addons in Stormworks with Python, handled through HTTP.",
    long_description = long_description,
    long_description_content_type = "text/markdown",
    packages = find_packages(where = "src"),
    license = "Apache License 2.0",
    
    classifiers = [
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    
    project_urls = {
        "Source code": "https://github.com/Cuh4/PythonToSW"
    },

    install_requires = requirements,

    python_requires = ">=3.12",
    include_package_data = True,
    package_dir = {"": "src"}
)