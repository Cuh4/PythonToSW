# ----------------------------------------
# [PythonToSW] Matrix
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
A module that allows you to create and manipulate matrices.

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

# ---- // Variables
import math

# ---- // Main
def new(x: float|int, y: float|int, z: float|int) -> list:
    """
    Creates a new matrix with the given XYZ.

    Args:
        x: (float|int) The X coordinate.
        y: (float|int) The Y coordinate.
        z: (float|int) The Z coordinate. 
        
    Returns:
        (list) The constructed matrix.
    """

    return [
        1, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 1, 0,
        x, y, z, 1
    ]

def getXYZ(matrix: list) -> tuple[float, float, float]:
    """
    Returns the X, Y, and Z coordinates of a matrix.

    Args:
        matrix: (list) The matrix to get the XYZ from.
        
    Returns:
        (float) The X coordinate.
        (float) The Y coordinate.
        (float) The Z coordinate.
    """

    return matrix[12], matrix[13], matrix[14]

def distance(matrix1: list, matrix2: list) -> float:
    """
    Returns the distance between two matrices.

    Args:
        matrix1: (list) The first matrix.
        matrix2: (list) The second matrix.
        
    Returns:
        (float) The distance between the two matrices.
    """

    return math.sqrt((matrix1[12] - matrix2[12])**2 + (matrix1[13] - matrix2[13])**2 + (matrix1[14] - matrix2[14])**2)