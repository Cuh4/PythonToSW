# ----------------------------------------
# [PythonToSW] Add Map Object
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

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