# ----------------------------------------
# [PythonToSW] Addon
# ----------------------------------------

# A Python package that allows you to execute server functions in a Stormworks: Build and Rescue addon.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Main
class InternalError(Exception):
    pass

class AddonException(Exception):
    pass

class FailedStartAttempt(Exception):
    pass

class FailedExecutionAttempt(Exception):
    pass

class InvalidExecutionID(Exception):
    pass