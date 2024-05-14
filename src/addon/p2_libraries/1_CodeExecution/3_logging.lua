--------------------------------------------------------
-- [Libraries] Code Execution - Logging
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author: @Cuh4 (GitHub)
        GitHub Repository: https://github.com/Cuh4/PythonToSW

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------
-- Send a log
---@param log string
function CodeExecution:sendLog(log)
    debug.log(("[CodeExecution] %s"):format(log))
end

-- Send error to backend
---@param errorType string
---@param errorMessage string
function CodeExecution:error(errorType, errorMessage)
    self:sendLog(("ERROR (%s): %s"):format(errorType, errorMessage))

    self:sendRequest(AuroraFramework.services.HTTPService.URLArgs(
        "/error",
        {name = "errorType", value = errorType},
        {name = "errorMessage", value = errorMessage}
    ))
end