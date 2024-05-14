# ----------------------------------------
# [PythonToSW] Set Player Pos
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class SetPlayerPos(BaseExecution):
    def __init__(self, peer_id: int, pos: list):
        super().__init__(
            functionName = "setPlayerPos",
            arguments = [peer_id, pos]
        )