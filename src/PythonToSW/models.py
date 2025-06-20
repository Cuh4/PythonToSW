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
from pydantic import (
    BaseModel,
    Field,
    field_serializer,
    SerializationInfo,
    ConfigDict
)

from typing import (
    Union,
    Any
)

from concurrent.futures import Future

from . import CallEnum
from . import BaseValue

# // Main
__all__ = [
    "Call",
    "Token"
]

class Token(BaseModel):
    """
    Represents a token for an addon.
    """
    
    token: str
    set_at: float

class Call(BaseModel):
    """
    Represents a call to a function in the addon.
    """
    
    model_config = ConfigDict(
        arbitrary_types_allowed = True
    )
    
    id: str
    name: CallEnum
    arguments: list[Union[Any, BaseValue]]
    future: Future = Field(exclude = True)
    
    @field_serializer("arguments")
    def serialize_arguments(self, arguments: Union[Any, BaseValue], _info: SerializationInfo):
        """
        Validates the arguments to ensure they are of type Value.
        
        Args:
            arguments (Union[Any, BaseValue]): The list of arguments to validate.
            _info (SerializationInfo): Serialization information.
        
        Returns:
            list: The validated list of arguments.
        """
        
        for index, argument in enumerate(arguments):
            if BaseValue.is_value(argument):
                arguments[index] = argument.build()
                
        return arguments