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
        Fired when we connect to the PythonToSW server.
    ]]
    self.OnConnect = Noir.Libraries.Events:Create()

    --[[
        Fired when we disconnect from the PythonToSW server.
    ]]
    self.OnDisconnect = Noir.Libraries.Events:Create()

    --[[
        The status of the PythonToSW server.
    ]]
    self.Alive = false

    --[[
        How often to check if the PythonToSW server is alive.
    ]]
    self.AliveCheckTickInterval = 12 * 64

    --[[
        The port of the PythonToSW server.
    ]]
    ---@type integer
    ---@diagnostic disable-next-line: undefined-global
    self.Port = __PORT

    --[[
        The request token for the PythonToSW server.
    ]]
    self.Token = "__REQUEST_TOKEN"

    --[[
        The tick interval between updates.
    ]]
    ---@type integer
    ---@diagnostic disable-next-line: undefined-global
    self.TickInterval = __TICK_INTERVAL

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
        A table of triggered callbacks.
    ]]
    ---@type table<integer, SWToPython.TriggeredCallback>
    self.TriggeredCallbacks = {}

    --[[
        A table of handled calls.
    ]]
    ---@type table<string, SWToPython.HandledCall>
    self.HandledCalls = {}

    --[[
        The amount of outgoing requests that haven't received a response yet.
    ]]
    self.Outgoing = 0
end

--[[
    Called when the service is started.
]]
function SWToPython.Uplink:ServiceStart()
    -- Check alive
    self:CheckAlive()

    -- Handle callbacks
    self:HandleCallbacks()

    --[[
        A repeated task for updating the PythonToSW server with new data.
    ]]
    self.UpdateTask = Noir.Services.TaskService:AddTickTask(function()
        self:Update()
    end, self.TickInterval, nil, true)

    --[[
        A repeated task for checking if the PythonToSW server is alive.
    ]]
    self.CheckAliveTask = Noir.Services.TaskService:AddTickTask(function()
        self:CheckAlive()
    end, self.AliveCheckTickInterval, nil, true)

    -- Load handled calls from previous session
    if Noir.AddonReason == "AddonReload" then
        Noir.Services.HoarderService:LoadAll(
            self,
            "HandledCalls",
            self.HandledCalls,
            SWToPython.Classes.HandledCall,
            {}
        )

        Noir.Services.HoarderService:LoadAll(
            self,
            "TriggeredCallbacks",
            self.TriggeredCallbacks,
            SWToPython.Classes.TriggeredCallback,
            {}
        )
    end
end

--[[
    Returns a function from a path, or nil if not found.<br>
    Example path: "server.announce", "foo.bar.myFunction", etc.
]]
---@param path string
---@return function|nil
function SWToPython.Uplink:GetFunction(path)
    local at = _ENV

    for _, segment in pairs(Noir.Libraries.String:Split(path, ".")) do
        local nextPoint = at[segment]

        if not nextPoint then
            return nil
        end

        if type(nextPoint) ~= "table" and type(nextPoint) ~= "function" then
            return nil
        end

        at = nextPoint
    end

    if type(at) == "function" then
        return at
    else
        return nil
    end
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
            self.Outgoing = self.Outgoing - 1

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

            if data["detail"] then
                warn("Uplink:Request(): Sent request, but got an error from PythonToSW server: %s", data["detail"])
                return
            end

            if callback then
                callback(data)
            end
        end
    )

    self.Outgoing = self.Outgoing + 1
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
        print("Uplink:SetAlive(): Connected to PythonToSW server (alive).")
        self.OnConnect:Fire()
    else
        warn("Uplink:SetAlive(): Disconnected from PythonToSW server (not alive).")
        self.OnDisconnect:Fire()
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
    Handles the process of running calls from the PythonToSW server, returning values, etc.
]]
function SWToPython.Uplink:Update()
    local handledCalls = self:HandledCallsToTable()

    for _, handledCall in pairs(self.HandledCalls) do
        self:RemoveHandledCall(handledCall)
    end

    local triggeredCallbacks = self:TriggeredCallbacksToTable()

    for _, triggeredCallback in pairs(self.TriggeredCallbacks) do
        self:RemoveTriggeredCallback(triggeredCallback)
    end

    self:Request(
        "/update",

        {
            handled_calls = handledCalls,
            triggered_callbacks = triggeredCallbacks
        },

        ---@param calls table<integer, table>
        function(calls)
            for _, _call in ipairs(calls) do
                local call = SWToPython.Classes.Call:FromTable(_call)

                if self:HasHandledCall(call) then
                    return
                end

                self:HandleCall(call)
            end
        end
    )
