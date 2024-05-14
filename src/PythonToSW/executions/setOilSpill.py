# ----------------------------------------
# [PythonToSW] Set Oil Spill
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class SetOilSpill(BaseExecution):
    def __init__(self, pos: list, amount: int|float):
        super().__init__(
            functionName = "setOilSpill",
            arguments = [pos, amount]
        )