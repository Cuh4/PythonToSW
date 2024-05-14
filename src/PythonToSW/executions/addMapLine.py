# ----------------------------------------
# [PythonToSW] Add Map Line
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class AddMapLine(BaseExecution):
    def __init__(self, peer_id: int, ui_id: int, startPos: list, endPos: list, width: int, r: int = 255, g: int = 255, b: int = 255, a: int = 255):
        super().__init__(
            functionName = "addMapLine",
            arguments = [peer_id, ui_id, startPos, endPos, width, r, g, b, a]
        )