end

--[[
    Converts handled calls to table representations.
]]
---@return table<integer, SwToPython.HandledCall.AsTable>
function SWToPython.Uplink:HandledCallsToTable()
    ---@type table<integer, SwToPython.HandledCall.AsTable>
    local handledCalls = {}

    for _, handledCall in pairs(self.HandledCalls) do
        table.insert(handledCalls, handledCall:ToTable())
    end

    table.sort(handledCalls, function (handledCallA, handledCallB)
        return handledCallA.Time < handledCallB.Time
    end)

    return handledCalls
end

--[[
    Converts triggered callbacks to table representations.
]]
---@return table<integer, SwToPython.TriggeredCallback.AsTable>
function SWToPython.Uplink:TriggeredCallbacksToTable()
    ---@type table<integer, SwToPython.TriggeredCallback.AsTable>
    local triggeredCallbacks = {}

    for _, triggeredCallback in pairs(self.TriggeredCallbacks) do
        table.insert(triggeredCallbacks, triggeredCallback:ToTable())
    end

    table.sort(triggeredCallbacks, function (triggeredCallbackA, triggeredCallbackB)
        return triggeredCallbackA.Time < triggeredCallbackB.Time
    end)

    return triggeredCallbacks
end

--[[
    Handles a call.
]]
---@param call SWToPython.Call
function SWToPython.Uplink:HandleCall(call)
    if self:HasHandledCall(call) then
        return
    end

    local handledCall = call:Call()

    if not handledCall then
        warn("Uplink:HandleCall(): Failed to handle call. ID: %s", call.ID)
        return
    end

    self.HandledCalls[handledCall.ID] = handledCall
    handledCall:Hoard(self, "HandledCalls")
end

--[[
    Returns if a call has been handled.
]]
---@param call SWToPython.Call
---@return boolean
function SWToPython.Uplink:HasHandledCall(call)
    return self.HandledCalls[call.ID] ~= nil
end

--[[
    Removes a handled call.
]]
---@param handledCall SWToPython.HandledCall
function SWToPython.Uplink:RemoveHandledCall(handledCall)
    self.HandledCalls[handledCall.ID] = nil
    handledCall:Unhoard(self, "HandledCalls")
end

--[[
    Invokes a callback.<br>
    Essentially triggers an event up in PythonToSW.
]]
---@param callbackName string
---@param arguments table<integer, any>
---@return SWToPython.TriggeredCallback
function SWToPython.Uplink:InvokeCallback(callbackName, arguments)
    local triggeredCallback = SWToPython.Classes.TriggeredCallback:New(SWToPython.ID:GetID(), callbackName, arguments)
    self.TriggeredCallbacks[triggeredCallback.ID] = triggeredCallback

    triggeredCallback:Hoard(self, "TriggeredCallbacks")

    return triggeredCallback
end

--[[
    Removes a triggered callback.
]]
---@param triggeredCallback SWToPython.TriggeredCallback
function SWToPython.Uplink:RemoveTriggeredCallback(triggeredCallback)
    self.TriggeredCallbacks[triggeredCallback.ID] = nil
    triggeredCallback:Unhoard(self, "TriggeredCallbacks")
end

--[[
    Handle all callbacks.
]]
function SWToPython.Uplink:HandleCallbacks()
    for _, callbackName in pairs(self.Callbacks) do
        Noir.Callbacks:Connect(callbackName, function(...)
            self:InvokeCallback(callbackName, {...})
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

    print("Uplink:CheckAlive(): Checking if PythonToSW server is alive...")

    self:Request("/ok", {}, function(response)
        self:SetAlive(true)
    end, true)
end