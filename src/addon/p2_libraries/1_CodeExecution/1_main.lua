--------------------------------------------------------
-- [Libraries] Code Execution - Main
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author: @cuh6_ (Discord)
        GitHub Repository: https://github.com/Cuh4/PythonToSW

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
            self:triggerCallback(name, ...)
        end)

        ::continue::
    end

    -- manually handle http reply
    AuroraFramework.callbacks.httpReply.main:connect(function(port, ...)
        if port == 0 or port == self.backendPort then -- port 0 returns response the very next tick. not good for http!
            return
        end

        self:triggerCallback("httpReply", ...)
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
        self:triggerCallback("onTick")

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
---
---
---@field start fun(self: CodeExecution) Start fetching pending executions and executing them
---
---@field copyTable fun(self: CodeExecution, tbl: table): table Copy a table
---@field sendRequest fun(self: CodeExecution, URL: string, callback: fun(response: string, successful: boolean)|nil): af_services_http_request Send a GET request
---
---@field sendLog fun(self: CodeExecution, log: string) Send a log
---@field error fun(self: CodeExecution, errorType: string, errorMessage: string) Trigger an error in the backend
---
---@field handlePendingExecutions fun(self: CodeExecution) Handle pending executions
---@field getFunctionFromExecution fun(self: CodeExecution, execution: CodeExecution_PendingExecution): function|nil Get a server function from an execution
---@field returnExecutionResults fun(self: CodeExecution, execution: CodeExecution_PendingExecution, returnValues: table<integer, any>) Send return values to backend
---@field triggerCallback fun(self: CodeExecution, name: string, ...: any) Trigger a callback in the backend

---@class CodeExecution_PendingExecution
---@field ID string The ID of this execution
---@field functionName string The name of the function
---@field arguments table<integer, any> The arguments
---@field handled boolean Whether the execution has been handled or not