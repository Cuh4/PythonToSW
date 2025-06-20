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
from __future__ import annotations

import math
from . import BaseValue

# // Main
class Matrix(BaseValue):
    """
    A class representing a matrix in Stormworks.
    """
    
    def __init__(self, x: float|int, y: float|int, z: float|int):
        """
        Initializes a new instance of the `Matrix` class.

        Args:
            x (float | int): The x-coordinate of the matrix.
            y (float | int): The y-coordinate of the matrix.
            z (float | int): The z-coordinate of the matrix.
        """        

        self.x = x
        self.y = y
        self.z = z
        
    def build(self) -> list:
        """
        Builds the matrix into a format suitable for Stormworks.

        Returns:
            list: The built matrix.
        """

        return [
            1, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 1, 0,
            self.x, self.y, self.z, 1
        ]
        
    @classmethod
    def rebuild(cls, value: list) -> Matrix:
        """
        Rebuilds a matrix from a Stormworks value.

        Args:
            value (list): The Stormworks value to rebuild from.
            
        Raises:
            ValueError: If the value does not have the expected length of 16 elements.

        Returns:
            Matrix: The rebuilt matrix.
        """
        
        if not isinstance(value, list):
            raise ValueError("Invalid matrix value type. Expected a list.")

        if len(value) != 16:
            raise ValueError("Invalid matrix value length. Expected 16 elements.")

        return cls(
            x = value[12],
            y = value[13],
            z = value[14]
        )

    def distance(self, other: Matrix) -> float:
        """
        Returns the distance between this matrix and another matrix.

        Returns:
            float: The distance between the two matrices.
        """

        return math.sqrt(
            (self.x - other.x) ** 2 +
            (self.y - other.y) ** 2 +
            (self.z - other.z) ** 2
        )