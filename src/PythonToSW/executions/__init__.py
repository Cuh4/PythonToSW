# ----------------------------------------
# [PythonToSW] Init
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
from .addAdmin import AddAdmin
from .addAuth import AddAuth
from .addMapLabel import AddMapLabel
from .addMapLine import AddMapLine
from .addMapObject import AddMapObject
from .announce import Announce
from .cancelGerstner import CancelGerstner
from .clearOilSpills import ClearOilSpills
from .clearRadiation import ClearRadiation
from .clearVehicles import ClearVehicles
from .despawnObject import DespawnObject
from .despawnVehicle import DespawnVehicle
from .despawnVehicleGroup import DespawnVehicleGroup
from .getCharacterItem import GetCharacterItem
from .getObjectData import GetObjectData
from .getPlayerCharacter import GetPlayerCharacter
from .getPlayerPos import GetPlayerPos
from .getPlayers import GetPlayers
from .getSeasonalEvent import GetSeasonalEvent
from .getUniqueID import GetUniqueID
from .getVehicleBatteryByName import GetVehicleBatteryByName
from .getVehicleBatteryByVoxel import GetVehicleBatteryByVoxel
from .getVehicleComponents import GetVehicleComponents
from .getVehicleData import GetVehicleData
from .getVehiclePos import GetVehiclePos
from .getVehicleTankByName import GetVehicleTankByName
from .getVehicleTankByVoxel import GetVehicleTankByVoxel
from .isAridDLC import IsAridDLC
from .isSpaceDLC import IsSpaceDLC
from .isWeaponsDLC import IsWeaponsDLC
from .notify import Notify
from .removeAdmin import RemoveAdmin
from .removeAuth import RemoveAuth
from .removeMapLabel import RemoveMapLabel
from .removeMapLine import RemoveMapLine
from .removeMapObject import RemoveMapObject
from .removePopup import RemovePopup
from .setCharacterData import SetCharacterData
from .setCharacterItem import SetCharacterItem
from .setCharacterTooltip import SetCharacterTooltip
from .setCreatureMoveTarget import SetCreatureMoveTarget
from .setOilSpill import SetOilSpill
from .setPlayerPos import SetPlayerPos
from .setPopup import SetPopup
from .setVehicleBatteryByName import SetVehicleBatteryByName
from .setVehicleBatteryByVoxel import SetVehicleBatteryByName
from .setVehicleEditable import SetVehicleEditable
from .setVehicleInvulnerable import SetVehicleInvulnerable
from .setVehiclePos import SetVehiclePos
from .setVehicleShowOnMap import SetVehicleShowOnMap
from .setVehicleTankByName import SetVehicleTankByName
from .setVehicleTankByVoxel import SetVehicleTankByVoxel
from .spawnCharacter import SpawnCharacter
from .spawnCreature import SpawnCreature
from .spawnExplosion import SpawnExplosion
from .spawnMeteor import SpawnMeteor
from .spawnMeteorShower import SpawnMeteorShower
from .spawnTsunami import SpawnTsunami
from .spawnVolcano import SpawnVolcano
from .spawnWhirlpool import SpawnWhirlpool