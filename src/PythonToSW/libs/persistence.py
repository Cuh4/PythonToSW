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
import json
import os

from typing import (
    Any,
    Iterable,
    ItemsView,
    ValuesView,
    KeysView
)

# // Main
class Persistence():
    """
    Used to store data like a dictionary, but automatically saves to disk.
    """    
    
    def __init__(self, path: str):
        """
        Initializes a new instance of the Persistence class.

        Args:
            path (str): The path to the file used for persistence (.json recommended). Automatically created if it doesn't exist
        """        
        
        self.path = path
        self.data = {}
        self.json_indent = 7
        
        self._ensure_file_exists()
        self._load()
    
    def __getitem__(self, key: str) -> Any:
        """
        Returns the value assigned to the provided key in persistence.
        
        Args:
            key (str): The key to get the value from
            
        Returns:
            Any: The value assigned to the provided key
        """        
        
        return self.get(key)
    
    def __setitem__(self, key: str, value: Any):
        """
        Saves a value to persistence.
        
        Args:
            key (str): The key to save the value under
            value (Any): The value to save
        """        
        
        self.set(key, value)
    
    def __delitem__(self, key: str):
        """
        Deletes the value assigned to the provided key in persistence.
        
        Args:
            key (str): The key to delete the value from
        """        
        
        self.delete(key)
    
    def __contains__(self, key: str) -> bool:
        """
        Returns whether or not the provided key exists in persistence.
        
        Args:
            key (str): The key to check for
            
        Returns:
            bool: Whether or not the provided key exists in persistence
        """        
        
        return self.contains(key)
    
    def __iter__(self) -> Iterable[str]:
        """
        Returns an iterator over the keys in persistence.
        
        Returns:
            Iterable[str]: An iterator over the keys in persistence
        """        
        
        return iter(self.data.keys())
    
    def keys(self) -> KeysView:
        """
        Returns an iterator over the keys in persistence.
        
        Returns:
            KeysView: An iterator over the keys in persistence
        """        
        
        return self.data.keys()
    
    def values(self) -> ValuesView:
        """
        Returns an iterator over the values in persistence.
        
        Returns:
            ValuesView: An iterator over the values in persistence
        """        
        
        return self.data.values()
    
    def items(self) -> ItemsView:
        """
        Returns an iterator over the key-value pairs in persistence.
        
        Returns:
            ItemsView: An iterator over the key-value pairs in persistence
        """        
        
        return self.data.items()
    
    def __len__(self) -> int:
        """
        Returns the number of keys in persistence.
        
        Returns:
            int: The number of saved values in persistence
        """        
        
        return len(self.data)
        
    def _ensure_file_exists(self):
        """
        Ensures the persistence file exists.
        """        
        
        directory = os.path.dirname(self.path)
        
        if not os.path.exists(directory):
            os.makedirs(directory, exist_ok = True)
            
        if not os.path.exists(self.path):
            self._save()
    
    def _save(self):
        """
        Saves persistence data to the persistence file.
        """        
        
        with open(self.path, "w") as file:
            json.dump(self.data, file, indent = self.json_indent)
            
    def _load(self):
        """
        Loads persistence data from the persistence file.
        """        
        
        if os.path.exists(self.path):
            with open(self.path, "r") as file:
                self.data = json.load(file)
            
    def set(self, key: str, value: Any):
        """
        Saves a value to persistence.

        Args:
            key (str): The key to save the value under
            value (Any): The value to save
        """
        
        self.data[key] = value
        self._save()
        
    def get(self, key: str, default: Any = None, save_default: bool = False) -> Any:
        """
        Loads a value from persistence.

        Args:
            key (str): The key to load the value from
            default (Any, optional): The default value to use if the key is not found. Defaults to None
            save_default (bool, optional): Whether or not to save the default value if the key is not found. Defaults to False

        Returns:
            Any: The value loaded from the persistence
        """
        
        value = self.data.get(key)
        
        if value is None:
            if save_default:
                self.set(key, default)

            return default
        
        return value
    
    def contains(self, key: str) -> bool:
        """
        Checks if a key exists in persistence.

        Args:
            key (str): The key to check for

        Returns:
            bool: Whether or not the key exists in persistence
        """
        
        return key in self.data
    
    def delete(self, key: str):
        """
        Deletes a value from persistence.

        Args:
            key (str): The key to delete the value from
        """
        
        del self.data[key]
        self._save()
        
    def clear(self):
        """
        Clears all data from persistence.
        """
        
        self.data.clear()
        self._save()