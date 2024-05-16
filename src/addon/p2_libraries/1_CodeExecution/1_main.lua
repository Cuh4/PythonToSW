--------------------------------------------------------
-- [Libraries] Code Execution - Main
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
---@type CodeExecution
CodeExecution = Class("CodeExecution", function(self, backendPort, executionTickRate)
    self.backendPort = backendPort
    self.executionTickRate = executionTickRate
    self.tickTimer = 0
    self.started = false
    self.handled = {}
    self.requestCooldown = false
end, BaseLibrary)

-- Start the code execution
function CodeExecution:start()
    -- error check
    if self.started then
        self:error("Addon", "Attempted to start code execution when it has already started.")
        return
    end

    -- log
    self:sendLog("Started.")

    -- set started
    self.started = true

    -- callback functionality
    local exceptions = {
        onTick = true,
        httpReply = true
    }

    for name, callback in pairs(AuroraFramework.callbacks) do
        -- ignore problematic callbacks
        if exceptions[name] then
            goto continue
        end

        -- connect to event and trigger backend callback
        self:sendLog(("Connecting to event: %s."):format(name))

        callback.main:connect(function(...)
            self:triggerCallback(name, true, ...)
        end)

        ::continue::
    end

    -- manually handle http reply
    AuroraFramework.callbacks.httpReply.main:connect(function(port, ...)
        if port == 0 or port == self.backendPort then -- port 0 returns response the very next tick. not good for http!
            return
        end

        self:triggerCallback("httpReply", true, ...)
    end)

    -- count up ticks
    AuroraFramework.callbacks.onTick.main:connect(function()
        -- increment ticks
        self.tickTimer = self.tickTimer + 1

        -- check if we should handle pending executions
        if self.tickTimer < self.executionTickRate then
            return
        end

        -- call ontick callback
        self:triggerCallback("onTick", false)

        -- handle them
        self:handlePendingExecutions()

        -- reset timer
        self.tickTimer = 0
    end)
end

-------------------------------
-- // Intellisense
-------------------------------
---@class CodeExecution: BaseLibrary
---@field backendPort number
---@field executionTickRate number
---@field tickTimer number
---@field started boolean
---@field handled table<string, boolean>
---@field requestCooldown boolean
---@field requestCooldownDelay af_services_timer_delay|nil
---
---
---@field start fun(self: CodeExecution) Start fetching pending executions and executing them
---
---@field copyTable fun(self: CodeExecution, tbl: table): table Copy a table
---@field sendRequest fun(self: CodeExecution, URL: string, callback: fun(response: string, successful: boolean)|nil, priority: boolean|nil): af_services_http_request Send a GET request
---
---@field sendLog fun(self: CodeExecution, log: string) Send a log
---@field error fun(self: CodeExecution, errorType: string, errorMessage: string) Trigger an error in the backend
---
---@field handlePendingExecutions fun(self: CodeExecution) Handle pending executions
---@field getFunctionFromExecution fun(self: CodeExecution, execution: CodeExecution_PendingExecution): function|nil Get a server function from an execution
---@field returnExecutionResults fun(self: CodeExecution, execution: CodeExecution_PendingExecution, returnValues: table<integer, any>) Send return values to backend
---@field triggerCallback fun(self: CodeExecution, name: string, priority: boolean, ...: any) Trigger a callback in the backend

---@class CodeExecution_PendingExecution
---@field ID string The ID of this execution
---@field functionName string The name of the function
---@field arguments table<integer, any> The arguments
---@field handled boolean Whether the execution has been handled or not