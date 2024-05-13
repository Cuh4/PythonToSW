# ----------------------------------------
# [PythonToSW] Remove Popup
# ----------------------------------------

# A Python package that allows you to execute server functions in a Stormworks: Build and Rescue addon.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class RemovePopup(BaseExecution):
    def __init__(self, peer_id: int, ui_id: int):
        super().__init__(
            functionName = "removePopup",
            arguments = [peer_id, ui_id]
        )