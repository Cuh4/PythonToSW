--------------------------------------------------------
-- [Libraries] Code Execution - Helpers
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
-- Create a shallow copy of a table
---@generic passedTable: table
---@param tbl passedTable
---@return passedTable
function CodeExecution:copyTable(tbl)
    local new = {}

    for index, value in pairs(tbl) do
        new[index] = value
    end

    return new
end

-- Send a request
---@param URL string
---@param callback fun(response: string, successful: boolean)|nil
---@return af_services_http_request
function CodeExecution:sendRequest(URL, callback)
    return AuroraFramework.services.HTTPService.request(
        self.backendPort,
        URL,
        callback
    )
end