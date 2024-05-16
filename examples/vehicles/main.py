# ----------------------------------------
# [PythonToSW] Example - Vehicles
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

# Import PythonToSW
import PythonToSW as PTS
import time

# Create addon
addon = PTS.Addon(addonName = "Vehicle Spawner", port = 12752)

# Register vehicles
addon.registerVehicle("my_vehicle.xml", vehicleID = 1, isStatic = False, isInvulnerable = False, isShowOnMap = True) # Remember the vehicleID argument for later

# Main code
def main():
    # Get addon index
    addonIndex = addon.execute(PTS.GetAddonIndex())[0]

    # Spawn a vehicle at the player's position if they use any command
    def onCustomCommand(_, peer_id, *__):
        # Prevent creating more loops
        onCustomCommandEvent.disconnectAll()
        
        # Get player position
        playerPos = addon.execute(PTS.GetPlayerPos(peer_id))[0]
        
        # Infinitely spawn vehicles at their position
        while True:
            addon.execute(PTS.SpawnAddonVehicle(playerPos, addonIndex, 1)) # 1 = vehicleID argument from earlier
            time.sleep(1)
        
    onCustomCommandEvent = addon.listen("onCustomCommand", onCustomCommand)

# Start addon
addon.start(main)