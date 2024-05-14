--------------------------------------------------------
-- [Libraries] Code Execution - Execution
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
-- Fetch pending executions
function CodeExecution:handlePendingExecutions()
    AuroraFramework.services.HTTPService.request(
        self.backendPort,
        "/get-pending-executions",
        function(response, successful)
            -- success check
            if not successful then
                return
            end

            -- get pending executions
            local pendingExecutions = AuroraFramework.services.HTTPService.JSON.decode(response) ---@type table<integer, CodeExecution_PendingExecution>

            if not pendingExecutions then
                return
            end

            -- log
            self:sendLog("Fetched pending executions, processing...")

            -- iterate through executions
            for _, execution in pairs(pendingExecutions) do
                -- check if we've already handled this execution
                if self.handled[execution.ID] then -- this is in place because the "/return" http request takes time, and this may take enough time that we get the same execution again before it is recognized as handled by "/return" request
                    if execution.handled then
                        self.handled[execution.ID] = nil -- garbage cleanup
                    end

                    goto continue
                end

                if execution.handled then
                    goto continue
                end

                -- log
                self:sendLog(("Processing execution: %s (%s)"):format(execution.ID, execution.functionName))

                -- get function
                local executionFunction = self:getFunctionFromExecution(execution)

                if not executionFunction then
                    self:error("Execution", ("Function name in execution is invalid, got: %s"):format(execution.functionName))
                    goto continue
                end

                -- call function
                local returnValues = table.pack(
                    executionFunction(table.unpack(execution.arguments))
                )

                -- send result to backend
                self:returnExecutionResults(execution, returnValues)

                -- mark as handled
                self.handled[execution.ID] = true

                -- log
                self:sendLog(("Handled execution %s. Sent return values back."):format(execution.ID))

                ::continue::
            end
        end
    )
end

-- Get function from execution
---@param execution CodeExecution_PendingExecution
---@return function
function CodeExecution:getFunctionFromExecution(execution)
    return server[execution.functionName]
end

-- Send return values to backend
---@param execution CodeExecution_PendingExecution
---@param returnValues table<integer, any>
function CodeExecution:returnExecutionResults(execution, returnValues)
    self:sendRequest(AuroraFramework.services.HTTPService.URLArgs(
        "/return",
        {name = "id", value = execution.ID},
        {name = "returnValues", value = AuroraFramework.services.HTTPService.JSON.encode(returnValues)} -- sorry, sw only allows GET requests
    ))
end

-- Trigger a callback
---@param name string
---@param ... any
function CodeExecution:triggerCallback(name, ...)
    self:sendRequest(AuroraFramework.services.HTTPService.URLArgs(
        "/trigger-callback",
        {name = "name", value = name},
        {name = "args", value = AuroraFramework.services.HTTPService.JSON.encode({...})}
    ))
end