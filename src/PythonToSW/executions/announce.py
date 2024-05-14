# ----------------------------------------
# [PythonToSW] Announce
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class Announce(BaseExecution):
    def __init__(self, author: str, message: str, peer_id: int = -1):
        super().__init__(
            functionName = "announce",
            arguments = [author, message, peer_id]
        )