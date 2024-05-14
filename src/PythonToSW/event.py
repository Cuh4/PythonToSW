# ----------------------------------------
# [PythonToSW] Event
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
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
    def __init__(self):
        self.callbacks: list["function"] = []
    
    # Register a callback to this event
    def connect(self, callback: "function"):
        self.callbacks.append(callback)
        
    # Unregister a callback from this event
    def disconnect(self, callback: "function"):
        self.callbacks.remove(callback)
        
    # Unregister all callbacks from this event
    def disconnectAll(self):
        self.callbacks = []
        
    # Get all callbacks connected to this event
    def getCallbacks(self):
        return self.callbacks.copy()

    # Fire this event    
    def fire(self, *args, **kwargs):
        for callback in self.getCallbacks():
            self._call(callback, *args, **kwargs)
            
    # Call a function via thread
    def _call(self, func: "function", *args, **kwargs):
        threading.Thread(
            target = func,
            args = args,
            kwargs = kwargs
        ).start()