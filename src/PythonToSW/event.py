# ----------------------------------------
# [PythonToSW] Event
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
A module containing an Event class that allows you to create and fire events.

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
import threading

# ---- // Main
class Event():
    """
    A class that allows you to pack functions together and call them all at once in different threads.
    
    >>> event = Event()
    >>> event.connect(lambda: print("Hello, world!"))
    >>>
    >>> event.fire()
    """

    def __init__(self):
        self.callbacks: list["function"] = []
    
    def connect(self, callback: "function"):
        """
        Register a callback to this event.
        
        Args:
            callback: (function) The callback to register.
        """

        self.callbacks.append(callback)
        
    def disconnect(self, callback: "function"):
        """
        Unregister a callback from this event.
        
        Args:
            callback: (function) The callback to unregister.
            
        Raises:
            ValueError: Raised if the callback is not connected to this event.
        """

        self.callbacks.remove(callback)
        
    def disconnectAll(self):
        """
        Unregister all callbacks from this event.
        """

        self.callbacks = []
        
    def getCallbacks(self):
        """
        Return all callbacks connected to this event.
        
        Returns:
            list[function]: The callbacks connected to this event.
        """

        return self.callbacks.copy()

    def fire(self, *args, **kwargs):
        """
        Fire all callbacks connected to this event.
        
        Args:
            *args: (list) The arguments to pass to the callbacks.
            **kwargs: (dict) The keyword arguments to pass to the callbacks.
        """

        for callback in self.getCallbacks():
            self._call(callback, *args, **kwargs)
            
    def _call(self, func: "function", *args, **kwargs):
        """
        Call a function in a new thread.
        
        Args:
            func: (function) The function to call.
            *args: (list) The arguments to pass to the function.
            **kwargs: (dict) The keyword arguments to pass to the function.
        """

        threading.Thread(
            target = func,
            args = args,
            kwargs = kwargs
        ).start()