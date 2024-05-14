# ----------------------------------------
# [PythonToSW] Add Map Object
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
from . import BaseExecution
from .. import matrix

# ---- // Main
class AddMapObject(BaseExecution):
    def __init__(self, peer_id: int, ui_id: int, label: str, hoverLabel: str, radius: int|float, positionType: int, markerType: int, pos: list, relativePos: list = matrix.new(0, 0, 0), vehicle_id: int = 0, object_id: int = 0, r: int = 255, g: int = 255, b: int = 255, a: int = 255):
        globalX, _, globalZ = matrix.getXYZ(pos)
        localX, _, localZ = matrix.getXYZ(relativePos)
        
        super().__init__(
            functionName = "addMapObject",
            arguments = [peer_id, ui_id, positionType, markerType, globalX, globalZ, localX, localZ, vehicle_id, object, label, radius, hoverLabel, r, g, b, a]
        )