--------------------------------------------------------
-- [Libraries] Code Execution - Logging
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