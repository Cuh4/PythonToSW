# ----------------------------------------
# [PythonToSW] Add Map Label
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
Copyright (C) 2024 Cuh4

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

# ---- // Imports
from . import BaseExecution
from .. import matrix

# ---- // Main
class AddMapLabel(BaseExecution):
    def __init__(self, peer_id: int, ui_id: int, label_type: int, label: str, pos: list):
        x, _, z = matrix.getXYZ(pos)

        super().__init__(
            functionName = "addMapLabel",
            arguments = [peer_id, ui_id, label_type, label, x, z]
        )