--------------------------------------------------------
-- [Libraries] Code Execution - Helpers
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