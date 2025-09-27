--------------------------------------------------------
-- [SWToPython] Uplink
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
    A service that interacts with the localhost PythonToSW server.
    This service receives events, acts accordingly, and returns whatever data needed.
]]
---@class SWToPython.Uplink: NoirService
SWToPython.Uplink = Noir.Services:CreateService(
    "Uplink",
    false,
    "A service that interacts with the localhost PythonToSW server.",
    "A service that interacts with the localhost PythonToSW server. This service receives events, acts accordingly, and returns whatever data needed.",
    {"Cuh4 (https://github.com/Cuh4)"}
)

--[[
    Called when the service is initialized.
]]
function SWToPython.Uplink:ServiceInit()
    --[[
        The status of the PythonToSW server.
    ]]
    self.Alive = true

    --[[
        How often to check if the PythonToSW server is alive.
    ]]
    self.AliveCheckTickInterval = 12 * 64

    --[[
        The port of the PythonToSW server.
    ]]
    ---@diagnostic disable-next-line: undefined-global
    self.Port = __PORT

    --[[
        The request token for the PythonToSW server.
    ]]
    ---@diagnostic disable-next-line: undefined-global
    self.Token = __REQUEST_TOKEN

    --[[
        The tick interval between handling calls, etc.
    ]]
    self.TickInterval = 4 -- Must be >2

    --[[
        The amount of ticks that have passed.
    ]]
    self.Ticks = 0

    --[[
        The callbacks to listen for.
    ]]
    self.Callbacks = {
        "onClearOilSpill",
        "onCreate",
        "onDestroy",
        "onCustomCommand",
        "onChatMessage",
        "onPlayerJoin",
        "onPlayerSit",
        "onPlayerUnsit",
        "onCharacterSit",
        "onCharacterUnsit",
        "onCharacterPickup",
        "onCreatureSit",
        "onCreatureUnsit",
        "onCreaturePickup",
        "onEquipmentPickup",
        "onEquipmentDrop",
        "onPlayerRespawn",
        "onPlayerLeave",
        "onToggleMap",
        "onPlayerDie",
        "onVehicleSpawn",
        "onGroupSpawn",
        "onVehicleDespawn",
        "onVehicleLoad",
        "onVehicleUnload",
        "onVehicleTeleport",
        "onObjectLoad",
        "onObjectUnload",
        "onButtonPress",
        "onSpawnAddonComponent",
        "onVehicleDamaged",
        "onFireExtinguished",
        "onForestFireSpawned",
        "onForestFireExtinguished",
        "onTornado",
        "onMeteor",
        "onTsunami",
        "onWhirlpool",
        "onVolcano",
        "onOilSpill"
    }

    --[[
        A table of handled calls by IDs.
    ]]
    ---@type table<string, SWToPython.HandledCall>
    self.HandledCalls = {}
end

--[[
    Called when the service is started.
]]
function SWToPython.Uplink:ServiceStart()
    self:HandleCallbacks()

    --[[
        A repeated task for handling incoming calls.
    ]]
    self.CallHandlerTask = Noir.Services.TaskService:AddTickTask(function()
        self:HandleCalls()
    end, self.TickInterval, nil, true)

    --[[
        A repeated task for checking if the PythonToSW server is alive.
    ]]
    self.CheckAliveTask = Noir.Services.TaskService:AddTickTask(function()
        self:CheckAlive()
    end, self.AliveCheckTickInterval, nil, true)

    --[[
        A connection to onTick. Used for repeated, low-perf impact, non-HTTP operations
    ]]
    self.OnTickConnection = Noir.Callbacks:Connect("onTick", function()
        self:CleanupHandledCalls()
    end)
end

