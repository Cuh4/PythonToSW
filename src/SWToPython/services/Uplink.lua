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
    self.Alive = false

    --[[
        How often to check if the PythonToSW server is alive.
    ]]
    self.AliveCheckTickInterval = 5

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
        The tick interval between handling calls, forwarding `onTick`, etc.
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
    ---@type table<string, boolean>
    self.HandledCalls = {}
end

--[[
    Called when the service is started.
]]
function SWToPython.Uplink:ServiceStart()
    self:HandleCallbacks()

    Noir.Services.TaskService:AddTickTask(function()
        self:HandleCalls()
    end, self.TickInterval, nil, true)

    Noir.Services.TaskService:AddTickTask(function()
        self:CheckAlive()
    end, self.AliveCheckTickInterval, nil, true)
end

--[[
    Sends a request to the PythonToSW server.
]]
---@param endpoint string
---@param params table<string, any>
---@param callback fun(response: any)|nil
---@param error_callback fun(response: NoirHTTPResponse)|nil
---@param overrideAliveCheck boolean|nil
function SWToPython.Uplink:Request(endpoint, params, callback, error_callback, overrideAliveCheck)
    if not self.Alive and not overrideAliveCheck then
        return
    end

    print("HTTP > "..endpoint)

    params["token"] = self.Token

    for key, value in pairs(params) do
        if type(value) == "table" then
            params[key] = Noir.Libraries.JSON:Encode(value)
        end
    end

    Noir.Services.HTTPService:GET(
        endpoint..Noir.Libraries.HTTP:URLParameters(params),
        self.Port,
        function (response)
            if not response:IsOk() then
                if error_callback then
                    error_callback(response)
                    return
                end

                warn("Failed to send request to PythonToSW server: "..response.Text)
                return
            end

            local data = response:JSON()

            if not data then
                warn("Failed to parse response from PythonToSW server: "..response.Text)
                return
            end

            if data["detail"] and Noir.Libraries.String:StartsWith(data["detail"], "no_auth") then
                warn("Can't send request. Outdated token. Try `?reload_scripts`.")
                return
            end

            if callback then
                callback(data)
            end
        end
    )
end

--[[
    Propagates an error to the PythonToSW server.
]]
---@param message string
function SWToPython.Uplink:PropagateError(message)
    warn("Uplink > Error Propagation > "..message)
    self:Request("/error", {message = message})
end

--[[
    Handles any incoming calls from the PythonToSW server.
]]
function SWToPython.Uplink:HandleCalls()
    ---@param calls table<integer, SWToPython.Call>
    self:Request("/calls", {}, function(calls)
        for handled, _ in pairs(self.HandledCalls) do
            if not calls[handled] then -- PythonToSW server has deleted the handled call which can take a bit after we actually handle it,
                self.HandledCalls[handled] = nil -- so we dont need to keep track of it anymore
            end
        end

        for _, _call in pairs(calls) do
            local call = SWToPython.Classes.Call:FromTable(_call)
            self:HandleCall(call)
        end
    end)
end

--[[
    Handles a call
]]
---@param call SWToPython.Call
function SWToPython.Uplink:HandleCall(call)
    if self.HandledCalls[call.ID] then
        return
    end

    local result = {call:Call()}
    self:Request("/calls/"..call.ID.."/return", {return_values = result})

    self.HandledCalls[call.ID] = true
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

    Noir.Callbacks:Connect("onTick", function (...)
        self.Ticks = self.Ticks + 1

        if self.Ticks % self.TickInterval == 0 then
            self:ForwardCallback("onTick", self.Callbacks)
        end
    end)
end

--[[
    Checks if the PythonToSW server is alive.
]]
function SWToPython.Uplink:CheckAlive()
    self:Request("/ok", {}, function(response)
        self.Alive = true
    end, function()
        self.Alive = false
    end)
end