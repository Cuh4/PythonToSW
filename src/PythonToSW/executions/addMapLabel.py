# ----------------------------------------
# [PythonToSW] Add Map Label
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution
from .. import matrix

# ---- // Main
class AddMapLabel(BaseExecution):
    def __init__(self, peer_id: int, ui_id: int, label_type: int, label: str, pos: list):
        x, _, z = matrix.getXYZ(pos)

        super().__init__(
            functionName = "addMapLabel",
            arguments = [peer_id, ui_id, label_type, label, x, z]
        )