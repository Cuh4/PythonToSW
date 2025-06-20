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
from typing import Any
from abc import abstractmethod, ABCMeta

# // Main
class BaseValue(metaclass = ABCMeta):
    """
    Base class for all values in PythonToSW.
    """
    
    @staticmethod
    def is_value(instance: BaseValue):
        """
        Checks if the instance is a value.
        
        Args:
            instance (BaseValue): The instance to check.
        
        Returns:
            bool: True if the instance is a value, False otherwise.
        """
        
        return isinstance(instance, BaseValue)

    @abstractmethod
    def build(self):
        """
        Builds the value into a format suitable for Stormworks.
        
        Raises:
            NotImplementedError: If the method is not implemented by a subclass.
        
        Returns:
            The built value.
        """
        
        raise NotImplementedError("The `build` method must be implemented by subclasses.")
    
    @abstractmethod
    def rebuild(cls, value: Any) -> BaseValue:
        """
        Creates a value from the serialized variant (`.build()` return value).
        
        Args:
            value (Any): The value to convert.
            
        Raises:
            NotImplementedError: If the method is not implemented by a subclass.
        
        Returns:
            BaseValue: The converted value.
        """
        
        raise NotImplementedError("The `rebuild` method must be implemented by subclasses.")