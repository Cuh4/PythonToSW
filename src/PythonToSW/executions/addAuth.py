# ----------------------------------------
# [PythonToSW] Add Auth
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class AddAuth(BaseExecution):
    def __init__(self, peer_id: int):
        super().__init__(
            functionName = "addAuth",
            arguments = [peer_id]
        )