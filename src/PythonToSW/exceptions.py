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
from fastapi import HTTPException

# // Main
class PTSException(Exception):
    """
    Base class for all exceptions in PythonToSW.
    """

class PTSCallbackException(PTSException):
    """
    Raised when something goes wrong with addon callbacks.
    """
    
class PTSLifecycleException(PTSException):
    """
    Raised when something goes wrong with addon lifecycle.
    """
    
class PTSHTTPException(PTSException, HTTPException):
    """
    Exception class for HTTP errors in PythonToSW.
    Inherits from both `PTSException` and FastAPI's `HTTPException`.
    """

    def __init__(self, status_code: int, type: str, detail: str):
        """
        Initializes a new instance of the `PTSHTTPException` class.
        
        Args:
            status_code (int): The HTTP status code for the exception.
            type (str): The type of the exception.
            detail (str): The detail message for the exception.
        """

        PTSException.__init__(self, detail)
        HTTPException.__init__(self, status_code = status_code, detail = f"{type}: {detail}")