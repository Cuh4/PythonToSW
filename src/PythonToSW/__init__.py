# ----------------------------------------
# [PythonToSW] Init
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
A Python package that allows you to make Stormworks addons with Python.
The source code as well as examples can be found at https://github.com/Cuh4/PythonToSW

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
# Main
from PythonToSW.event import Event
from PythonToSW.addon import Addon, BaseExecution
from PythonToSW import exceptions
from PythonToSW import helpers
from PythonToSW import matrix

# Executions
from PythonToSW.executions.addAdmin import AddAdmin
from PythonToSW.executions.addAuth import AddAuth
from PythonToSW.executions.addMapLabel import AddMapLabel
from PythonToSW.executions.addMapLine import AddMapLine
from PythonToSW.executions.addMapObject import AddMapObject
from PythonToSW.executions.announce import Announce
from PythonToSW.executions.cancelGerstner import CancelGerstner
from PythonToSW.executions.clearOilSpills import ClearOilSpills
from PythonToSW.executions.clearRadiation import ClearRadiation
from PythonToSW.executions.clearVehicles import ClearVehicles
from PythonToSW.executions.despawnObject import DespawnObject
from PythonToSW.executions.despawnVehicle import DespawnVehicle
from PythonToSW.executions.despawnVehicleGroup import DespawnVehicleGroup
from PythonToSW.executions.getAddonIndex import GetAddonIndex
from PythonToSW.executions.getCharacterItem import GetCharacterItem
from PythonToSW.executions.getCurrency import GetCurrency
from PythonToSW.executions.getGameSettings import GetGameSettings
from PythonToSW.executions.getObjectData import GetObjectData
from PythonToSW.executions.getPlayerCharacter import GetPlayerCharacter
from PythonToSW.executions.getPlayerLookDirection import GetPlayerLookDirection
from PythonToSW.executions.getPlayerName import GetPlayerName
from PythonToSW.executions.getPlayerPos import GetPlayerPos
from PythonToSW.executions.getPlayers import GetPlayers
from PythonToSW.executions.getSeasonalEvent import GetSeasonalEvent
from PythonToSW.executions.getUniqueID import GetUniqueID
from PythonToSW.executions.getVehicleBatteryByName import GetVehicleBatteryByName
from PythonToSW.executions.getVehicleBatteryByVoxel import GetVehicleBatteryByVoxel
from PythonToSW.executions.getVehicleComponents import GetVehicleComponents
from PythonToSW.executions.getVehicleData import GetVehicleData
from PythonToSW.executions.getVehicleGroup import GetVehicleGroup
from PythonToSW.executions.getVehiclePos import GetVehiclePos
from PythonToSW.executions.getVehicleTankByName import GetVehicleTankByName
from PythonToSW.executions.getVehicleTankByVoxel import GetVehicleTankByVoxel
from PythonToSW.executions.isAridDLC import IsAridDLC
from PythonToSW.executions.isSpaceDLC import IsSpaceDLC
from PythonToSW.executions.isWeaponsDLC import IsWeaponsDLC
from PythonToSW.executions.moveGroup import MoveGroup
from PythonToSW.executions.moveGroupSafe import MoveGroupSafe
from PythonToSW.executions.moveVehicle import MoveVehicle
from PythonToSW.executions.moveVehicleSafe import MoveVehicleSafe
from PythonToSW.executions.notify import Notify
from PythonToSW.executions.removeAdmin import RemoveAdmin
from PythonToSW.executions.removeAuth import RemoveAuth
from PythonToSW.executions.removeMapLabel import RemoveMapLabel
from PythonToSW.executions.removeMapLine import RemoveMapLine
from PythonToSW.executions.removeMapObject import RemoveMapObject
from PythonToSW.executions.removePopup import RemovePopup
from PythonToSW.executions.setCharacterData import SetCharacterData
from PythonToSW.executions.setCharacterItem import SetCharacterItem
from PythonToSW.executions.setCharacterTooltip import SetCharacterTooltip
from PythonToSW.executions.setCreatureMoveTarget import SetCreatureMoveTarget
from PythonToSW.executions.setCurrency import SetCurrency
from PythonToSW.executions.setGameSetting import SetGameSetting
from PythonToSW.executions.setGroupPosSafe import SetGroupPosSafe
from PythonToSW.executions.setOilSpill import SetOilSpill
from PythonToSW.executions.setPlayerPos import SetPlayerPos
from PythonToSW.executions.setPopup import SetPopup
from PythonToSW.executions.setVehicleBatteryByName import SetVehicleBatteryByName
from PythonToSW.executions.setVehicleBatteryByVoxel import SetVehicleBatteryByName
from PythonToSW.executions.setVehicleEditable import SetVehicleEditable
from PythonToSW.executions.setVehicleInvulnerable import SetVehicleInvulnerable
from PythonToSW.executions.setVehiclePos import SetVehiclePos
from PythonToSW.executions.setVehiclePosSafe import SetVehiclePosSafe
from PythonToSW.executions.setVehicleShowOnMap import SetVehicleShowOnMap
from PythonToSW.executions.setVehicleTankByName import SetVehicleTankByName
from PythonToSW.executions.setVehicleTankByVoxel import SetVehicleTankByVoxel
from PythonToSW.executions.spawnAddonVehicle import SpawnAddonVehicle
from PythonToSW.executions.spawnCharacter import SpawnCharacter
from PythonToSW.executions.spawnCreature import SpawnCreature
from PythonToSW.executions.spawnEquipment import SpawnEquipment
from PythonToSW.executions.spawnExplosion import SpawnExplosion
from PythonToSW.executions.spawnMeteor import SpawnMeteor
from PythonToSW.executions.spawnMeteorShower import SpawnMeteorShower
from PythonToSW.executions.spawnObject import SpawnObject
from PythonToSW.executions.spawnTsunami import SpawnTsunami
from PythonToSW.executions.spawnVehicle import SpawnVehicle
from PythonToSW.executions.spawnVolcano import SpawnVolcano
from PythonToSW.executions.spawnWhirlpool import SpawnWhirlpool