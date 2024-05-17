# ----------------------------------------
# [PythonToSW] Init
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
A sub-package containing preset executions for you to use in your code.

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
    """
    Represents an execution that can be sent to the in-game addon.

    You never really need to use this directly. If there is an in-game
    function that doesn't have an execution, create an execution that
    inherits from this. Example:
    
    >>> class MoveGroup(BaseExecution):
    >>>     def __init__(self, group_id: int, pos: list):
    >>>         super().__init__(
    >>>             functionName = "moveGroup",
    >>>             arguments = [group_id, pos]
    >>>         )
    
    Args:
        functionName: (str) The name of the in-game function to call
        arguments: (list) The arguments to pass to the in-game function
    """

    def __init__(self, functionName: str, arguments: list = []):
        self.ID = str(uuid4())
        self.functionName = functionName
        self.arguments = arguments
        
        self.handled = False
        self.returnValues = []
        self.isWaiting = False
        
    def __str__(self):
        return f"Execution-{self.ID} ({self.functionName})"
        
    def _toDict(self):
        """
        Converts this execution into a dictionary that can be sent to the addon
        
        Returns:
            (dict) The dictionary representation of this execution
        """

        return {
            "ID" : self.ID,
            "functionName": self.functionName,
            "arguments": self.arguments,
            "handled": self.handled
        }
        
    def _return(self, returnValues: list):
        """
        Marks this execution as handled and saves return values.
        
        Args:
            returnValues: (list) The return values from the in-game function.
            
        Raises:
            exceptions.InternalError: Raised if this method is called when the execution is already handled.
        """

        if self.handled:
            raise exceptions.InternalError("Tried to return after already returning")
        
        self.handled = True
        self.returnValues = returnValues
    
    def _halt(self):
        """
        Stops waiting on this execution via _wait() method.
        """

        self.isWaiting = False
        
    def _obsolete(self):
        """
        Returns whether this execution has been handled.
        
        Returns:
            (bool) Whether this execution has been handled.
        """

        return not self.isWaiting
        
    def _wait(self) -> list:
        """
        Waits until this execution has been handled and returns the return values.
        
        Returns:
            (list) The return values from the in-game function call.
        """

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
from .getAddonIndex import GetAddonIndex
from .getCharacterItem import GetCharacterItem
from .getCurrency import GetCurrency
from .getGameSettings import GetGameSettings
from .getObjectData import GetObjectData
from .getPlayerCharacter import GetPlayerCharacter
from .getPlayerLookDirection import GetPlayerLookDirection
from .getPlayerName import GetPlayerName
from .getPlayerPos import GetPlayerPos
from .getPlayers import GetPlayers
from .getSeasonalEvent import GetSeasonalEvent
from .getUniqueID import GetUniqueID
from .getVehicleBatteryByName import GetVehicleBatteryByName
from .getVehicleBatteryByVoxel import GetVehicleBatteryByVoxel
from .getVehicleComponents import GetVehicleComponents
from .getVehicleData import GetVehicleData
from .getVehicleGroup import GetVehicleGroup
from .getVehiclePos import GetVehiclePos
from .getVehicleTankByName import GetVehicleTankByName
from .getVehicleTankByVoxel import GetVehicleTankByVoxel
from .isAridDLC import IsAridDLC
from .isSpaceDLC import IsSpaceDLC
from .isWeaponsDLC import IsWeaponsDLC
from .moveGroup import MoveGroup
from .moveGroupSafe import MoveGroupSafe
from .moveVehicle import MoveVehicle
from .moveVehicleSafe import MoveVehicleSafe
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
from .setCurrency import SetCurrency
from .setGameSetting import SetGameSetting
from .setGroupPosSafe import SetGroupPosSafe
from .setOilSpill import SetOilSpill
from .setPlayerPos import SetPlayerPos
from .setPopup import SetPopup
from .setVehicleBatteryByName import SetVehicleBatteryByName
from .setVehicleBatteryByVoxel import SetVehicleBatteryByName
from .setVehicleEditable import SetVehicleEditable
from .setVehicleInvulnerable import SetVehicleInvulnerable
from .setVehiclePos import SetVehiclePos
from .setVehiclePosSafe import SetVehiclePosSafe
from .setVehicleShowOnMap import SetVehicleShowOnMap
from .setVehicleTankByName import SetVehicleTankByName
from .setVehicleTankByVoxel import SetVehicleTankByVoxel
from .spawnAddonVehicle import SpawnAddonVehicle
from .spawnCharacter import SpawnCharacter
from .spawnCreature import SpawnCreature
from .spawnEquipment import SpawnEquipment
from .spawnExplosion import SpawnExplosion
from .spawnMeteor import SpawnMeteor
from .spawnMeteorShower import SpawnMeteorShower
from .spawnObject import SpawnObject
from .spawnTsunami import SpawnTsunami
from .spawnVehicle import SpawnVehicle
from .spawnVolcano import SpawnVolcano
from .spawnWhirlpool import SpawnWhirlpool