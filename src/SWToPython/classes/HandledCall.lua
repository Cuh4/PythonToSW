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
---@class SWToPython.HandledCall: NoirDataclass
---@field New fun(self: SWToPython.HandledCall, ID: string): SWToPython.HandledCall
SWToPython.Classes.HandledCall = Noir.Class("HandledCall")

--[[
    Initializes new HandledCall instances.
]]
---@param ID string The ID of the call
function SWToPython.Classes.HandledCall:Init(ID)
    --[[
        The ID of the call.
    ]]
    self.ID = ID

    --[[
        The time the call was handled.
    ]]
    self.HandledAt = Noir.Services.TaskService:GetTimeSeconds()

    --[[
        How long until this handled call can be cleaned up.
    ]]
    self.ExpiresAfter = 60
end

--[[
    Returns if this handled call has expired.
]]
---@return boolean
function SWToPython.Classes.HandledCall:HasExpired()
    return Noir.Services.TaskService:GetTimeSeconds() > self.HandledAt + self.ExpiresAfter
end