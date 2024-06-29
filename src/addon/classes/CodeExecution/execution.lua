--------------------------------------------------------
-- [Classes] Code Execution - Execution
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
    Represents a pending execution.
]]
---@class PendingExecution
---@field ID string The ID of this execution
---@field functionName string The name of the function
---@field arguments table<integer, any> The arguments
---@field handled boolean Whether the execution has been handled or not

--[[
    Handles pending executions.
]]
function Classes.CodeExecution:HandlePendingExecutions()
    self:SendRequest("/get-pending-executions", function(response, successful)
        -- success check
        if not successful then
            return
        end

        -- get pending executions
        local pendingExecutions = AuroraFramework.services.HTTPService.JSON.decode(response) ---@type table<integer, PendingExecution>

        if not pendingExecutions then
            return
        end

        -- log
        self:SendLog("Fetched pending executions, processing...")

        -- iterate through executions
        for _, execution in pairs(pendingExecutions) do
            -- check if we've already handled this execution
            if self.Handled[execution.ID] then -- this is in place because the "/return" http request takes time, and this may take enough time that we get the same execution again before it is recognized as handled by "/return" request
                if execution.handled then
                    self.Handled[execution.ID] = nil -- garbage cleanup
                end

                goto continue
            end

            if execution.handled then
                goto continue
            end

            -- log
            self:SendLog(("Processing execution: %s (%s)"):format(execution.ID, execution.functionName))

            -- get function
            local executionFunction = self:GetFunctionFromExecution(execution)

            if not executionFunction then
                self:Error("Execution", ("Function name in execution is invalid, got: %s"):format(execution.functionName))
                goto continue
            end

            -- call function
            local returnValues = table.pack(
                executionFunction(table.unpack(execution.arguments))
            )

            -- send result to backend
            self:ReturnExecutionResults(execution, returnValues)

            -- mark as handled
            self.Handled[execution.ID] = true

            -- log
            self:SendLog(("Handled execution %s. Sent return values back."):format(execution.ID))

            ::continue::
        end
    end, false)
end

--[[
    Get an addon lua function from an execution.
]]
---@param execution PendingExecution
---@return function
function Classes.CodeExecution:GetFunctionFromExecution(execution)
    return server[execution.functionName]
end

--[[
    Send return values to backend.
]]
---@param execution PendingExecution
---@param returnValues table<integer, any>
function Classes.CodeExecution:ReturnExecutionResults(execution, returnValues)
    self:SendRequest(AuroraFramework.services.HTTPService.URLArgs(
        "/return",
        {name = "id", value = execution.ID},
        {name = "returnValues", value = AuroraFramework.services.HTTPService.JSON.encode(returnValues)} -- sorry, sw only allows GET requests
    ), nil, true)
end

--[[
    Send callback data to backend.
]]
---@param name string
---@param priority boolean
---@param ... any
function Classes.CodeExecution:TriggerCallback(name, priority, ...)
    self:SendRequest(AuroraFramework.services.HTTPService.URLArgs(
        "/trigger-callback",
        {name = "name", value = name},
        {name = "args", value = AuroraFramework.services.HTTPService.JSON.encode({...})}
    ), nil, priority)
end