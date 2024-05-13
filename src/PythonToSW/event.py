# ----------------------------------------
# [PythonToSW] Event
# ----------------------------------------

# A Python package that allows you to execute server functions in a Stormworks: Build and Rescue addon.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

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