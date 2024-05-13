# ----------------------------------------
# [PythonToSW] Announce
# ----------------------------------------

# A Python package that allows you to execute server functions in a Stormworks: Build and Rescue addon.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
from . import BaseExecution

# ---- // Main
class Announce(BaseExecution):
    def __init__(self, author: str, message: str, peer_id: int):
        super().__init__(
            functionName = "announce",
            arguments = [author, message, peer_id]
        )