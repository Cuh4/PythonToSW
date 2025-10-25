--------------------------------------------------------
-- [SWToPython] Handled Call
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
    A class representing a call from the PythonToSW server that has been handled.
]]
---@class SWToPython.HandledCall: NoirHoardable
---@field New fun(self: SWToPython.HandledCall, ID: string, returnValues: table<integer, any>): SWToPython.HandledCall
SWToPython.Classes.HandledCall = Noir.Class("HandledCall", Noir.Classes.Hoardable)

--[[
    Initializes new HandledCall instances.
]]
---@param ID string
---@param returnValues table<integer, any>
function SWToPython.Classes.HandledCall:Init(ID, returnValues)
    self:InitFrom(Noir.Classes.Hoardable, ID)

    --[[
        The ID of the call.
    ]]
    self.ID = ID

    --[[
        The return values of the call.
    ]]
    self.ReturnValues = returnValues

    --[[
        The time the call was handled.
    ]]
    self.Time = server.getTimeMillisec()
end

--[[
    Converts the HandledCall to a table representation.
]]
---@return SwToPython.HandledCall.AsTable
function SWToPython.Classes.HandledCall:ToTable()
    return {
        ID = self.ID,
        ReturnValues = self.ReturnValues,
        Time = self.Time
    }
end

--[[
    Table representation of a HandledCall. Use for sending to the PythonToSW server.
]]
---@class SwToPython.HandledCall.AsTable
---@field ID string
---@field ReturnValues table<integer, any>
---@field Time number