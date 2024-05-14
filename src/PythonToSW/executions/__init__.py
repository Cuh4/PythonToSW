# ----------------------------------------
# [PythonToSW] Init
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from .. import exceptions

from uuid import uuid4
import time

# ---- // Main
class BaseExecution():
    def __init__(self, functionName: str, arguments: list = []):
        self.ID = str(uuid4())
        self.functionName = functionName
        self.arguments = arguments
        
        self.handled = False
        self.returnValues = []
        self.isWaiting = False
        
    # Convert this execution to a JSON format
    def _toDict(self):
        return {
            "ID" : self.ID,
            "functionName": self.functionName,
            "arguments": self.arguments,
            "handled": self.handled
        }
        
    # Set return values, etc
    def _return(self, returnValues: list):
        if self.handled:
            raise exceptions.InternalError("Tried to return after already returning")
        
        self.handled = True
        self.returnValues = returnValues
    
    # Halt this execution
    def _halt(self):
        self.isWaiting = False
        
    # Returns if this execution is obsolete
    def _obsolete(self):
        return not self.isWaiting
        
    # Wait until this execution has returned
    def _wait(self) -> list:
        self.isWaiting = True
        
        while not self.handled and self.isWaiting:
            time.sleep(0.01)
            
        return self.returnValues
    
# ---- // Other Executions
from .announce import Announce
from .setPlayerPos import SetPlayerPos
from .getPlayerPos import GetPlayerPos
from .getPlayers import GetPlayers
from .removePopup import RemovePopup
from .setPopup import SetPopup
from .getPlayerCharacter import GetPlayerCharacter