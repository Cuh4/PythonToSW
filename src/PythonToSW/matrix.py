# ----------------------------------------
# [PythonToSW] Matrix
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Main
def new(x: float|int, y: float|int, z: float|int):
    return [
        1, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 1, 0,
        x, y, z, 1
    ]
    
def getXYZ(matrix: list):
    return matrix[12], matrix[13], matrix[14]