--[[
    Sends a request to the PythonToSW server.
]]
---@param endpoint string
---@param params table<string, any>
---@param callback fun(response: any)|nil
---@param overrideAliveCheck boolean|nil
function SWToPython.Uplink:Request(endpoint, params, callback, overrideAliveCheck)
    if not self.Alive and not overrideAliveCheck then
        return
    end

    -- Pass token with request
    params["token"] = self.Token

    -- JSON encode certain data
    for key, value in pairs(params) do
        if type(value) == "table" then
            params[key] = Noir.Libraries.JSON:Encode(value)
        end
    end

    -- Send the request
    Noir.Services.HTTPService:GET(
        endpoint..Noir.Libraries.HTTP:URLParameters(params),
        self.Port,
        function (response)
            -- http queue fuckery
            if not self.Alive and not overrideAliveCheck then
                return
            end

            -- if the request failed, the server is likely down. we'll validate this later
            if not response:IsOk() then
                if not self.Alive then
                    return
                end

                warn("Uplink:Request(): Request returned not ok. Proceeding to assume the PythonToSW server is down. Response: %s", response.Text)
                self:SetAlive(false)

                return
            end

            -- decode the data
            local data = response:JSON()

            if not data then
                warn("Uplink:Request(): Failed to parse response from request to '%s' on PythonToSW server. Response: %s", endpoint, response.Text)
                return
            end

            if data["detail"] and Noir.Libraries.String:StartsWith(data["detail"], "no_auth") then
                warn("Uplink:Request(): Can't send request. Outdated token. Try `?reload_scripts`.")
                return
            end

            if callback then
                callback(data)
            end
        end
    )
end

--[[
    Sets if the PythonToSW server is alive.
]]
---@param alive boolean
function SWToPython.Uplink:SetAlive(alive)
    if self.Alive == alive then
        warn("Uplink:SetAlive(): Attempted to set alive to what it is already.")
        return
    end

    self.Alive = alive

    if self.Alive then
        info("Uplink:SetAlive(): PythonToSW server is alive.")
    else
        warn("Uplink:SetAlive(): PythonToSW server is not alive.")
    end
end

--[[
    Propagates an error to the PythonToSW server.
]]
---@param message string
function SWToPython.Uplink:PropagateError(message)
    warn("Uplink:PropagateError(): "..message)
    self:Request("/error", {message = message})
end

--[[
    Cleans up any handled calls.
]]
function SWToPython.Uplink:CleanupHandledCalls()
    for index, handledCall in pairs(self.HandledCalls) do
        if handledCall:HasExpired() then
            self.HandledCalls[index] = nil
        end
    end
end

--[[
    Handles any incoming calls from the PythonToSW server.
]]
function SWToPython.Uplink:HandleCalls()
    ---@param calls table<string, SWToPython.Call>
    self:Request("/calls", {}, function(calls)
        for _, _call in pairs(calls) do
            local call = SWToPython.Classes.Call:FromTable(_call)
            self:HandleCall(call)
        end
    end)
end

--[[
    Handles a call.
]]
---@param call SWToPython.Call
function SWToPython.Uplink:HandleCall(call)
    if self.HandledCalls[call.ID] then
        return
    end

    local result = {call:Call()}
    self:Request("/calls/"..call.ID.."/return", {return_values = result})

    self.HandledCalls[call.ID] = SWToPython.Classes.HandledCall:New(call.ID)
end

--[[
    Forward callbacks to the PythonToSW server.
]]
---@param name string
---@param ... any
function SWToPython.Uplink:ForwardCallback(name, ...)
    self:Request("/callbacks/"..name, {arguments = {...}})
end

--[[
    Handle all callbacks.
]]
function SWToPython.Uplink:HandleCallbacks()
    for _, callbackName in pairs(self.Callbacks) do
        Noir.Callbacks:Connect(callbackName, function(...)
            self:ForwardCallback(callbackName, ...)
        end)
    end
end

--[[
    Checks if the PythonToSW server is alive.
]]
function SWToPython.Uplink:CheckAlive()
    if self.Alive then
        return
    end

    info("Uplink:CheckAlive(): Checking if PythonToSW server is alive...")

    self:Request("/ok", {}, function(response)
        self:SetAlive(true)
    end, true)
end