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
import pytest
from concurrent.futures import Future

import PythonToSW

# // Main
def _test_value(value: PythonToSW.BaseValue):
    """
    Tests the serialization of a value.
    
    Args:
        value (PythonToSW.BaseValue): The value to process.
    """
    
    call = PythonToSW.Call(
        id = "test",
        name = PythonToSW.CallEnum.ADDADMIN,
        arguments = [value],
        future = Future()
    )
    
    assert call.model_dump()["arguments"][0] == value.build(), f"{value.__class__.__name__} serialization failed."
    
def test_matrix_serialization():
    """
    Tests the automatic serialization of matrices.
    """

    _test_value(PythonToSW.Matrix(1, 5, 2))