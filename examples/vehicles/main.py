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

# Create addon
addon = PTS.Addon(addonName = "Vehicles", port = 12752)

# Register vehicles
addon.registerVehicle("vehicle_1.xml", isStatic = True, isEditable = False, isInvulnerable = True, isShowOnMap = True, isTransponderActive = True) # All of these "is" arguments default to False. Important note: The ID of this vehicle is 1. You can find this out from the name (vehicle_*1*.xml)

# Main code
def main():
    # Get addon index
    addonIndex = addon.execute(PTS.GetAddonIndex())[0]
    
    # Spawn a vehicle at 0, 10, 0
    addon.execute(
        PTS.SpawnAddonVehicle(PTS.matrix.new(0, 10, 0), addonIndex, 1)
    )

# Start addon
addon.start(main)