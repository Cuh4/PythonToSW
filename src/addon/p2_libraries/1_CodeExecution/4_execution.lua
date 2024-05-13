--------------------------------------------------------
-- [Libraries] Code Execution - Execution
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
                self:sendLog(("Processing execution %s."):format(execution.ID))

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
    self:sendLog("Triggering callback: "..name)

    self:sendRequest(AuroraFramework.services.HTTPService.URLArgs(
        "/trigger-callback",
        {name = name, value = name},
        {name = "args", value = AuroraFramework.services.HTTPService.JSON.encode({...})}
    ))
end