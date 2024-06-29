--------------------------------------------------------
-- [Classes] Code Execution - Helpers
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

--[[
    Send a request to the backend.
]]
---@param URL string
---@param callback fun(response: string, successful: boolean)|nil
---@param priority boolean|nil
---@return af_services_http_request|nil
function Classes.CodeExecution:SendRequest(URL, callback, priority)
    -- Send log
    self:SendLog(("Sending request to %s. | Priority: %s | Is Cooldown: %s"):format(URL, tostring(priority), tostring(self.RequestCooldown)))

    -- stop here if this is not a priority request and a cooldown is active
    if self.RequestCooldown and not priority then
        self:SendLog("Failed to send request due to cooldown. URL: "..URL)
        return
    end

    -- if this is a priority request, then send the request straight away and add a tick cooldown to prevent rate limit
    if priority then
        -- set cooldown
        self.RequestCooldown = true

        -- remove old cooldown if any
        if self.RequestCooldownDelay then
            self.RequestCooldownDelay:remove()
        end

        -- remove cooldown the next tick
        self.RequestCooldownDelay = AuroraFramework.services.timerService.delay.create(0, function()
            self.RequestCooldown = false
            self.RequestCooldownDelay = nil
        end)
    end

    -- send request
    self:SendLog("Successfully sent request.")

    return AuroraFramework.services.HTTPService.request(
        self.BackendPort,
        URL,
        callback
    )
end