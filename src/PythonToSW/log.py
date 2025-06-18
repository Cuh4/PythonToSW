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
import logging

from coloredlogs import install as _install

# // Main
logger = logging.getLogger("cuhHub")

console_handler = logging.StreamHandler()
logger.addHandler(console_handler)

def install(level: int):
    """
    Install colored logs with the specified log level.

    Args:
        level (int): The log level to set.
    """
    
    _install(level = level, logger = logger, fmt = "%(asctime)s - %(levelname)s - %(message)s")

def set_log_level(level: int):
    """
    Set the log level for the logger.
    
    Args:
        level (int): The log level to set.
    """
    
    install(level)
    logger.setLevel(level)
    console_handler.setLevel(level)