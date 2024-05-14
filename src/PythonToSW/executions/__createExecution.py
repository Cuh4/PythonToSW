# ----------------------------------------
# [PythonToSW] Create Execution
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
import sys
import re

# ---- // Main
# sorry, all of this is ugly but it works
function = (" ".join(sys.argv[1:]))

generated = """class _FORMATTEDNAME_(BaseExecution):
    def __init__(self, _ARGUMENTS_):
        super().__init__(
            functionName = "_FUNCTIONNAME_",
            arguments = [_RAWARGUMENTS_]
        )"""
        
# replace name
name = function.split("(")[0].replace("server.", "")
capitalizedName = name[0].upper() + name[1:]
generated = generated.replace("_FUNCTIONNAME_", name)
generated = generated.replace("_FORMATTEDNAME_", capitalizedName)

# replace arguments
start = function.find("(") + 1
rawArguments = function[start:-1].split(", ")
arguments = []

for argument in rawArguments:
    arguments.append(argument.split(": ")[0])
    
generated = generated.replace("_RAWARGUMENTS_", ", ".join(arguments))
generated = generated.replace("_ARGUMENTS_", ", ".join(rawArguments))

# create file
with open(f"{name}.py", "w") as file:
    main = f"""# ----------------------------------------
# [PythonToSW] {re.sub(r"(\w)([A-Z])", r"\1 \2", capitalizedName)}
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

\"\"\"
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
\"\"\"

# ---- // Imports
from . import BaseExecution

# ---- // Main
{generated}"""

    file.write(main)