--------------------------------------------------------
-- [SWToPython] Call
-- https://github.com/Cuh4/PythonToSW
--------------------------------------------------------

--[[
    Copyright (C) 2025 Cuh4

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a call from the PythonToSW server
]]
---@class SWToPython.Call: NoirDataclass
---@field New fun(self: SWToPython.Call, ID: string, name: string, arguments: table): SWToPython.Call
---@field ID string The ID of the call
---@field Name string The name of the `server.` function to call
---@field Arguments table The arguments of the call
SWToPython.Classes.Call = Noir.Libraries.Dataclasses:New("Call", {
    Noir.Libraries.Dataclasses:Field("ID", "string"),
    Noir.Libraries.Dataclasses:Field("Name", "string"),
    Noir.Libraries.Dataclasses:Field("Arguments", "table")
})

--[[
    Calls the `server.` function in the addon and returns the result.
]]
---@return any
function SWToPython.Classes.Call:Call()
    local func = server[self.Name]

    if not func then
        SWToPython.Uplink:PropagateError("Function "..self.Name.." does not exist.")
        return
    end

    return func(table.unpack(self.Arguments))
end

--[[
    Returns a Call instance from a table representation.
]]
---@param tbl table
---@return SWToPython.Call
function SWToPython.Classes.Call:FromTable(tbl)
    return self:New(
        tbl.id,
        tbl.name,
        tbl.arguments
    )
end