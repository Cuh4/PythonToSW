# ----------------------------------------
# [PythonToSW] Addon
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
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