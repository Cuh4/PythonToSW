# ----------------------------------------
# [PythonToSW] Get Players
# ----------------------------------------

# A Python package that allows you to execute server functions in a Stormworks: Build and Rescue addon.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class GetPlayers(BaseExecution):
    def __init__(self):
        super().__init__(
            functionName = "getPlayers"
        )