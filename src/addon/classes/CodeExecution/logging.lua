--------------------------------------------------------
-- [Classes] Code Execution - Logging
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

--[[
    Send a log.
]]
---@param log string
function Classes.CodeExecution:SendLog(log)
    debug.log(("[CodeExecution] %s"):format(log))
end

--[[
    Trigger an error in the backend.
]]
---@param errorType string
---@param errorMessage string
function Classes.CodeExecution:Error(errorType, errorMessage)
    self:SendLog(("ERROR (%s): %s"):format(errorType, errorMessage))

    self:SendRequest(AuroraFramework.services.HTTPService.URLArgs(
        "/error",
        {name = "errorType", value = errorType},
        {name = "errorMessage", value = errorMessage}
    ), nil, true)
end