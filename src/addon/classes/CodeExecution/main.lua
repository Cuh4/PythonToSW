--------------------------------------------------------
-- [Classes] Code Execution - Main
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
    A library for interacting with the PythonToSW backend.
]]
---@class CodeExecution
---@field New fun(backendPort: number, executionTickRate: number): CodeExecution
---@field BackendPort number
---@field ExecutionTickRate number
---@field TickTimer number
---@field Started boolean
---@field Handled table<string, boolean>
---@field RequestCooldown boolean
---@field RequestCooldownDelay af_services_timer_delay|nil
Classes.CodeExecution = Class("CodeExecution")

--[[
    Initializes code execution class objects.
]]
---@param backendPort integer
---@param executionTickRate number
function Classes.CodeExecution:Init(backendPort, executionTickRate)
    self.BackendPort = backendPort
    self.ExecutionTickRate = executionTickRate
    self.TickTimer = 0
    self.Started = false
    self.Handled = {}
    self.RequestCooldown = false
end

--[[
    Starts the library, listening for callbacks and handling pending executions.
]]
function Classes.CodeExecution:Start()
    -- error check
    if self.Started then
        self:Error("Addon", "Attempted to start code execution when it has already started.")
        return
    end

    -- log
    self:SendLog("Started.")

    -- set started
    self.Started = true

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
        self:SendLog(("Connecting to event: %s."):format(name))

        callback.main:connect(function(...)
            self:TriggerCallback(name, true, ...)
        end)

        ::continue::
    end

    -- manually handle http reply
    AuroraFramework.callbacks.httpReply.main:connect(function(port, ...)
        if port == 0 or port == self.BackendPort then -- port 0 returns response the very next tick. not good for http!
            return
        end

        self:TriggerCallback("httpReply", true, ...)
    end)

    -- count up ticks
    AuroraFramework.callbacks.onTick.main:connect(function()
        -- increment ticks
        self.TickTimer = self.TickTimer + 1

        -- check if we should handle pending executions
        if self.TickTimer < self.ExecutionTickRate then
            return
        end

        -- call ontick callback
        self:TriggerCallback("onTick", false)

        -- handle them
        self:HandlePendingExecutions()

        -- reset timer
        self.TickTimer = 0
    end)
end