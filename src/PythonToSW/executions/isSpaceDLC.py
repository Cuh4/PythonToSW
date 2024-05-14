# ----------------------------------------
# [PythonToSW] Is Space DLC
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class IsSpaceDLC(BaseExecution):
    def __init__(self):
        super().__init__(
            functionName = "dlcSpace",
        )