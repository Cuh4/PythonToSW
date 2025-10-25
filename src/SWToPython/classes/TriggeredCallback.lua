--------------------------------------------------------
-- [SWToPython] Trigged Callback
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
    A class representing a game callback that has been triggered. Contains arguments from the callback too.
]]
---@class SWToPython.TriggeredCallback: NoirHoardable
---@field New fun(self: SWToPython.TriggeredCallback, ID: number, name: string, arguments: table<integer, any>): SWToPython.TriggeredCallback
SWToPython.Classes.TriggeredCallback = Noir.Class("TriggeredCallback", Noir.Classes.Hoardable)

--[[
    Initializes new TriggeredCallback instances.
]]
---@param ID number
---@param name string
---@param arguments table<integer, any>
function SWToPython.Classes.TriggeredCallback:Init(ID, name, arguments)
    self:InitFrom(Noir.Classes.Hoardable, ID)

    --[[
        The ID of the triggered callback.
    ]]
    self.ID = ID

    --[[
        The name of the callback.
    ]]
    self.Name = name

    --[[
        The arguments of the callback.
    ]]
    self.Arguments = arguments

    --[[
        The time the callback was triggered.
    ]]
    self.Time = server.getTimeMillisec()
end

--[[
    Converts the TriggeredCallback to a table representation.
]]
---@return SwToPython.TriggeredCallback.AsTable
function SWToPython.Classes.TriggeredCallback:ToTable()
    return {
        ID = self.ID,
        Name = self.Name,
        Arguments = self.Arguments,
        Time = self.Time
    }
end

--[[
    Table representation of a TriggeredCallback. Use for sending to the PythonToSW server.
]]
---@class SwToPython.TriggeredCallback.AsTable
---@field ID number
---@field Name string
---@field Arguments table<integer, any>
---@field Time number