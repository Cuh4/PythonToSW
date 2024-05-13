# ----------------------------------------
# [PythonToSW] Set Popup
# ----------------------------------------

# A Python package that allows you to execute server functions in a Stormworks: Build and Rescue addon.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution
from .. import matrix

# ---- // Main
class SetPopup(BaseExecution):
    def __init__(self, peer_id: int, ui_id: int, visible: bool, text: str, pos: list, render_distance: int, vehicle_parent_id: int = 0, object_parent_id: int = 0):
        super().__init__(
            functionName = "setPopup",
            arguments = [peer_id, ui_id, "", visible, text, *matrix.getXYZ(pos), render_distance, vehicle_parent_id, object_parent_id]
        )