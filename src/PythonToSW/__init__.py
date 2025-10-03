"""
----------------------------------------------
PythonToSW: A Python package that allows you to make Stormworks addons with Python.
https://github.com/Cuh4/PythonToSW
----------------------------------------------

Copyright (C) 2025 Cuh4

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

# // Imports
import os
PACKAGE_PATH = os.path.dirname(os.path.abspath(__file__))

from . import log
from .log import logger

from .libs import (
    io,
    xml,
    http,
)

from .libs.persistence import Persistence
from .libs.event import Event

from . import exceptions

from .values import *
from .enums import *
from .models import *

from .addon import *

# // Main
from logging import INFO as _INFO
log.install(_INFO)