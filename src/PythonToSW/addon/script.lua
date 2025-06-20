--------------------------------------------------------
-- [SWToPython] Init
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
    The main namespace for this addon.
]]
SWToPython = {}

--[[
    A table containing classes used throughout the addon.
]]
SWToPython.Classes = {}

--[[
    A table containing enums used throughout the addon.
]]
SWToPython.Enums = {}

--------------------------------------------------------
-- [Noir] Definition
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Noir Framework @ https://github.com/cuhHub/Noir<br>
    A framework for making Stormworks addons with ease.
]]
Noir = {}

g_savedata = { ---@diagnostic disable-line: lowercase-global
    Noir = {
        Services = {}
    }
}

--------------------------------------------------------
-- [Noir] Class
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Create a class that objects can be created from.<br>
    Note that classes can inherit from other classes.

    local MyClass = Noir.Class("MyClass")

    function MyClass:Init(name) -- This is called when MyClass:New() is called
        self.name = name
    end

    function MyClass:MyName()
        print(self.name)
    end

    local object = MyClass:New("Cuh4")
    object:MyName() -- "Cuh4"
]]
---@param name string
---@param ... NoirClass
---@return NoirClass
function Noir.Class(name, ...)
    --[[
        A class that objects can be created from.

        local MyClass = Noir.Class("MyClass")

        function MyClass:Init(name) -- This is called when MyClass:New() is called
            self.something = true
        end

        local object = MyClass:New("Cuh4")
        print(object.something) -- true
    ]]
    ---@class NoirClass
    ---@field ClassName string The name of this class/object
    ---@field _Parents table<integer, NoirClass> The parent classes that this class inherits from
    ---@field _IsObject boolean Represents whether or not this is a class or a class object (an object created from a class due to class:New() call)
    ---@field _ClassMethods table<string, boolean> A list of methods that are only available on classes and not objects created from classes. Used for :_Descend() exceptions internally
    ---@field Init fun(self: NoirClass, ...) A function that initializes objects created from this class
    local class = {} ---@diagnostic disable-line
    class.ClassName = name
    class._Parents = {...}
    class._IsObject = false
    class._ClassMethods = {
        ["New"] = true,
        ["Init"] = true
    }

    function class:New(...)
        -- Create class object
        ---@type NoirClass
        local object = {} ---@diagnostic disable-line
        self:_Descend(object, self._ClassMethods)

        object._IsObject = true

        -- Bring down methods from parent
        for _, parent in ipairs(self._Parents) do
            parent:_Descend(object, self._ClassMethods)
        end

        -- Call init of object. This init function will provide the needed attributes to the object
        if self.Init then
            self.Init(object, ...)
        else
            error("Class", "'%s' is missing an :Init() method. This method is required for classes. See the documentation for info.", self.ClassName)
        end

        -- Return the object
        return object
    end

    --[[
        Copies attributes and methods from one object to another.<br>
        Used internally. Do not use in your code.
    ]]
    ---@param from NoirClass
    ---@param object NoirClass|table
    ---@param exceptions table<string, boolean>
    function class._Descend(from, object, exceptions)
        -- Type checking
        Noir.TypeChecking:Assert("Noir.Class()._Descend()", "from", from, "class")
        Noir.TypeChecking:Assert("Noir.Class()._Descend()", "object", object, "class", "table")
        Noir.TypeChecking:Assert("Noir.Class()._Descend()", "exceptions", exceptions, "table")

        -- Perform value descending
        for index, value in pairs(from) do
            if exceptions[index] then
                goto continue
            end

            if object[index] then
                goto continue
            end

            object[index] = value

            ::continue::
        end
    end

    --[[
        Creates an object from the parent class and copies it to this object.<br>
        Use this in the :Init() method of a class that inherits from a parent class.<br>
        Any args provided will be passed to the :Init()
    ]]
    ---@param parent NoirClass 
    function class:InitFrom(parent, ...)
        -- Check if this was called from an object
        if not self._IsObject then
            error("Class", "Attempted to call :InitFrom() when 'self' is a class and not an object.")
        end

        -- Create an object from the parent class
        local object = parent:New(...)

        -- Copy and bring new attributes and methods down from the new parent object to this object
        self._Descend(object, self, self._ClassMethods)
    end

    --[[
        Returns if a class/object is the same type as another.<br>
        If `other` is not a class, it will return false.
    ]]
    ---@param other any
    ---@return boolean
    function class:IsSameType(other)
        if not self:IsClass(other) then
            return false
        end

        if self.ClassName == other.ClassName then
            return true
        end

        for _, parent in pairs(other._Parents) do
            if self.ClassName == parent.ClassName then
                return true
            end
        end

        for _, parent in pairs(self._Parents) do
            if other.ClassName == parent.ClassName then
                return true
            end
        end

        return false
    end

    --[[
        Returns if a table is a class or not.
    ]]
    ---@param other NoirClass|any
    ---@return boolean
    function class:IsClass(other)
        return type(other) == "table" and other.ClassName ~= nil
    end

    return class
end

--------------------------------------------------------
-- [Noir] Type Checking
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A module of Noir for checking if a value is of the correct type.<br>
    This normally would be a library, but libraries need to use this and libraries are meant to be independent of each other.
]]
Noir.TypeChecking = {}

--[[
    Raises an error if the value is not any of the provided types.<br>
    This supports checking if a value is a specific class or not too.
]]
---@param origin string The location of the thing (method, function, etc) that called this so the user can find out where something went wrong
---@param parameterName string The name of the parameter that is being type checked
---@param value any
---@param ... NoirTypeCheckingType
function Noir.TypeChecking:Assert(origin, parameterName, value, ...)
    -- TODO: Type checking can't be performed here otherwise we get a stack overflow :-( very small priority but might want to get this sorted in the future

    -- Pack types into a table
    local types = {...}

    -- Get value type
    local valueType = type(value)

    -- Check if the value is of the correct type
    for _, typeToCheck in pairs(types) do
        -- Value == ExactType
        if valueType == typeToCheck then
            return
        end

        -- Value == Any Class
        if typeToCheck == "class" and self._DummyClass:IsClass(value) then
            return
        end

        -- Value == Exact Class
        if self._DummyClass:IsClass(typeToCheck) and typeToCheck:IsSameType(value) then ---@diagnostic disable-line
            return
        end
    end

    -- Otherwise, raise an error
    error(
        origin,
        "Expected %s for parameter '%s', but got '%s'.",
        self:_FormatTypes(types),
        parameterName,
        self._DummyClass:IsClass(value) and value.ClassName.." (Class)" or valueType
    )
end

--[[
    Raises an error if any of the provided values are not any of the provided types.
]]
---@param origin string The location of the thing (method, function, etc) that called this so the user can find out where something went wrong
---@param parameterName string The name of the parameter that is being type checked
---@param values table<integer, any>
---@param ... NoirTypeCheckingType
function Noir.TypeChecking:AssertMany(origin, parameterName, values, ...)
    -- TODO: look at TODO in Noir.TypeChecking:Assert()

    -- Perform type checking on the provided parameters
    self:Assert("Noir.TypeChecking:AssertMany()", "origin", origin, "string")
    self:Assert("Noir.TypeChecking:AssertMany()", "parameterName", parameterName, "string")
    self:Assert("Noir.TypeChecking:AssertMany()", "values", values, "table")

    -- Perform type checking for provided values
    for _, value in pairs(values) do
        self:Assert(origin, parameterName, value, ...)
    end
end

--[[
    Format required types for an error message.<br>
    Used internally.
]]
---@param types table<integer, NoirTypeCheckingType>
---@return string
function Noir.TypeChecking:_FormatTypes(types)
    -- Perform type checking
    self:Assert("Noir.TypeChecking:_FormatTypes()", "types", types, "table")

    -- Format types
    local formatted = ""

    for index, typeToFormat in pairs(types) do
        if self._DummyClass:IsClass(typeToFormat) then
            typeToFormat = typeToFormat.ClassName
        end

        local formattedType = ("'%s'%s"):format(typeToFormat, index ~= #types and (index == #types - 1 and " or " or ", ") or "")
        formatted = formatted..formattedType
    end

    return formatted
end

--[[
    A dummy class for checking if a value is a class or not.<br>
    Used internally.
]]
Noir.TypeChecking._DummyClass = Noir.Class("NoirTypeCheckingDummyClass")

-------------------------------
-- // Intellisense
-------------------------------

---@alias NoirTypeCheckingType
---| "string"
---| "number"
---| "boolean"
---| "nil"
---| "table"
---| "function"
---| "class"
---| NoirClass

--------------------------------------------------------
-- [Noir] Classes
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A table containing classes used throughout Noir.<br>
    This is a good place to store your classes.
]]
Noir.Classes = {}

--------------------------------------------------------
-- [Noir] Classes - AI Target
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents AI target data for a character.
]]
---@class NoirAITarget: NoirClass
---@field New fun(self: NoirAITarget, data: SWTargetData): NoirAITarget
---@field TargetBody NoirBody|nil The body that the character is targeting (if any).
---@field TargetCharacter NoirObject|nil The character that the character is targeting (if any).
---@field TargetPos SWMatrix The position that the character is targeting.
Noir.Classes.AITarget = Noir.Class("AITarget")

--[[
    Initializes class objects from this class.
]]
---@param data SWTargetData
function Noir.Classes.AITarget:Init(data)
    Noir.TypeChecking:Assert("Noir.Classes.AITarget:Init()", "data", data, "table")

    self.TargetBody = data.vehicle and Noir.Services.VehicleService:GetBody(data.vehicle)
    self.TargetCharacter = data.character and Noir.Services.ObjectService:GetObject(data.character)
    self.TargetPos = matrix.translation(data.x or 0, data.y or 0, data.z or 0)
end

--------------------------------------------------------
-- [Noir] Classes - Body
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a body which is apart of a vehicle.<br>
    In Stormworks, this is actually a vehicle apart of a vehicle group.
]]
---@class NoirBody: NoirClass
---@field New fun(self: NoirBody, ID: integer, owner: NoirPlayer|nil, loaded: boolean): NoirBody
---@field ID integer The ID of this body
---@field Owner NoirPlayer|nil The owner of this body, or nil if spawned by an addon OR if the player who owns the body left before Noir starts again (eg: after save load or addon reload)
---@field ParentVehicle NoirVehicle|nil The vehicle this body belongs to. This can be nil if the body or vehicle is despawned
---@field Loaded boolean Whether or not this body is loaded
---@field Spawned boolean Whether or not this body is spawned. This is set to false when the body is despawned
---@field OnDespawn NoirEvent Fired when this body is despawned
---@field OnLoad NoirEvent Fired when this body is loaded
---@field OnUnload NoirEvent Fired when this body is unloaded
---@field OnDamage NoirEvent Arguments: damage (number), voxelX (number), voxelY (number), voxelZ (number) | Fired when this body is damaged
Noir.Classes.Body = Noir.Class("Body")

--[[
    Initializes body class objects.
]]
---@param ID any
---@param owner NoirPlayer|nil
---@param loaded boolean
function Noir.Classes.Body:Init(ID, owner, loaded)
    Noir.TypeChecking:Assert("Noir.Classes.Body:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:Init()", "owner", owner, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Body:Init()", "loaded", loaded, "boolean")

    self.ID = math.floor(ID)
    self.Owner = owner
    self.ParentVehicle = nil
    self.Loaded = loaded
    self.Spawned = true

    self.OnDespawn = Noir.Libraries.Events:Create()
    self.OnLoad = Noir.Libraries.Events:Create()
    self.OnUnload = Noir.Libraries.Events:Create()
    self.OnDamage = Noir.Libraries.Events:Create()
end

--[[
    Serialize the body.<br>
    Used internally.
]]
---@return NoirSerializedBody
function Noir.Classes.Body:_Serialize()
    return {
        ID = self.ID,
        Owner = self.Owner and self.Owner.ID,
        ParentVehicle = self.ParentVehicle and self.ParentVehicle.ID,
        Loaded = self.Loaded
    }
end

--[[
    Deserialize the body.<br>
    Used internally.
]]
---@param serializedBody NoirSerializedBody
---@param setParentVehicle boolean|nil
---@return NoirBody
function Noir.Classes.Body:_Deserialize(serializedBody, setParentVehicle)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:_Deserialize()", "serializedBody", serializedBody, "table")
    Noir.TypeChecking:Assert("Noir.Classes.Body:_Deserialize()", "setParentVehicle", setParentVehicle, "boolean", "nil")

    -- Deserialize
    local body = self:New(
        serializedBody.ID,
        serializedBody.Owner and Noir.Services.PlayerService:GetPlayer(serializedBody.Owner),
        serializedBody.Loaded
    )

    -- Set parent vehicle
    if setParentVehicle and serializedBody.ParentVehicle then
        local parentVehicle = Noir.Services.VehicleService:GetVehicle(serializedBody.ParentVehicle)

        if not parentVehicle then
            error("Noir.Classes.Body:_Deserialize()", "Could not find parent vehicle for a deserialized body.")
        end

        body.ParentVehicle = parentVehicle
    end

    -- Return body
    return body
end

--[[
    Returns the name of the body, or nil if there is none (relies on map icon component)
]]
---@return string|nil
function Noir.Classes.Body:GetName()
    local data = self:GetData()

    if not data then
        return
    end

    if data.name == "" then
        return
    end

    return data.name
end

--[[
    Returns the position of this body.
]]
---@param voxelX integer|nil
---@param voxelY integer|nil
---@param voxelZ integer|nil
function Noir.Classes.Body:GetPosition(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetPosition()", "voxelX", voxelX, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetPosition()", "voxelY", voxelY, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetPosition()", "voxelZ", voxelZ, "number", "nil")

    -- Get and return position
    return (server.getVehiclePos(self.ID))
end

--[[
    Damage this body at the provided voxel.
]]
---@param damageAmount number
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param radius number
function Noir.Classes.Body:Damage(damageAmount, voxelX, voxelY, voxelZ, radius)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:Damage()", "damageAmount", damageAmount, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:Damage()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:Damage()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:Damage()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:Damage()", "radius", radius, "number")

    -- Add damage
    server.addDamage(self.ID, damageAmount, voxelX, voxelY, voxelZ, radius)
end

--[[
    Makes the body invulnerable/vulnerable to damage.
]]
---@param invulnerable boolean
function Noir.Classes.Body:SetInvulnerable(invulnerable)
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetInvulnerable()", "invulnerable", invulnerable, "boolean")
    server.setVehicleInvulnerable(self.ID, invulnerable)
end

--[[
    Makes the body editable/non-editable (dictates whether or not the body can be brought back to the workbench).
]]
---@param editable boolean
function Noir.Classes.Body:SetEditable(editable)
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetEditable()", "editable", editable, "boolean")
    server.setVehicleEditable(self.ID, editable)
end

--[[
    Teleport the body to the specified position.
]]
---@param position SWMatrix
function Noir.Classes.Body:Teleport(position)
    Noir.TypeChecking:Assert("Noir.Classes.Body:Teleport()", "position", position, "table")
    server.setVehiclePos(self.ID, position)
end

--[[
    Move the body to the specified position. Essentially teleports the body without reloading it.<br>
    Rotation is ignored.
]]
---@param position SWMatrix
function Noir.Classes.Body:Move(position)
    Noir.TypeChecking:Assert("Noir.Classes.Body:Move()", "position", position, "table")
    server.moveVehicle(self.ID, position)
end

--[[
    Set a battery's charge (by name).
]]
---@param batteryName string
---@param amount number
function Noir.Classes.Body:SetBattery(batteryName, amount)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetBattery()", "batteryName", batteryName, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetBattery()", "amount", amount, "number")

    -- Set battery
    server.setVehicleBattery(self.ID, batteryName, amount)
end

--[[
    Set a battery's charge (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param amount number
function Noir.Classes.Body:SetBatteryByVoxel(voxelX, voxelY, voxelZ, amount)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetBatteryByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetBatteryByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetBatteryByVoxel()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetBatteryByVoxel()", "amount", amount, "number")

    -- Set battery
    server.setVehicleBattery(self.ID, voxelX, voxelY, voxelZ, amount)
end

--[[
    Set a hopper's amount (by name).
]]
---@param hopperName string
---@param amount number
---@param resourceType SWResourceTypeEnum
function Noir.Classes.Body:SetHopper(hopperName, amount, resourceType)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopper()", "hopperName", hopperName, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopper()", "amount", amount, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopper()", "resourceType", resourceType, "number")

    -- Set hopper
    server.setVehicleHopper(self.ID, hopperName, amount, resourceType)
end

--[[
    Set a hopper's amount (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param amount number
---@param resourceType SWResourceTypeEnum
function Noir.Classes.Body:SetHopperByVoxel(voxelX, voxelY, voxelZ, amount, resourceType)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopperByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopperByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopperByVoxel()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopperByVoxel()", "amount", amount, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetHopperByVoxel()", "resourceType", resourceType, "number")

    -- Set hopper
    server.setVehicleHopper(self.ID, voxelX, voxelY, voxelZ, amount, resourceType)
end

--[[
    Set a keypad's value (by name).
]]
---@param keypadName string
---@param value number
function Noir.Classes.Body:SetKeypad(keypadName, value)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetKeypad()", "keypadName", keypadName, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetKeypad()", "value", value, "number")

    -- Set keypad
    server.setVehicleKeypad(self.ID, keypadName, value)
end

--[[
    Set a keypad's value (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param value number
function Noir.Classes.Body:SetKeypadByVoxel(voxelX, voxelY, voxelZ, value)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetKeypadByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetKeypadByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetKeypadByVoxel()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetKeypadByVoxel()", "value", value, "number")

    -- Set keypad
    server.setVehicleKeypad(self.ID, voxelX, voxelY, voxelZ, value)
end

--[[
    Set a seat's values (by name).
]]
---@param seatName string
---@param axisPitch number
---@param axisRoll number
---@param axisUpDown number
---@param axisYaw number
---@param button1 boolean
---@param button2 boolean
---@param button3 boolean
---@param button4 boolean
---@param button5 boolean
---@param button6 boolean
---@param trigger boolean
function Noir.Classes.Body:SetSeat(seatName, axisPitch, axisRoll, axisUpDown, axisYaw, button1, button2, button3, button4, button5, button6, trigger)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "seatName", seatName, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisPitch", axisPitch, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisRoll", axisRoll, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisUpDown", axisUpDown, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisYaw", axisYaw, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button1", button1, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button2", button2, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button3", button3, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button4", button4, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button5", button5, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button6", button6, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "trigger", trigger, "boolean")

    -- Set seat
    server.setVehicleSeat(self.ID, seatName, axisPitch, axisRoll, axisUpDown, axisYaw, button1, button2, button3, button4, button5, button6, trigger)
end

--[[
    Set a seat's values (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param axisPitch number
---@param axisRoll number
---@param axisUpDown number
---@param axisYaw number
---@param button1 boolean
---@param button2 boolean
---@param button3 boolean
---@param button4 boolean
---@param button5 boolean
---@param button6 boolean
---@param trigger boolean
function Noir.Classes.Body:SetSeatByVoxel(voxelX, voxelY, voxelZ, axisPitch, axisRoll, axisUpDown, axisYaw, button1, button2, button3, button4, button5, button6, trigger)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeatByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeatByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeatByVoxel()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisPitch", axisPitch, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisRoll", axisRoll, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisUpDown", axisUpDown, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "axisYaw", axisYaw, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button1", button1, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button2", button2, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button3", button3, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button4", button4, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button5", button5, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "button6", button6, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetSeat()", "trigger", trigger, "boolean")

    -- Set seat
    server.setVehicleSeat(self.ID, voxelX, voxelY, voxelZ, axisPitch, axisRoll, axisUpDown, axisYaw, button1, button2, button3, button4, button5, button6, trigger)
end

--[[
    Set a weapon's ammo count (by name).
]]
---@param weaponName string
---@param amount number
function Noir.Classes.Body:SetWeapon(weaponName, amount)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetWeapon()", "weaponName", weaponName, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetWeapon()", "amount", amount, "number")

    -- Set weapon
    server.setVehicleWeapon(self.ID, weaponName, amount)
end

--[[
    Set a weapon's ammo count (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param amount number
function Noir.Classes.Body:SetWeaponByVoxel(voxelX, voxelY, voxelZ, amount)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetWeaponByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetWeaponByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetWeaponByVoxel()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetWeaponByVoxel()", "amount", amount, "number")

    -- Set weapon
    server.setVehicleWeapon(self.ID, voxelX, voxelY, voxelZ, amount)
end

--[[
    Set this body's transponder activity.
]]
---@param isActive boolean
function Noir.Classes.Body:SetTransponder(isActive)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTransponder()", "isActive", isActive, "boolean")

    -- Set transponder
    server.setVehicleTransponder(self.ID, isActive)
end

--[[
    Set a tank's contents (by name).
]]
---@param tankName string
---@param amount number
---@param fluidType SWTankFluidTypeEnum
function Noir.Classes.Body:SetTank(tankName, amount, fluidType)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTank()", "tankName", tankName, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTank()", "amount", amount, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTank()", "fluidType", fluidType, "number")

    -- Set tank
    server.setVehicleTank(self.ID, tankName, amount, fluidType)
end

--[[
    Set a tank's contents (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param amount number
---@param fluidType SWTankFluidTypeEnum
function Noir.Classes.Body:SetTankByVoxel(voxelX, voxelY, voxelZ, amount, fluidType)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTankByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTankByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTankByVoxel()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTankByVoxel()", "amount", amount, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTankByVoxel()", "fluidType", fluidType, "number")

    -- Set tank
    server.setVehicleTank(self.ID, voxelX, voxelY, voxelZ, amount, fluidType)
end

--[[
    Set whether or not this body is shown on the map.
]]
---@param isShown boolean
function Noir.Classes.Body:SetShowOnMap(isShown)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetShowOnMap()", "isShown", isShown, "boolean")

    -- Set show on map
    server.setVehicleShowOnMap(self.ID, isShown)
end

--[[
    Reset this body's state.
]]
function Noir.Classes.Body:ResetState()
    server.resetVehicleState(self.ID)
end

--[[
    Set this body's tooltip.
]]
---@param tooltip string
function Noir.Classes.Body:SetTooltip(tooltip)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SetTooltip()", "tooltip", tooltip, "string")

    -- Set tooltip
    server.setVehicleTooltip(self.ID, tooltip)
end

--[[
    Get a battey's data (by name).
]]
---@param batteryName string
---@return SWVehicleBatteryData|nil
function Noir.Classes.Body:GetBattery(batteryName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetBattery()", "batteryName", batteryName, "string")

    -- Get battery
    return (server.getVehicleBattery(self.ID, batteryName))
end

--[[
    Get a battey's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleBatteryData|nil
function Noir.Classes.Body:GetBatteryByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetBatteryByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetBatteryByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetBatteryByVoxel()", "voxelZ", voxelZ, "number")

    -- Get battery
    return (server.getVehicleBattery(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Get a button's data (by name).
]]
---@param buttonName string
---@return SWVehicleButtonData|nil
function Noir.Classes.Body:GetButton(buttonName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetButton()", "buttonName", buttonName, "string")

    -- Get button
    return (server.getVehicleButton(self.ID, buttonName))
end

--[[
    Get a button's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleButtonData|nil
function Noir.Classes.Body:GetButtonByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetButtonByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetButtonByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetButtonByVoxel()", "voxelZ", voxelZ, "number")

    -- Get button
    return (server.getVehicleButton(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Get this body's components.
]]
---@return SWLoadedVehicleData|nil
function Noir.Classes.Body:GetComponents()
    -- Get components
    return (server.getVehicleComponents(self.ID))
end

--[[
    Get this body's data.
]]
---@return SWVehicleData|nil
function Noir.Classes.Body:GetData()
    -- Get data
    return (server.getVehicleData(self.ID))
end

--[[
    Get a dial's data (by name).
]]
---@param dialName string
---@return SWVehicleDialData|nil
function Noir.Classes.Body:GetDial(dialName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetDial()", "dialName", dialName, "string")

    -- Get dial
    return (server.getVehicleDial(self.ID, dialName))
end

--[[
    Get a dial's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleDialData|nil
function Noir.Classes.Body:GetDialByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetDialByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetDialByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetDialByVoxel()", "voxelZ", voxelZ, "number")

    -- Get dial
    return (server.getVehicleDial(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Returns the number of surfaces that are on fire.
]]
---@return integer|nil
function Noir.Classes.Body:GetFireCount()
    -- Get fire count
    return (server.getVehicleFireCount(self.ID))
end

--[[
    Get a hopper's data (by name).
]]
---@param hopperName string
---@return SWVehicleHopperData|nil
function Noir.Classes.Body:GetHopper(hopperName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetHopper()", "hopperName", hopperName, "string")

    -- Get hopper
    return (server.getVehicleHopper(self.ID, hopperName))
end

--[[
    Get a hopper's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleHopperData|nil
function Noir.Classes.Body:GetHopperByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetHopperByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetHopperByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetHopperByVoxel()", "voxelZ", voxelZ, "number")

    -- Get hopper
    return (server.getVehicleHopper(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Get a rope hook's data (by name).
]]
---@param hookName string
---@return SWVehicleRopeHookData|nil
function Noir.Classes.Body:GetRopeHook(hookName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetRopeHook()", "hookName", hookName, "string")

    -- Get rope hook
    return (server.getVehicleRopeHook(self.ID, hookName))
end

--[[
    Get a rope hook's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleRopeHookData|nil
function Noir.Classes.Body:GetRopeHookByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetRopeHookByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetRopeHookByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetRopeHookByVoxel()", "voxelZ", voxelZ, "number")

    -- Get rope hook
    return (server.getVehicleRopeHook(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Get a seat's data (by name).
]]
---@param seatName string
---@return SWVehicleSeatData|nil
function Noir.Classes.Body:GetSeat(seatName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSeat()", "seatName", seatName, "string")

    -- Get seat
    return (server.getVehicleSeat(self.ID, seatName))
end

--[[
    Get a seat's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleSeatData|nil
function Noir.Classes.Body:GetSeatByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSeatByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSeatByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSeatByVoxel()", "voxelZ", voxelZ, "number")

    -- Get seat
    return (server.getVehicleSeat(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Get a sign's data (by name).
]]
---@param signName string
---@return SWVehicleSignData|nil
function Noir.Classes.Body:GetSign(signName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSign()", "signName", signName, "string")

    -- Get sign
    return (server.getVehicleSign(self.ID, signName))
end

--[[
    Get a sign's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleSignData|nil
function Noir.Classes.Body:GetSignByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSignByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSignByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetSignByVoxel()", "voxelZ", voxelZ, "number")

    -- Get sign
    return (server.getVehicleSign(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Get a tank's data (by name).
]]
---@param tankName string
---@return SWVehicleTankData|nil
function Noir.Classes.Body:GetTank(tankName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetTank()", "tankName", tankName, "string")

    -- Get tank
    return (server.getVehicleTank(self.ID, tankName))
end

--[[
    Get a tank's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleTankData|nil
function Noir.Classes.Body:GetTankByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetTankByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetTankByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetTankByVoxel()", "voxelZ", voxelZ, "number")

    -- Get tank
    return (server.getVehicleTank(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Get a weapon's data (by name).
]]
---@param weaponName string
---@return SWVehicleWeaponData|nil
function Noir.Classes.Body:GetWeapon(weaponName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetWeapon()", "weaponName", weaponName, "string")

    -- Get weapon
    return (server.getVehicleWeapon(self.ID, weaponName))
end

--[[
    Get a weapon's data (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@return SWVehicleWeaponData|nil
function Noir.Classes.Body:GetWeaponByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetWeaponByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetWeaponByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:GetWeaponByVoxel()", "voxelZ", voxelZ, "number")

    -- Get weapon
    return (server.getVehicleWeapon(self.ID, voxelX, voxelY, voxelZ))
end

--[[
    Presses a button on this body (by name).
]]
---@param buttonName string
function Noir.Classes.Body:PressButton(buttonName)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:PressButton()", "buttonName", buttonName, "string")

    -- Press button
    server.pressVehicleButton(self.ID, buttonName)
end

--[[
    Presses a button on this body (by voxel).
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
function Noir.Classes.Body:PressButtonByVoxel(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:PressButtonByVoxel()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:PressButtonByVoxel()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:PressButtonByVoxel()", "voxelZ", voxelZ, "number")

    -- Press button
    server.pressVehicleButton(self.ID, voxelX, voxelY, voxelZ)
end

--[[
    Spawns a rope connected by a hook on this body to a hook on another (or this) body.
]]
---@param voxelX integer
---@param voxelY integer
---@param voxelZ integer
---@param targetBody NoirBody|nil nil = this body
---@param targetVoxelX integer
---@param targetVoxelY integer
---@param targetVoxelZ integer
---@param length number
---@param ropeType SWRopeTypeEnum
function Noir.Classes.Body:SpawnRopeHook(voxelX, voxelY, voxelZ, targetBody, targetVoxelX, targetVoxelY, targetVoxelZ, length, ropeType)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "voxelX", voxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "voxelY", voxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "voxelZ", voxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "targetBody", targetBody, Noir.Classes.Body, "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "targetVoxelX", targetVoxelX, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "targetVoxelY", targetVoxelY, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "targetVoxelZ", targetVoxelZ, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "length", length, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Body:SpawnRopeHook()", "ropeType", ropeType, "number")

    -- Spawn rope hook
    server.spawnVehicleRope(
        self.ID,
        voxelX,
        voxelY,
        voxelZ,
        targetBody and targetBody.ID or self.ID,
        targetVoxelX,
        targetVoxelY,
        targetVoxelZ,
        length,
        ropeType
    )
end

--[[
    Despawn the body.
]]
function Noir.Classes.Body:Despawn()
    server.despawnVehicle(self.ID, true)
end

--[[
    Returns whether or not the body exists.
]]
---@return boolean
function Noir.Classes.Body:Exists()
    local _, exists = server.getVehicleSimulating(self.ID)
    return exists
end

--[[
    Returns whether or not the body is simulating.
]]
---@return boolean
function Noir.Classes.Body:IsSimulating()
    local simulating, success = server.getVehicleSimulating(self.ID)
    return simulating and success
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of the NoirBody class.
]]
---@class NoirSerializedBody
---@field ID integer
---@field Owner integer
---@field ParentVehicle integer
---@field Loaded boolean

--------------------------------------------------------
-- [Noir] Classes - Command
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a command.
]]
---@class NoirCommand: NoirClass
---@field New fun(self: NoirCommand, name: string, aliases: table<integer, string>, requiredPermissions: table<integer, string>, requiresAuth: boolean, requiresAdmin: boolean, capsSensitive: boolean, description: string): NoirCommand
---@field Name string The name of this command
---@field Aliases table<integer, string> The aliases of this command
---@field RequiredPermissions table<integer, string> The required permissions for this command. If this is empty, anyone can use this command
---@field RequiresAuth boolean Whether or not this command requires auth
---@field RequiresAdmin boolean Whether or not this command requires admin
---@field CapsSensitive boolean Whether or not this command is case-sensitive
---@field Description string The description of this command
---@field OnUse NoirEvent Arguments: player (NoirPlayer), message (string), args (table<integer, string>), hasPermission (boolean) | Fired when this command is used
Noir.Classes.Command = Noir.Class("Command")

--[[
    Initializes command class objects.
]]
---@param name string
---@param aliases table<integer, string>
---@param requiredPermissions table<integer, string>
---@param requiresAuth boolean
---@param requiresAdmin boolean
---@param capsSensitive boolean
---@param description string
function Noir.Classes.Command:Init(name, aliases, requiredPermissions, requiresAuth, requiresAdmin, capsSensitive, description)
    Noir.TypeChecking:Assert("Noir.Classes.Command:Init()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Command:Init()", "aliases", aliases, "table")
    Noir.TypeChecking:Assert("Noir.Classes.Command:Init()", "requiredPermissions", requiredPermissions, "table")
    Noir.TypeChecking:Assert("Noir.Classes.Command:Init()", "requiresAuth", requiresAuth, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Command:Init()", "requiresAdmin", requiresAdmin, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Command:Init()", "capsSensitive", capsSensitive, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Command:Init()", "description", description, "string")

    self.Name = name
    self.Aliases = aliases
    self.RequiredPermissions = requiredPermissions
    self.RequiresAuth = requiresAuth
    self.RequiresAdmin = requiresAdmin
    self.CapsSensitive = capsSensitive
    self.Description = description

    self.OnUse = Noir.Libraries.Events:Create()
end

--[[
    Trigger this command.<br>
    Used internally. Do not use in your code.
]]
---@param player NoirPlayer
---@param message string
---@param args table
function Noir.Classes.Command:_Use(player, message, args)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Command:_Use()", "player", player, Noir.Classes.Player)
    Noir.TypeChecking:Assert("Noir.Classes.Command:_Use()", "message", message, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Command:_Use()", "args", args, "table")

    -- Fire event
    self.OnUse:Fire(player, message, args, self:CanUse(player))
end

--[[
    Returns whether or not the string matches this command.<br>
    Used internally. Do not use in your code.
]]
---@param query string
---@return boolean
function Noir.Classes.Command:_Matches(query)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Command:_Matches()", "query", query, "string")

    -- Check if the string matches this command's name/aliases
    if not self.CapsSensitive then
        if self.Name:lower() == query:lower() then
            return true
        end

        for _, alias in ipairs(self.Aliases) do
            if alias:lower() == query:lower() then
                return true
            end
        end

        return false
    else
        if self.Name == query then
            return true
        end

        for _, alias in ipairs(self.Aliases) do
            if alias == query then
                return true
            end
        end

        return false
    end
end

--[[
    Returns whether or not the player can use this command.
]]
---@param player NoirPlayer
---@return boolean
function Noir.Classes.Command:CanUse(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Command:CanUse()", "player", player, Noir.Classes.Player)

    -- Check if the player can use this command via auth
    if self.RequiresAuth and not player.Auth then
        return false
    end

    -- Check if the player can use this command via admin
    if self.RequiresAdmin and not player.Admin then
        return false
    end

    -- Check if the player has the required permissions
    for _, permission in ipairs(self.RequiredPermissions) do
        if not player:HasPermission(permission) then
            return false
        end
    end

    -- Woohoo!
    return true
end

--------------------------------------------------------
-- [Noir] Classes - Connection
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a connection to an event.
]]
---@class NoirConnection: NoirClass
---@field New fun(self: NoirConnection, callback: function): NoirConnection
---@field ID integer The ID of this connection
---@field Callback function The callback that is assigned to this connection
---@field ParentEvent NoirEvent The event that this connection is connected to
---@field Connected boolean Whether or not this connection is connected
---@field Index integer The index of this connection in `ParentEvent.ConnectionsOrder`
Noir.Classes.Connection = Noir.Class("Connection")

--[[
    Initializes new connection class objects.
]]
---@param callback function
function Noir.Classes.Connection:Init(callback)
    Noir.TypeChecking:Assert("Noir.Classes.Connection:Init()", "callback", callback, "function")

    self.Callback = callback
    self.ParentEvent = nil
    self.ID = nil
    self.Connected = false
    self.Index = -1
end

--[[
    Triggers the callback's stored function.
]]
---@param ... any
---@return any
function Noir.Classes.Connection:Fire(...)
    if not self.Connected then
        error("Noir.Classes.Connection:Fire()", "Attempted to fire an event connection when it is not connected.")
    end

    return self.Callback(...)
end

--[[
    Disconnects the callback from the event.
]]
function Noir.Classes.Connection:Disconnect()
    if not self.Connected then
        error("Noir.Classes.Connection:Disconnect()", "Attempted to disconnect an event connection when it is not connected.")
    end

    self.ParentEvent:Disconnect(self)
end

--------------------------------------------------------
-- [Noir] Classes - Event
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub), @Avril112113 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents an event.
]]
---@class NoirEvent: NoirClass
---@field New fun(self: NoirEvent): NoirEvent
---@field CurrentID integer The ID that will be passed to new connections. Increments by 1 every connection
---@field Connections table<integer, NoirConnection> The connections that are connected to this event
---@field ConnectionsOrder table<integer, integer> Array of connection IDs into Connections table
---@field ConnectionsToRemove table<integer, NoirConnection> Array of connections to remove after the firing of the event
---@field ConnectionsToAdd table<integer, NoirConnection> Array of connections to add after the firing of the event
---@field IsFiring boolean Weather or not this event is currently calling connection callbacks
---@field HasFiredOnce boolean Whether or not this event has fired atleast once
Noir.Classes.Event = Noir.Class("Event")

--[[
    Initializes event class objects.
]]
function Noir.Classes.Event:Init()
    self.CurrentID = 0
    self.Connections = {}
    self.ConnectionsOrder = {}
    self.ConnectionsToRemove = {}  -- Only used when IsFiring is true, should remain empty otherwise.
    self.ConnectionsToAdd = {}  -- Only used when IsFiring is true, should remain empty otherwise.
    self.IsFiring = false
    self.HasFiredOnce = false
end

--[[
    Fires the event, passing any provided arguments to the connections.

    local event = Noir.Libraries.Events:Create()
    event:Fire()
]]
function Noir.Classes.Event:Fire(...)
    -- Fire the event connections
    self.IsFiring = true

    for _, connection_id in ipairs(self.ConnectionsOrder) do
        local connection = self.Connections[connection_id]
        local result = connection:Fire(...)

        -- Disconnect if prompted
        if result == Noir.Libraries.Events.DismissAction then
            connection:Disconnect()
        end
    end

    self.IsFiring = false

    -- Reverse iteration is more performant, as we are book-keeping stuff we already plan to remove
    for index = #self.ConnectionsToRemove, 1, -1 do
        self:_DisconnectImmediate(self.ConnectionsToRemove[index])
        self.ConnectionsToRemove[index] = nil
    end

    -- Add connections which were connected during iteration, so they get called next time
    for index = 1, #self.ConnectionsToAdd do
        self:_ConnectFinalize(self.ConnectionsToAdd[index])
        self.ConnectionsToAdd[index] = nil
    end

    self.HasFiredOnce = true
end

--[[
    Connects a function to the event. A connection is automatically made for the function.<br>
    If connecting to an event that is currently being handled, it will be added afterwards and run the next time the event is fired.

    local event = Noir.Libraries.Events:Create()

    local connection = event:Connect(function()
        print("Fired")
    end)

    connection:Disconnect() -- Disconnects the callback from the event
]]
---@param callback function
---@return NoirConnection
function Noir.Classes.Event:Connect(callback)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Event:Connect()", "callback", callback, "function")

    -- Increment ID
    self.CurrentID = self.CurrentID + 1

    -- Create connection object
    local connection = Noir.Classes.Connection:New(callback)
    self.Connections[self.CurrentID] = connection

    -- Set up the connection for later
    connection.ParentEvent = self
    connection.ID = self.CurrentID
    connection.Index = -1
    connection.Connected = false

    -- If we are currently iterating over the events, finalize it later, otherwise do it now
    if self.IsFiring then
        table.insert(self.ConnectionsToAdd, connection)
    else
        self:_ConnectFinalize(connection)
    end

    -- Return the connection
    return connection
end

--[[
    Finalizes the connection to the event, allowing it to be run.<br>
    Used internally.
]]
---@param connection NoirConnection
function Noir.Classes.Event:_ConnectFinalize(connection)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Event:_ConnectFinalize()", "connection", connection, Noir.Classes.Connection)

    -- Insert into ConnectionsOrder
    table.insert(self.ConnectionsOrder, connection.ID)

    -- Set up connection
    connection.Index = #self.ConnectionsOrder
    connection.Connected = true
end

--[[
    Connects a callback to the event that will automatically be disconnected upon the event being fired.<br>
    If connecting to an event that is currently being handled, it will be added afterwards and run the next time the event is fired.  
]]
---@param callback function
---@return NoirConnection
function Noir.Classes.Event:Once(callback)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Event:Once()", "callback", callback, "function")

    -- Connect to event
    local connection

    connection = self:Connect(function(...)
        callback(...)
        connection:Disconnect()
    end)

    -- Return the connection
    return connection
end

--[[
    Disconnects the provided connection from the event.<br>
    The disconnection may be delayed if done while handling the event.  
]]
---@param connection NoirConnection
function Noir.Classes.Event:Disconnect(connection)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Event:Disconnect()", "connection", connection, Noir.Classes.Connection)

    -- If we are currently iterating over the events, disconnect it later, otherwise do it now
    if self.IsFiring then
        table.insert(self.ConnectionsToRemove, connection)
    else
        self:_DisconnectImmediate(connection)
    end
end

--[[
    **Should only be used internally.**<br>
    Disconnects the provided connection from the event immediately.  
]]
---@param connection NoirConnection
function Noir.Classes.Event:_DisconnectImmediate(connection)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Event:_DisconnectImmediate()", "connection", connection, Noir.Classes.Connection)

    -- Remove the connection
    self.Connections[connection.ID] = nil
    table.remove(self.ConnectionsOrder, connection.Index)

    -- Re-index the connections by shifting down one
    for index = connection.Index, #self.ConnectionsOrder do
        local _connection = self.Connections[self.ConnectionsOrder[index]]
        _connection.Index = _connection.Index - 1
    end

    -- Update connection attributes
    connection.Connected = false
    connection.ParentEvent = nil
    connection.ID = nil
    connection.Index = nil
end


--------------------------------------------------------
-- [Noir] Classes - HTTP Request
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a HTTP request.
]]
---@class NoirHTTPRequest: NoirClass
---@field New fun(self: NoirHTTPRequest, URL: string, port: integer): NoirHTTPRequest
---@field URL string The URL of the request (eg: "/hello")
---@field Port integer The port of the request
---@field OnResponse NoirEvent Arguments: response (NoirHTTPResponse) | Fired when this request receives a response
Noir.Classes.HTTPRequest = Noir.Class("HTTPRequest")

--[[
    Initializes HTTP request class objects.
]]
---@param URL string
---@param port integer
function Noir.Classes.HTTPRequest:Init(URL, port)
    Noir.TypeChecking:Assert("Noir.Classes.HTTPRequest:Init()", "URL", URL, "string")
    Noir.TypeChecking:Assert("Noir.Classes.HTTPRequest:Init()", "port", port, "number")

    self.URL = URL
    self.Port = port
    self.OnResponse = Noir.Libraries.Events:Create()
end

--------------------------------------------------------
-- [Noir] Classes - HTTP Response
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a response to a HTTP request.
]]
---@class NoirHTTPResponse: NoirClass
---@field New fun(self: NoirHTTPResponse, response: string): NoirHTTPResponse
---@field Text string The raw response.
Noir.Classes.HTTPResponse = Noir.Class("HTTPResponse")

--[[
    Initializes HTTP response class objects.
]]
---@param response string
function Noir.Classes.HTTPResponse:Init(response)
    Noir.TypeChecking:Assert("Noir.Classes.HTTPResponse:Init()", "response", response, "string")
    self.Text = response
end

--[[
    Attempts to JSON decode the response. This will error if the response cannot be JSON decoded.
]]
---@return any
function Noir.Classes.HTTPResponse:JSON()
    return (Noir.Libraries.JSON:Decode(self.Text))
end

--[[
    Returns whether or not the response is ok.
]]
---@return boolean
function Noir.Classes.HTTPResponse:IsOk()
    return Noir.Libraries.HTTP:IsResponseOk(self.Text)
end

--------------------------------------------------------
-- [Noir] Classes - Library
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a library.
]]
---@class NoirLibrary: NoirClass
---@field New fun(self: NoirLibrary, name: string, shortDescription: string, longDescription: string, authors: table<integer, string>): NoirLibrary
---@field Name string The name of the library
---@field ShortDescription string The short description of the library
---@field LongDescription string The long description of the library
---@field Authors table<integer, string> The authors of the library
Noir.Classes.Library = Noir.Class("Library")

--[[
    Initializes library class objects.
]]
---@param name string
---@param shortDescription string
---@param longDescription string
---@param authors table<integer, string>
function Noir.Classes.Library:Init(name, shortDescription, longDescription, authors)
    Noir.TypeChecking:Assert("Noir.Classes.Library:Init()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Library:Init()", "shortDescription", shortDescription, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Library:Init()", "longDescription", longDescription, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Library:Init()", "authors", authors, "table")

    self.Name = name
    self.ShortDescription = shortDescription
    self.LongDescription = longDescription
    self.Authors = authors
end

--------------------------------------------------------
-- [Noir] Classes - Message
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a message.
]]
---@class NoirMessage: NoirClass
---@field New fun(self: NoirMessage, author: NoirPlayer|nil, isAddon: boolean, content: string, title: string, sentAt: number|nil, recipient: NoirPlayer|nil): NoirMessage
---@field Author NoirPlayer|nil The author of the message, or nil if sent by an addon
---@field IsAddon boolean Whether or not the message was sent by an addon
---@field Content string The actual message
---@field Title string If this message wasn't sent by an addon, this will be the author's name
---@field SentAt number Represents when the message was sent
---@field Recipient NoirPlayer|nil Who received the message, nil = everyone
Noir.Classes.Message = Noir.Class("Message")

--[[
    Initializes message class objects.
]]
---@param author NoirPlayer|nil
---@param isAddon boolean
---@param content string
---@param title string
---@param sentAt number|nil
---@param recipient NoirPlayer|nil
function Noir.Classes.Message:Init(author, isAddon, content, title, sentAt, recipient)
    Noir.TypeChecking:Assert("Noir.Classes.Message:Init()", "author", author, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Message:Init()", "isAddon", isAddon, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Message:Init()", "content", content, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Message:Init()", "title", title, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Message:Init()", "sentAt", sentAt, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Message:Init()", "recipient", recipient, Noir.Classes.Player, "nil")

    self.Author = author
    self.IsAddon = isAddon
    self.Content = content
    self.Title = title
    self.SentAt = sentAt or server.getTimeMillisec()
    self.Recipient = recipient
end

--[[
    Serializes the message into a g_savedata-safe format.<br>
    Used internally.
]]
---@return NoirSerializedMessage
function Noir.Classes.Message:_Serialize()
    return {
        Author = self.Author and self.Author.ID,
        IsAddon = self.IsAddon,
        Content = self.Content,
        Title = self.Title,
        SentAt = self.SentAt,
        Recipient = self.Recipient and self.Recipient.ID
    }
end

--[[
    Deserializes the message from a g_savedata-safe format.<br>
    Used internally.
]]
---@param serializedMessage NoirSerializedMessage
function Noir.Classes.Message:_Deserialize(serializedMessage)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Message:_Deserialize()", "serializedMessage", serializedMessage, "table")

    -- Create the message
    local message = self:New(
        serializedMessage.Author and Noir.Services.PlayerService:GetPlayer(serializedMessage.Author),
        serializedMessage.IsAddon,
        serializedMessage.Content,
        serializedMessage.Title,
        serializedMessage.SentAt,
        serializedMessage.Recipient and Noir.Services.PlayerService:GetPlayer(serializedMessage.Recipient)
    )

    -- Return the message
    return message
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of the NoirMessage class.
]]
---@class NoirSerializedMessage
---@field Author integer|nil
---@field IsAddon boolean
---@field Content string
---@field Title string
---@field SentAt number
---@field Recipient integer|nil

--------------------------------------------------------
-- [Noir] Classes - Object
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a Stormworks object.

    object:IsSimulating() -- true
    object:Teleport(matrix.translation(0, 0, 0))
]]
---@class NoirObject: NoirClass
---@field New fun(self: NoirObject, ID: integer): NoirObject
---@field ID integer The ID of this object
---@field Loaded boolean Whether or not this object is loaded
---@field OnLoad NoirEvent Fired when this object is loaded
---@field OnUnload NoirEvent Fired when this object is unloaded
---@field OnUnregister NoirEvent Fired when this object is unregistered from the ObjectService (mostly on despawn)
Noir.Classes.Object = Noir.Class("Object")

--[[
    Initializes object class objects.
]]
---@param ID integer
function Noir.Classes.Object:Init(ID)
    Noir.TypeChecking:Assert("Noir.Classes.Object:Init()", "ID", ID, "number")

    self.ID = math.floor(ID)
    self.Loaded = false

    self.OnLoad = Noir.Libraries.Events:Create()
    self.OnUnload = Noir.Libraries.Events:Create()
    self.OnUnregister = Noir.Libraries.Events:Create()
end

--[[
    Serializes this object into g_savedata format.<br>
    Used internally. Do not use in your code.
]]
---@return NoirSerializedObject
function Noir.Classes.Object:_Serialize()
    return {
        ID = self.ID
    }
end

--[[
    Deserializes this object from g_savedata format.<br>
    Used internally. Do not use in your code.
]]
---@param serializedObject NoirSerializedObject
---@return NoirObject
function Noir.Classes.Object:_Deserialize(serializedObject)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:_Deserialize()", "serializedObject", serializedObject, "table")

    -- Create object from serialized object
    local object = self:New(serializedObject.ID)

    -- Return it
    return object
end

--[[
    Returns the data of this object.
]]
---@return SWObjectData
function Noir.Classes.Object:GetData()
    -- Get the data
    local data = server.getObjectData(self.ID)

    if not data then
        error("Noir.Classes.Object:GetData()", ":GetData() failed for object %d. Data is nil", self.ID)
    end

    -- Return the data
    return data
end

--[[
    Returns whether or not this object is simulating.
]]
---@return boolean
function Noir.Classes.Object:IsSimulating()
    local simulating, success = server.getObjectSimulating(self.ID)
    return simulating and success
end

--[[
    Returns whether or not this object exists.
]]
---@return boolean
function Noir.Classes.Object:Exists()
    local _, exists = server.getObjectSimulating(self.ID)
    return exists
end

--[[
    Despawn this object.
]]
function Noir.Classes.Object:Despawn()
    server.despawnObject(self.ID, true)
    Noir.Services.ObjectService:_RemoveObject(self)
end

--[[
    Get this object's position.
]]
---@return SWMatrix
function Noir.Classes.Object:GetPosition()
    return (server.getObjectPos(self.ID))
end

--[[
    Teleport this object.
]]
---@param position SWMatrix
function Noir.Classes.Object:Teleport(position)
    Noir.TypeChecking:Assert("Noir.Classes.Object:Teleport()", "position", position, "table")
    server.setObjectPos(self.ID, position)
end

--[[
    Revive this character (if character).
]]
function Noir.Classes.Object:Revive()
    server.reviveCharacter(self.ID)
end

--[[
    Set this object's data (if character).
]]
---@param hp number
---@param interactable boolean
---@param AI boolean
function Noir.Classes.Object:SetData(hp, interactable, AI)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetData()", "hp", hp, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetData()", "interactable", interactable, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetData()", "AI", AI, "boolean")

    -- Set data
    server.setCharacterData(self.ID, hp, interactable, AI)
end

--[[
    Returns this character's health (if character).
]]
---@return number
function Noir.Classes.Object:GetHealth()
    return self:GetData().hp
end

--[[
    Set this character's/creature's tooltip (if character or creature).
]]
---@param tooltip string
function Noir.Classes.Object:SetTooltip(tooltip)
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetTooltip()", "tooltip", tooltip, "string")
    server.setCharacterTooltip(self.ID, tooltip)
end

--[[
    Set this character's AI state (if character).
]]
---@param state integer **Ship Pilot**: 0 = none, 1 = path to destination<br>**Heli Pilot**: 0 = None, 1 = path to destination, 2 = path to destination (accurate), 3 = gun run<br>**Plane Pilot**: 0 = none, 1 = path to destination, 2 = gun run<br>**Gunner**: 0 = none, 1 = fire at target<br>**Designator**: 0 = none, 1 = aim at target
function Noir.Classes.Object:SetAIState(state)
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetAIState()", "state", state, "number")
    server.setAIState(self.ID, state)
end

--[[
    Returns this character's AI target (if character).
]]
---@return NoirAITarget|nil
function Noir.Classes.Object:GetAITarget()
    local data = server.getAITarget(self.ID)

    if not data then
        return
    end

    return Noir.Classes.AITarget:New(data)
end

--[[
    Set this character's AI character target (if character).
]]
---@param target NoirObject
function Noir.Classes.Object:SetAICharacterTarget(target)
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetAICharacterTarget()", "target", target, Noir.Classes.Object)
    server.setAITargetCharacter(self.ID, target.ID)
end

--[[
    Set this character's AI body target (if character).
]]
---@param body NoirBody
function Noir.Classes.Object:SetAIBodyTarget(body)
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetAIBodyTarget()", "body", body, Noir.Classes.Body)
    server.setAITargetVehicle(self.ID, body.ID)
end

--[[
    Set this character's AI position target (if character).
]]
---@param position SWMatrix
function Noir.Classes.Object:SetAIPositionTarget(position)
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetAIPositionTarget()", "position", position, "table")
    server.setAITarget(self.ID, position)
end

--[[
    Kills this character (if character).
]]
function Noir.Classes.Object:Kill()
    server.killCharacter(self.ID)
end

--[[
    Returns the vehicle this character is sat in (if character).
]]
---@return NoirBody|nil
function Noir.Classes.Object:GetVehicle()
    -- Get the vehicle ID
    local vehicle_id, success = server.getCharacterVehicle(self.ID)

    if not success then
        return
    end

    -- Get the body
    return Noir.Services.VehicleService:GetBody(vehicle_id)
end

--[[
    Returns the item this character is holding in the specified slot (if character).
]]
---@param slot SWSlotNumberEnum
---@return integer
function Noir.Classes.Object:GetItem(slot)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:GetItem()", "slot", slot, "number")

    -- Get the item
    local item, success = server.getCharacterItem(self.ID, slot)

    if not success then
        error("Noir.Classes.Object:GetItem()", "server.getCharacterItem(...) was unsuccessful. Is the slot out of range? Is this object a character?")
    end

    -- Return it
    return item
end

--[[
    Give this character an item (if character).
]]
---@param slot SWSlotNumberEnum
---@param equipmentID SWEquipmentTypeEnum
---@param isActive boolean|nil
---@param int integer|nil
---@param float number|nil
function Noir.Classes.Object:GiveItem(slot, equipmentID, isActive, int, float)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:GiveItem()", "slot", slot, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Object:GiveItem()", "equipmentID", equipmentID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Object:GiveItem()", "isActive", isActive, "boolean", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Object:GiveItem()", "int", int, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Object:GiveItem()", "float", float, "number", "nil")

    -- Give the item
    server.setCharacterItem(self.ID, slot, equipmentID, isActive or false, int or 0, float or 0)
end

--[[
    Returns whether or not this character is downed (dead, incapaciated, or hp <= 0) (if character).
]]
---@return boolean
function Noir.Classes.Object:IsDowned()
    local data = self:GetData()
    return data.dead or data.incapacitated or data.hp <= 0
end

--[[
    Seat this character in a seat (if character).
]]
---@param body NoirBody
---@param name string|nil
---@param voxelX integer|nil
---@param voxelY integer|nil
---@param voxelZ integer|nil
function Noir.Classes.Object:Seat(body, name, voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:Seat()", "body", body, Noir.Classes.Body)
    Noir.TypeChecking:Assert("Noir.Classes.Object:Seat()", "name", name, "string", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Object:Seat()", "voxelX", voxelX, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Object:Seat()", "voxelY", voxelY, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Object:Seat()", "voxelZ", voxelZ, "number", "nil")

    -- Set seated
    if name then
        server.setSeated(self.ID, body.ID, name)
    elseif voxelX and voxelY and voxelZ then
        server.setSeated(self.ID, body.ID, voxelX, voxelY, voxelZ)
    else
        error("Noir.Classes.Object:Seat()", "Name, or voxelX and voxelY and voxelZ must be provided to NoirObject:Seat().")
    end
end

--[[
    Set the move target of this character (if creature).
]]
---@param position SWMatrix
function Noir.Classes.Object:SetMoveTarget(position)
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetMoveTarget()", "position", position, "table")
    server.setCreatureMoveTarget(self.ID, position)
end

--[[
    Damage this character by a certain amount (if character).
]]
---@param amount number
function Noir.Classes.Object:Damage(amount)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:Damage()", "amount", amount, "number")

    -- Get health
    local health = self:GetHealth()

    -- Damage
    self:SetData(health - amount, false, false)
end

--[[
    Heal this character by a certain amount (if character).
]]
---@param amount number
function Noir.Classes.Object:Heal(amount)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:Heal()", "amount", amount, "number")

    -- Get health
    local health = self:GetHealth()

    -- Prevent soft-lock
    if health <= 0 and amount > 0 then
        self:Revive()
    end

    -- Heal
    self:SetData(health + amount, false, false)
end

--[[
    Returns if this fire is lit (if fire).
]]
---@return boolean
function Noir.Classes.Object:IsLit()
    -- Get fire data
    local isLit, success = server.getFireData(self.ID)

    if not success then
        error("Noir.Classes.Object:IsLit()", "server.getFireData() was unsuccessful.")
    end

    -- Return
    return isLit
end

--[[
    Get this fire's data (if fire).
]]
---@deprecated
---@return boolean
function Noir.Classes.Object:GetFireData()
    Noir.Libraries.Deprecation:Deprecated("Noir.Classes.Object:GetFireData()", "Noir.Classes.Object:IsLit()", "This method will be removed in a future update.")
    return self:IsLit()
end

--[[
    Set this fire's data (if fire).
]]
---@param isLit boolean
---@param isExplosive boolean
function Noir.Classes.Object:SetFireData(isLit, isExplosive)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetFireData()", "isLit", isLit, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Object:SetFireData()", "isExplosive", isExplosive, "boolean")

    -- Set fire data
    server.setFireData(self.ID, isLit, isExplosive)
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents an object class object that has been serialized.
]]
---@class NoirSerializedObject
---@field ID integer The object ID

--------------------------------------------------------
-- [Noir] Classes - Player
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a player.

    local character = player:GetCharacter() -- NoirObject
    character:SetTooltip("A Tooltip")

    player:SetPermission("Awesome")
    player:HasPermission("Awesome") -- true
]]
---@class NoirPlayer: NoirClass
---@field New fun(self: NoirPlayer, name: string, ID: integer, steam: string, admin: boolean, auth: boolean, permissions: table<string, boolean>): NoirPlayer
---@field Name string The name of this player
---@field ID integer The ID of this player
---@field Steam string The Steam ID of this player
---@field Admin boolean Whether or not this player is an admin
---@field Auth boolean Whether or not this player is authed
---@field Permissions table<string, boolean> The permissions this player has
---@field InGame boolean Whether or not this player is in the game. This is set to false when the player leaves
Noir.Classes.Player = Noir.Class("Player")

--[[
    Initializes player class objects.
]]
---@param name string
---@param ID integer
---@param steam string
---@param admin boolean
---@param auth boolean
---@param permissions table<string, boolean>
function Noir.Classes.Player:Init(name, ID, steam, admin, auth, permissions)
    Noir.TypeChecking:Assert("Noir.Classes.Player:Init()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Player:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Player:Init()", "steam", steam, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Player:Init()", "admin", admin, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Player:Init()", "auth", auth, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Player:Init()", "permissions", permissions, "table")

    self.Name = name
    self.ID = math.floor(ID)
    self.Steam = steam
    self.Admin = admin
    self.Auth = auth
    self.Permissions = permissions
    self.InGame = true
end

--[[
    Give this player a permission.
]]
---@param permission string
function Noir.Classes.Player:SetPermission(permission)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Player:SetPermission()", "permission", permission, "string")

    -- Set permission
    self.Permissions[permission] = true

    -- Save changes
    Noir.Services.PlayerService:_SaveProperty(self, "Permissions")
end

--[[
    Returns whether or not this player has a permission.
]]
---@param permission string
---@return boolean
function Noir.Classes.Player:HasPermission(permission)
    Noir.TypeChecking:Assert("Noir.Classes.Player:HasPermission()", "permission", permission, "string")
    return self.Permissions[permission] ~= nil
end

--[[
    Remove a permission from this player.
]]
---@param permission string
function Noir.Classes.Player:RemovePermission(permission)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Player:RemovePermission()", "permission", permission, "string")

    -- Remove permission
    self.Permissions[permission] = nil

    -- Save changes
    Noir.Services.PlayerService:_SaveProperty(self, "Permissions")
end

--[[
    Returns a table containing the player's permissions.
]]
---@return table<integer, string>
function Noir.Classes.Player:GetPermissions()
    return Noir.Libraries.Table:Keys(self.Permissions)
end

--[[
    Sets whether or not this player is authed.
]]
---@param auth boolean
function Noir.Classes.Player:SetAuth(auth)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Player:SetAuth()", "auth", auth, "boolean")

    -- Add/remove auth
    if auth then
        server.addAuth(self.ID)
    else
        server.removeAuth(self.ID)
    end

    self.Auth = auth
end

--[[
    Sets whether or not this player is an admin.
]]
---@param admin boolean
function Noir.Classes.Player:SetAdmin(admin)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Player:SetAdmin()", "admin", admin, "boolean")

    -- Add/remove admin
    if admin then
        server.addAdmin(self.ID)
    else
        server.removeAdmin(self.ID)
    end

    self.Admin = admin
end

--[[
    Kicks this player.
]]
function Noir.Classes.Player:Kick()
    server.kickPlayer(self.ID)
end

--[[
    Bans this player.
]]
function Noir.Classes.Player:Ban()
    server.banPlayer(self.ID)
end

--[[
    Teleports this player.
]]
---@param pos SWMatrix
function Noir.Classes.Player:Teleport(pos)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Player:Teleport()", "pos", pos, "table")

    -- Teleport the player
    server.setPlayerPos(self.ID, pos)
end

--[[
    Returns this player's position.
]]
---@return SWMatrix
function Noir.Classes.Player:GetPosition()
    local pos, success = server.getPlayerPos(self.ID)

    if not success then
        return matrix.translation(0, 0 ,0)
    end

    return pos
end

--[[
    Set the player's audio mood.
]]
---@param mood SWAudioMoodEnum
function Noir.Classes.Player:SetAudioMood(mood)
    Noir.TypeChecking:Assert("Noir.Classes.Player:SetAudioMood()", "mood", mood, "number")
    server.setAudioMood(self.ID, mood)
end

--[[
    Returns this player's character as a NoirObject.
]]
---@return NoirObject
function Noir.Classes.Player:GetCharacter()
    -- Get the character
    local character = server.getPlayerCharacterID(self.ID)

    if not character then
        error("Noir.Classes.Player:GetCharacter()", "server.getPlayerCharacterID() returned nil")
    end

    -- Return character
    local object = Noir.Services.ObjectService:GetObject(character)
    return object
end

--[[
    Returns this player's look direction.
]]
---@return number LookX
---@return number LookY
---@return number LookZ
function Noir.Classes.Player:GetLook()
    local x, y, z, success = server.getPlayerLookDirection(self.ID)

    if not success then
        return 0, 0, 0
    end

    return x, y, z
end

--[[
    Send this player a notification.
]]
---@param title string
---@param message string
---@param notificationType SWNotificationTypeEnum
function Noir.Classes.Player:Notify(title, message, notificationType)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Player:Notify()", "title", title, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Player:Notify()", "message", message, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Player:Notify()", "notificationType", notificationType, "number")

    -- Send notification
    server.notify(self.ID, title, message, notificationType)
end

--------------------------------------------------------
-- [Noir] Classes - Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a Noir service.
]]
---@class NoirService: NoirClass
---@field New fun(self: NoirService, name: string, isBuiltIn: boolean, shortDescription: string, longDescription: string, authors: table<integer, string>): NoirService
---@field Name string The name of this service
---@field IsBuiltIn boolean Whether or not this service comes with Noir
---@field Initialized boolean Whether or not this service has been initialized
---@field Started boolean Whether or not this service has been started
---@field InitPriority integer The priority of this service when it is initialized
---@field StartPriority integer The priority of this service when it is started
---@field ShortDescription string A short description of this service
---@field LongDescription string A long description of this service
---@field Authors table<integer, string> The authors of this service
---
---@field ServiceInit fun(self: NoirService) A method that is called when the service is initialized
---@field ServiceStart fun(self: NoirService) A method that is called when the service is started
Noir.Classes.Service = Noir.Class("Service")

--[[
    Initializes service class objects.
]]
---@param name string
---@param isBuiltIn boolean
---@param shortDescription string
---@param longDescription string
---@param authors table<integer, string>
function Noir.Classes.Service:Init(name, isBuiltIn, shortDescription, longDescription, authors)
    Noir.TypeChecking:Assert("Noir.Classes.Service:Init()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Service:Init()", "isBuiltIn", isBuiltIn, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Service:Init()", "shortDescription", shortDescription, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Service:Init()", "longDescription", longDescription, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Service:Init()", "authors", authors, "table")

    self.Name = name
    self.IsBuiltIn = isBuiltIn
    self.Initialized = false
    self.Started = false

    self.InitPriority = nil
    self.StartPriority = nil

    self.ShortDescription = shortDescription
    self.LongDescription = longDescription
    self.Authors = authors
end

--[[
    Initialize this service.<br>
    Used internally.
]]
function Noir.Classes.Service:_Initialize()
    -- Checks
    if self.Initialized then
        error("Noir.Classes.Service:_Initialize()", "%s: Attempted to initialize this service when it has already initialized.", self.Name)
    end

    -- Set initialized
    self.Initialized = true

    -- Call ServiceInit
    if not self.ServiceInit then
        return
    end

    self:ServiceInit()
end

--[[
    Start this service.<br>
    Used internally.
]]
function Noir.Classes.Service:_Start()
    -- Checks
    if self.Started then
        error("Noir.Classes.Service:_Start()", "%s: Attempted to start this service when it has already started.", self.Name)
        return
    end

    if not self.Initialized then
        error("Noir.Classes.Service:_Start()", "%s: Attempted to start this service when it has not initialized yet.", self.Name)
        return
    end

    -- Set started
    self.Started = true

    -- Call ServiceStart
    if not self.ServiceStart then
        return
    end

    self:ServiceStart()
end

--[[
    Checks if g_savedata is intact.<br>
    Used internally.
]]
function Noir.Classes.Service:_CheckSaveData()
    -- Checks
    if not g_savedata then
        error("Noir.Classes.Service:_CheckSaveData()", "g_savedata doesn't exist.")
    end

    if not g_savedata.Noir then
        error("Noir.Classes.Service:_CheckSaveData()", "g_savedata.Noir doesn't exist.")
    end

    if not g_savedata.Noir.Services then
        error("Noir.Classes.Service:_CheckSaveData()", "g_savedata.Noir.Services doesn't exist.")
    end

    if not g_savedata.Noir.Services[self.Name] then
        g_savedata.Noir.Services[self.Name] = {}
    end
end

--[[
    Save a value to g_savedata under this service.

    local MyService = Noir.Services:CreateService("MyService")

    function MyService:ServiceInit()
        self:Save("MyKey", "MyValue")
    end
]]
---@param index string
---@param data any
function Noir.Classes.Service:Save(index, data)
    Noir.TypeChecking:Assert("Noir.Classes.Service:Save()", "index", index, "string")
    self:GetSaveData()[index] = data
end

--[[
    Load data from this service's g_savedata entry that was saved via the :Save() method.

    local MyService = Noir.Services:CreateService("MyService")

    function MyService:ServiceInit()
        local MyValue = self:Load("MyKey")
    end
]]
---@param index string
---@param default any
---@return any
function Noir.Classes.Service:Load(index, default)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Service:Load()", "index", index, "string")

    -- Get the value
    local value = self:GetSaveData()[index]

    -- Return the default if it's nil
    if value == nil then
        return default
    end

    -- Return the value
    return value
end

--[[
    Similar to `:Load()`, this method loads a value from this service's g_savedata entry.<br>
    However, if the value doesn't exist, the default value provided to this method is saved then returned.

    local MyService = Noir.Services:CreateService("MyService")

    function MyService:ServiceInit()
        local MyValue = self:EnsuredLoad("MyKey", "MyDefault")
    end
]]
---@param index string
---@param default any
---@return any
function Noir.Classes.Service:EnsuredLoad(index, default)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Service:EnsuredLoad()", "index", index, "string")

    -- Get the value
    local value = self:Load(index)

    -- If the value doesn't exist, save default and return default
    if value == nil then
        self:Save(index, default)
        return default
    end

    -- Return the value
    return value
end

--[[
    Remove data from this service's g_savedata entry that was saved.

    local MyService = Noir.Services:CreateService("MyService")

    function MyService:ServiceInit()
        MyService:Remove("MyKey")
    end
]]
---@param index string
function Noir.Classes.Service:Remove(index)
    Noir.TypeChecking:Assert("Noir.Classes.Service:Remove()", "index", index, "string")
    self:GetSaveData()[index] = nil
end

--[[
    Returns this service's g_savedata table for direct modification.<br>

    local MyService = Noir.Services:CreateService("MyService")

    function MyService:ServiceInit()
        self:GetSaveData().MyKey = "MyValue"
        -- Equivalent to: self:Save("MyKey", "MyValue")
    end
]]
---@return table
function Noir.Classes.Service:GetSaveData()
    -- Check g_savedata
    self:_CheckSaveData()

    -- Return
    return g_savedata.Noir.Services[self.Name]
end

--------------------------------------------------------
-- [Noir] Classes - Task
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a task.

    task:SetRepeating(true)
    task:SetDuration(1)

    task.OnCompletion:Connect(function()
        -- Do something
    end)
]]
---@class NoirTask: NoirClass
---@field New fun(self: NoirTask, ID: integer, taskType: NoirTaskType, duration: number, isRepeating: boolean, arguments: table<integer, any>, startedAt: number): NoirTask
---@field ID integer The ID of this task
---@field TaskType NoirTaskType The type of this task
---@field StartedAt number The point that this task started at
---@field Duration number The duration of this task
---@field StopsAt number The point that this task will stop at if it is not repeating
---@field IsRepeating boolean Whether or not this task is repeating
---@field Arguments table<integer, any> The arguments that will be passed to this task upon completion
---@field OnCompletion NoirEvent The event that will be fired when this task is completed
Noir.Classes.Task = Noir.Class("Task")

--[[
    Initializes task class objects.
]]
---@param ID integer
---@param taskType NoirTaskType
---@param duration number
---@param isRepeating boolean
---@param arguments table<integer, any>
---@param startedAt number
function Noir.Classes.Task:Init(ID, taskType, duration, isRepeating, arguments, startedAt)
    Noir.TypeChecking:Assert("Noir.Classes.Task:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Task:Init()", "taskType", taskType, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Task:Init()", "duration", duration, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Task:Init()", "isRepeating", isRepeating, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Task:Init()", "arguments", arguments, "table")
    Noir.TypeChecking:Assert("Noir.Classes.Task:Init()", "startedAt", startedAt, "number", "nil")

    self.ID = ID
    self.TaskType = taskType
    self.StartedAt = startedAt

    self:SetDuration(duration)
    self:SetRepeating(isRepeating)
    self:SetArguments(arguments)

    self.OnCompletion = Noir.Libraries.Events:Create()
end

    --[[
]]

--[[
    Sets whether or not this task is repeating.<br>
    If repeating, the task will be triggered repeatedly as implied.<br>
    If not, the task will be triggered once, then removed from the TaskService.
]]
---@param isRepeating boolean
function Noir.Classes.Task:SetRepeating(isRepeating)
    Noir.TypeChecking:Assert("Noir.Classes.Task:SetRepeating()", "isRepeating", isRepeating, "boolean")
    self.IsRepeating = isRepeating
end

--[[
    Sets the duration of this task.
]]
---@param duration number
function Noir.Classes.Task:SetDuration(duration)
    Noir.TypeChecking:Assert("Noir.Classes.Task:SetDuration()", "duration", duration, "number")

    self.Duration = duration
    self.StopsAt = self.StartedAt + duration
end

--[[
    Sets the arguments that will be passed to this task upon finishing.
]]
---@param arguments table<integer, any>
function Noir.Classes.Task:SetArguments(arguments)
    Noir.TypeChecking:Assert("Noir.Classes.Task:SetArguments()", "arguments", arguments, "table")
    self.Arguments = arguments
end

--[[
    Remove this task from the task service.
]]
function Noir.Classes.Task:Remove()
    Noir.Services.TaskService:RemoveTask(self)
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a task type.
]]
---@alias NoirTaskType
---| "Time" The task will use `server.getTimeMillisec()`
---| "Ticks" The task will count ticks in `onTick` while considering the amount of ticks passed in a single tick

--------------------------------------------------------
-- [Noir] Classes - Tick Iteration Process
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a process in which code iterates through a table in chunks of x over how ever many necessary ticks.
]]
---@class NoirTickIterationProcess: NoirClass
---@field New fun(self: NoirTickIterationProcess, ID: number, tbl: table, chunkSize: integer): NoirTickIterationProcess
---@field ID integer The ID of this process
---@field IterationEvent NoirEvent Arguments: value (any), tick (integer), completed (boolean) | Fired when an iteration during a tick is occuring
---@field ChunkSize integer The number of values to iterate through per tick
---@field TableToIterate table The table to iterate through across ticks
---@field CurrentTick integer Represents the current tick the iteration is at
---@field Completed boolean Whether or not the iteration is completed
---@field _PreviousIndex any The last index used in iteration
Noir.Classes.TickIterationProcess = Noir.Class("TickIterationProcess")

--[[
    Initializes tick iteration process class objects.
]]
---@param ID integer
---@param tbl table
---@param chunkSize integer
function Noir.Classes.TickIterationProcess:Init(ID, tbl, chunkSize)
    Noir.TypeChecking:Assert("Noir.Classes.TickIterationProcess:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.TickIterationProcess:Init()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Classes.TickIterationProcess:Init()", "chunkSize", chunkSize, "number")

    self.ID = ID
    self.IterationEvent = Noir.Libraries.Events:Create()
    self.ChunkSize = chunkSize
    self.TableToIterate = tbl
    self.CurrentTick = 0
    self.Completed = false
    self._PreviousIndex = nil
end

--[[
    Iterate through the table in chunks of x over how ever many necessary ticks.
]]
---@return boolean completed
function Noir.Classes.TickIterationProcess:Iterate()
    -- Increment the current tick
    self.CurrentTick = self.CurrentTick + 1

    -- Iterate 
    for _ = 1, self.ChunkSize do
        -- Get next index and value
        local index, value = next(self.TableToIterate, self._PreviousIndex)

        -- Nil check. This should never evaluate to true
        if index == nil then
            break
        end

        -- Set completed
        local completed = (next(self.TableToIterate, index) == nil)
        self.Completed = completed

        -- Set index
        self._PreviousIndex = index

        -- Fire event
        self.IterationEvent:Fire(index, value, self.CurrentTick, completed)

        -- Break if completed
        if completed then
            break
        end
    end

    -- Return
    return self.Completed
end

--------------------------------------------------------
-- [Noir] Classes - Tracker
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a tracker assigned to a function via `Noir.Debugging`.
]]
---@class NoirTracker: NoirClass
---@field New fun(self: NoirTracker, name: string, func: function): NoirTracker
---@field FunctionName string The name of the function provided
---@field Function function The original unmodified function
---@field CallCount integer The number of times the function has been called
---@field ExecutionTimes table<integer, integer> A table containing the execution time of each function call in milliseconds
---@field AverageExecutionTime number The average execution time of the function
---@field _TimeBeforeCall number The time before the function was called via server.getTimeMillisec()
---@field _ModifiedFunction function The unmodified function but wrapped with debug code
Noir.Classes.Tracker = Noir.Class("Tracker")

--[[
    Initializes class objects from this class.
]]
---@param name string
---@param func function
function Noir.Classes.Tracker:Init(name, func)
    Noir.TypeChecking:Assert("Noir.Classes.Tracker:Init()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Tracker:Init()", "func", func, "function")

    self.FunctionName = name
    self.Function = func
    self.CallCount = 0
    self.ExecutionTimes = {}
    self.AverageExecutionTime = 0

    self._TimeBeforeCall = 0

    self._ModifiedFunction = function(...)
        self:_BeforeCall(...)
        local returns = {self.Function(...)}
        self:_AfterCall(...)

        return table.unpack(returns)
    end
end

--[[
    Method called when the unmodified function is about to be called.<br>
    Used internally.
]]
function Noir.Classes.Tracker:_BeforeCall(...)
    self._TimeBeforeCall = server.getTimeMillisec()
end

--[[
    Method called after the unmodified function has been called.<br>
    Used internally.
]]
function Noir.Classes.Tracker:_AfterCall(...)
    -- Increment call count
    self.CallCount = self.CallCount + 1

    -- Add execution time
    if #self.ExecutionTimes >= 10 then
        table.remove(self.ExecutionTimes, 1)
    end

    table.insert(self.ExecutionTimes, server.getTimeMillisec() - self._TimeBeforeCall)

    -- Calculate average execution time
    self.AverageExecutionTime = Noir.Libraries.Number:Average(self.ExecutionTimes)
end

--[[
    Formats this tracker into a string.
]]
---@return string
function Noir.Classes.Tracker:ToFormattedString()
    return ("%s() | Avg. Exc. Time: %.4f ms, Last Exc. Time: %.4fms, Call Count: %d"):format(
        self:GetName(),
        self:GetAverageExecutionTime(),
        self:GetLastExecutionTime(),
        self:GetCallCount()
    )
end

--[[
    Returns the modified function.
    
    local tracker = Noir.Services.DebuggerService:TrackFunction("myFunction", myFunction)
    myFunction = tracker:Mount()
]]
---@return function
function Noir.Classes.Tracker:Mount()
    return self._ModifiedFunction
end

--[[
    Returns the name of the function.
]]
---@return string
function Noir.Classes.Tracker:GetName()
    return self.FunctionName
end

--[[
    Returns the average execution time of the function.
]]
---@return number
function Noir.Classes.Tracker:GetAverageExecutionTime()
    return self.AverageExecutionTime
end

--[[
    Returns the last execution time of the function.
]]
---@return number
function Noir.Classes.Tracker:GetLastExecutionTime()
    return self.ExecutionTimes[#self.ExecutionTimes] or 0
end

--[[
    Returns the amount of times this function has been called.
]]
---@return number
function Noir.Classes.Tracker:GetCallCount()
    return self.CallCount
end

--------------------------------------------------------
-- [Noir] Classes - Vehicle
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a vehicle.<br>
    In Stormworks, this is actually a vehicle group.
]]
---@class NoirVehicle: NoirClass
---@field New fun(self: NoirVehicle, ID: integer, owner: NoirPlayer|nil, spawnPosition: SWMatrix, cost: number): NoirVehicle
---@field ID integer The ID of this vehicle
---@field Owner NoirPlayer|nil The owner of this vehicle, or nil if spawned by an addon OR if the player who owns the vehicle left before Noir starts again (eg: after save load or addon reload)
---@field SpawnPosition SWMatrix The position this vehicle was spawned at
---@field Cost number The cost of this vehicle
---@field Bodies table<integer, NoirBody> A table of all of the the bodies apart of this vehicle
---@field PrimaryBody NoirBody|nil This will be nil if there are no bodies (occurs when the vehicle is despawned)
---@field Spawned boolean Whether or not this vehicle is spawned. This is set to false when the vehicle is despawned
---@field OnDespawn NoirEvent Fired when this vehicle is despawned
Noir.Classes.Vehicle = Noir.Class("Vehicle")

--[[
    Initializes vehicle class objects.
]]
---@param ID any
---@param owner NoirPlayer|nil
---@param spawnPosition SWMatrix
---@param cost number
function Noir.Classes.Vehicle:Init(ID, owner, spawnPosition, cost)
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:Init()", "owner", owner, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:Init()", "spawnPosition", spawnPosition, "table")
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:Init()", "cost", cost, "number")

    self.ID = math.floor(ID)
    self.Owner = owner
    self.SpawnPosition = spawnPosition
    self.Cost = cost
    self.Bodies = {}
    self.PrimaryBody = nil
    self.Spawned = true

    self.OnDespawn = Noir.Libraries.Events:Create()
end

--[[
    Serialize the vehicle.<br>
    Used internally.
]]
---@return NoirSerializedVehicle
function Noir.Classes.Vehicle:_Serialize()
    local bodies = {}

    for _, body in pairs(self.Bodies) do
        table.insert(bodies, body.ID)
    end

    return {
        ID = self.ID,
        Owner = self.Owner and self.Owner.ID,
        SpawnPosition = self.SpawnPosition,
        Cost = self.Cost,
        Bodies = bodies
    }
end

--[[
    Deserialize a serialized vehicle.<br>
]]
---@param serializedVehicle NoirSerializedVehicle
---@param addBodies boolean|nil
---@return NoirVehicle
function Noir.Classes.Vehicle:_Deserialize(serializedVehicle, addBodies)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:_Deserialize()", "serializedVehicle", serializedVehicle, "table")
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:_Deserialize()", "addBodies", addBodies, "boolean", "nil")

    -- Deserialize
    local vehicle = self:New(
        serializedVehicle.ID,
        serializedVehicle.Owner and Noir.Services.PlayerService:GetPlayer(serializedVehicle.Owner),
        serializedVehicle.SpawnPosition,
        serializedVehicle.Cost
    )

    if addBodies then
        for _, bodyID in pairs(serializedVehicle.Bodies) do
            local body = Noir.Services.VehicleService:GetBody(bodyID)

            if not body then
                goto continue
            end

            vehicle:_AddBody(body)

            ::continue::
        end
    end

    -- Return
    return vehicle
end

--[[
    Calculate the primary body.<br>
    Used internally.
]]
function Noir.Classes.Vehicle:_CalculatePrimaryBody()
    local previousBody, previousID

    for _, body in pairs(self.Bodies) do
        if not previousBody then
            previousBody, previousID = body, body.ID
            goto continue
        end

        if body.ID < previousID then
            previousBody, previousID = body, body.ID
        end

        ::continue::
    end

    self.PrimaryBody = previousBody
end

--[[
    Add a body to the vehicle.<br>
    Used internally.
]]
---@param body NoirBody
function Noir.Classes.Vehicle:_AddBody(body)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:_AddBody()", "body", body, Noir.Classes.Body)

    -- Add body
    self.Bodies[body.ID] = body
    body.ParentVehicle = self

    -- Recalculate primary body
    self:_CalculatePrimaryBody()
end

--[[
    Remove a body from the vehicle.<br>
    Used internally.
]]
---@param body NoirBody
function Noir.Classes.Vehicle:_RemoveBody(body)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:_RemoveBody()", "body", body, Noir.Classes.Body)

    -- Remove body
    self.Bodies[body.ID] = nil
    body.ParentVehicle = nil

    -- Recalculate primary body
    self:_CalculatePrimaryBody()
end

--[[
    Return this vehicle's position.<br>
    Uses the vehicle's primary body internally.
]]
---@param voxelX integer|nil
---@param voxelY integer|nil
---@param voxelZ integer|nil
---@return SWMatrix
function Noir.Classes.Vehicle:GetPosition(voxelX, voxelY, voxelZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:GetPosition()", "voxelX", voxelX, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:GetPosition()", "voxelY", voxelY, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:GetPosition()", "voxelZ", voxelZ, "number", "nil")

    -- Get and return position
    return self.PrimaryBody and self.PrimaryBody:GetPosition(voxelX, voxelY, voxelZ) or matrix.translation(0, 0, 0)
end

--[[
    Get a child body by its ID.
]]
---@param ID integer
---@return NoirBody|nil
function Noir.Classes.Vehicle:GetBody(ID)
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:GetBody()", "ID", ID, "number")
    return self.Bodies[ID]
end

--[[
    Teleport the vehicle to a new position.
]]
---@param position SWMatrix
function Noir.Classes.Vehicle:Teleport(position)
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:Teleport()", "position", position, "table")
    server.setGroupPos(self.ID, position)
end

--[[
    Move the vehicle to a new position, essentially teleports without reloading the vehicle.<br>
    Note that rotation is ignored.
]]
---@param position SWMatrix
function Noir.Classes.Vehicle:Move(position)
    Noir.TypeChecking:Assert("Noir.Classes.Vehicle:Move()", "position", position, "table")
    server.moveGroup(self.ID, position)
end

--[[
    Despawn the vehicle.
]]
function Noir.Classes.Vehicle:Despawn()
    server.despawnVehicleGroup(self.ID, true)
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of the NoirVehicle class.
]]
---@class NoirSerializedVehicle
---@field ID integer The ID of this vehicle
---@field Owner integer The peer ID of the owner of this vehicle, or -1 if addon vehicle
---@field SpawnPosition SWMatrix The position this vehicle was spawned at
---@field Cost number The cost of this vehicle
---@field Bodies table<integer, integer> A table containing the IDs of this vehicle's bodies

--------------------------------------------------------
-- [Noir] Classes - Widget
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a UI widget for the UI service.
]]
---@class NoirWidget: NoirClass
---@field New fun(self: NoirWidget, ID: integer, visible: boolean, widgetType: NoirWidgetType, player: NoirPlayer|nil): NoirWidget
---@field ID integer The Stormworks UI ID of this widget
---@field Visible boolean Whether or not this widget is visible
---@field WidgetType NoirWidgetType The type of this widget (eg: "MapObject")
---@field Player NoirPlayer|nil The player that this widget is attached to. If nil, all players can see this UI
Noir.Classes.Widget = Noir.Class("Widget")

--[[
    Initializes class objects from this class.
]]
---@param ID integer
---@param visible boolean
---@param widgetType NoirWidgetType
---@param player NoirPlayer|nil
function Noir.Classes.Widget:Init(ID, visible, widgetType, player)
    Noir.TypeChecking:Assert("Noir.Classes.Widget:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.Widget:Init()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.Widget:Init()", "widgetType", widgetType, "string")
    Noir.TypeChecking:Assert("Noir.Classes.Widget:Init()", "player", player, Noir.Classes.Player, "nil")

    self.ID = ID
    self.Visible = visible
    self.WidgetType = widgetType
    self.Player = player
end

--[[
    Serializes this widget.
]]
---@return NoirSerializedWidget
function Noir.Classes.Widget:Serialize()
    return Noir.Libraries.Table:ForceMerge({
        ID = self.ID,
        Visible = self.Visible,
        WidgetType = self.WidgetType,
        Player = self.Player and self.Player.ID or -1
    }, self:_Serialize())
end

--[[
    Serializes this widget.<br>
    *abstract method*
]]
---@return NoirSerializedWidget
function Noir.Classes.Widget:_Serialize() ---@diagnostic disable-next-line missing-return
    error("Noir.Classes.Widget:_Serialize()", "This method is abstract and must be overridden.")
end

--[[
    Deserializes a serialized widget.<br>
    *abstract method*<br>
    *static method*
]]
---@param serializedWidget NoirSerializedWidget
---@return NoirWidget|nil
function Noir.Classes.Widget:Deserialize(serializedWidget)
    error("Noir.Classes.Widget:Deserialize()", "This method is abstract and must be overridden.")
end

--[[
    Updates this widget.
]]
function Noir.Classes.Widget:Update()
    if self.Player then
        self:_Destroy(self.Player) -- destroy old version. prevents duplication
        self:_Update(self.Player)
    else
        for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
            self:_Destroy(player)
            self:_Update(player)
        end
    end

    if self:Exists() then
        Noir.Services.UIService:_SaveWidget(self)
    end
end

--[[
    Updates this widget.<br>
    *abstract method*
]]
---@param player NoirPlayer
function Noir.Classes.Widget:_Update(player)
    error("Noir.Classes.Widget:Update()", "This method is abstract and must be overridden.")
end

--[[
    Destroys this widget.
]]
function Noir.Classes.Widget:Destroy()
    if self.Player then
        self:_Destroy(self.Player)
    else
        for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
            self:_Destroy(player)
        end
    end
end

--[[
    Destroys this widget.<br>
    *abstract method*
]]
---@param player NoirPlayer
function Noir.Classes.Widget:_Destroy(player)
    error("Noir.Classes.Widget:_Destroy()", "This method is abstract and must be overridden.")
end

--[[
    Returns if this widget still exists within the UIService.
]]
---@return boolean
function Noir.Classes.Widget:Exists()
    return Noir.Services.UIService:GetWidget(self.ID) ~= nil
end

--[[
    Removes this widget from the UIService and from the game.
]]
function Noir.Classes.Widget:Remove()
    Noir.Services.UIService:RemoveWidget(self.ID)
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of a widget.
]]
---@class NoirSerializedWidget
---@field ID integer The Stormworks UI ID of this widget
---@field Visible boolean Whether or not this widget is visible
---@field WidgetType NoirWidgetType The type of this widget (eg: "MapObject")
---@field Player integer The peer ID of the player that this widget is attached to, or -1 if for everyone

--[[
    Represents a widget type.
]]
---@alias NoirWidgetType
---| "MapObject" # A map object widget
---| "MapLabel" # A map label widget
---| "MapLine" # A map line widget
---| "ScreenPopup" # A screen popup widget
---| "Popup" # A popup widget in 3D space

--------------------------------------------------------
-- [Noir] Classes - Map Label Widget
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a map label UI widget to be shown to players via UIService.
]]
---@class NoirMapLabelWidget: NoirWidget
---@field New fun(self: NoirMapLabelWidget, ID: integer, visible: boolean, text: string, labelType: SWLabelTypeEnum, position: SWMatrix, player: NoirPlayer|nil): NoirMapLabelWidget
---@field Text string The text of this label
---@field LabelType SWLabelTypeEnum The label type to use (changes the icon)
---@field Position SWMatrix The position the map label should be shown on the map at
Noir.Classes.MapLabelWidget = Noir.Class("MapLabelWidget", Noir.Classes.Widget)

--[[
    Initializes class objects from this class.
]]
---@param ID integer
---@param visible boolean
---@param text string
---@param labelType SWLabelTypeEnum
---@param position SWMatrix
---@param player NoirPlayer|nil
function Noir.Classes.MapLabelWidget:Init(ID, visible, text, labelType, position, player)
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:Init()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:Init()", "labelType", labelType, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:Init()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:Init()", "player", player, Noir.Classes.Player, "nil")

    self:InitFrom(
        Noir.Classes.Widget,
        ID,
        visible,
        "MapLabel",
        player
    )

    self.Text = text
    self.LabelType = labelType
    self.Position = position
end

--[[
    Serializes this map label widget.
]]
---@return NoirSerializedMapLabelWidget
function Noir.Classes.MapLabelWidget:_Serialize() ---@diagnostic disable-next-line missing-return
    return {
        Text = self.Text,
        LabelType = self.LabelType,
        Position = self.Position
    }
end

--[[
    Deserializes a map label widget.
]]
---@param serializedWidget NoirSerializedMapLabelWidget
---@return NoirMapLabelWidget|nil
function Noir.Classes.MapLabelWidget:Deserialize(serializedWidget)
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:Deserialize()", "serializedWidget", serializedWidget, "table")

    return self:New(
        serializedWidget.ID,
        serializedWidget.Visible,
        serializedWidget.Text,
        serializedWidget.LabelType,
        serializedWidget.Position,
        Noir.Services.UIService:_GetSerializedPlayer(serializedWidget.Player)
    )
end

--[[
    Handles updating this widget.
]]
---@param player NoirPlayer
function Noir.Classes.MapLabelWidget:_Update(player)
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:_Update()", "player", player, Noir.Classes.Player)

    server.addMapLabel(
        player.ID,
        self.ID,
        self.LabelType,
        self.Text,
        self.Position[13],
        self.Position[15]
    )
end

--[[
    Handles destroying this widget.
]]
---@param player NoirPlayer
function Noir.Classes.MapLabelWidget:_Destroy(player)
    Noir.TypeChecking:Assert("Noir.Classes.MapLabelWidget:_Destroy()", "player", player, Noir.Classes.Player)
    server.removeMapLabel(player.ID, self.ID)
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of a map label widget.
]]
---@class NoirSerializedMapLabelWidget: NoirSerializedWidget
---@field Text string The text of this label
---@field LabelType SWLabelTypeEnum The label type to use (changes the icon)
---@field Position SWMatrix The position the map label should be shown on the map at

--------------------------------------------------------
-- [Noir] Classes - Map Object Widget
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a map object UI widget to be shown to players via UIService.
]]
---@class NoirMapObjectWidget: NoirWidget
---@field New fun(self: NoirMapObjectWidget, ID: integer, visible: boolean, title: string, text: string, objectType: SWMarkerTypeEnum, position: SWMatrix, radius: number, colorR: number, colorG: number, colorB: number, colorA: number, player: NoirPlayer|nil): NoirMapObjectWidget
---@field Title string The title of this map object
---@field Text string The text of this map object
---@field ObjectType SWMarkerTypeEnum The map object type to use (changes the icon)
---@field Position SWMatrix The position the map object should be shown on the map at
---@field Radius number The radius of this map object
---@field AttachmentBody NoirBody|nil The body to optionally attach the map object to
---@field AttachmentObject NoirObject|nil The object to optionally attach the map object to
---@field AttachmentOffset SWMatrix The offset to apply to the body/object attachment
---@field _AttachmentMode SWPositionTypeEnum The map object attachment mode
---@field ColorR number The red color value of this map object (0-255)
---@field ColorG number The green color value of this map object (0-255)
---@field ColorB number The blue color value of this map object (0-255)
---@field ColorA number The alpha color value of this map object (0-255)
Noir.Classes.MapObjectWidget = Noir.Class("MapObjectWidget", Noir.Classes.Widget)

--[[
    Initializes class objects from this class.
]]
---@param ID integer
---@param visible boolean
---@param title string
---@param text string
---@param objectType SWMarkerTypeEnum
---@param position SWMatrix
---@param radius number
---@param colorR number
---@param colorG number
---@param colorB number
---@param colorA number
---@param player NoirPlayer|nil
function Noir.Classes.MapObjectWidget:Init(ID, visible, title, text, objectType, position, radius, colorR, colorG, colorB, colorA, player)
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "title", title, "string")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "text", text, "string")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "objectType", objectType, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "radius", radius, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "colorR", colorR, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "colorG", colorG, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "colorB", colorB, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "colorA", colorA, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Init()", "player", player, Noir.Classes.Player, "nil")

    self:InitFrom(
        Noir.Classes.Widget,
        ID,
        visible,
        "MapObject",
        player
    )

    self.Title = title
    self.Text = text
    self.ObjectType = objectType
    self.Position = position
    self.Radius = radius
    self.AttachmentOffset = matrix.translation(0, 0, 0)
    self._AttachmentMode = 0
    self.ColorR = colorR
    self.ColorG = colorG
    self.ColorB = colorB
    self.ColorA = colorA
end

--[[
    Attaches this map object to a body.<br>
    Upon doing so, the map object will follow the body's position until detached with the `:Detach()` method.<br>
    You can offset the map object with the `AttachmentOffset` property.<br>
    Note that `:Update()` is called automatically.
]]
---@param body NoirBody
function Noir.Classes.MapObjectWidget:AttachToBody(body)
    self.AttachmentBody = body
    self._AttachmentMode = 1

    self:Update()
end

--[[
    Attaches this map object to an object.<br>
    Upon doing so, the map object will follow the object's position until detached with the `:Detach()` method.<br>
    You can offset the map object with the `AttachmentOffset` property.<br>
    Note that `:Update()` is called automatically.
]]
---@param object NoirObject
function Noir.Classes.MapObjectWidget:AttachToObject(object)
    self.AttachmentObject = object
    self._AttachmentMode = 2

    self:Update()
end

--[[
    Detaches this map object from any body or object.
]]
function Noir.Classes.MapObjectWidget:Detach()
    self.AttachmentBody = nil
    self.AttachmentObject = nil
    self._AttachmentMode = 0

    self:Update()
end

--[[
    Serializes this map object widget.
]]
---@return NoirSerializedMapObjectWidget
function Noir.Classes.MapObjectWidget:_Serialize() ---@diagnostic disable-next-line missing-return
    return {
        Title = self.Title,
        Text = self.Text,
        ObjectType = self.ObjectType,
        Position = self.Position,
        Radius = self.Radius,
        ColorR = self.ColorR,
        ColorG = self.ColorG,
        ColorB = self.ColorB,
        ColorA = self.ColorA,
        AttachmentBodyID = self.AttachmentBody and self.AttachmentBody.ID or nil,
        AttachmentObjectID = self.AttachmentObject and self.AttachmentObject.ID or nil,
        AttachmentOffset = self.AttachmentOffset,
        AttachmentMode = self._AttachmentMode
    }
end

--[[
    Deserializes a map object widget.
]]
---@param serializedWidget NoirSerializedMapObjectWidget
---@return NoirMapObjectWidget|nil
function Noir.Classes.MapObjectWidget:Deserialize(serializedWidget)
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:Deserialize()", "serializedWidget", serializedWidget, "table")

    local widget = self:New(
        serializedWidget.ID,
        serializedWidget.Visible,
        serializedWidget.Title,
        serializedWidget.Text,
        serializedWidget.ObjectType,
        serializedWidget.Position,
        serializedWidget.Radius,
        serializedWidget.ColorR,
        serializedWidget.ColorG,
        serializedWidget.ColorB,
        serializedWidget.ColorA,
        Noir.Services.UIService:_GetSerializedPlayer(serializedWidget.Player)
    )

    widget._AttachmentMode = serializedWidget.AttachmentMode
    widget.AttachmentOffset = serializedWidget.AttachmentOffset

    if serializedWidget.AttachmentMode == 1 then
        local body = Noir.Services.VehicleService:GetBody(serializedWidget.AttachmentBodyID)

        if not body then
            self:Detach()
            return widget
        end

        self.AttachmentBody = body
    elseif serializedWidget.AttachmentMode == 2 then
        local object = Noir.Services.ObjectService:GetObject(serializedWidget.AttachmentObjectID)

        if not object or not object:Exists() then
            self:Detach()
            return widget
        end

        self.AttachmentObject = object
    end

    return widget
end

--[[
    Handles updating this widget.
]]
---@param player NoirPlayer
function Noir.Classes.MapObjectWidget:_Update(player)
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:_Update()", "player", player, Noir.Classes.Player)

    server.addMapObject(
        player.ID,
        self.ID,
        self._AttachmentMode,
        self.ObjectType,
        self.Position[13],
        self.Position[15],
        self.AttachmentOffset[13],
        self.AttachmentOffset[15],
        self._AttachmentMode == 1 and self.AttachmentBody.ID or 0,
        self._AttachmentMode == 2 and self.AttachmentObject.ID or 0,
        self.Title,
        self.Radius,
        self.Text,
        self.ColorR,
        self.ColorG,
        self.ColorB,
        self.ColorA
    )
end

--[[
    Handles destroying this widget.
]]
---@param player NoirPlayer
function Noir.Classes.MapObjectWidget:_Destroy(player)
    Noir.TypeChecking:Assert("Noir.Classes.MapObjectWidget:_Destroy()", "player", player, Noir.Classes.Player)
    server.removeMapObject(player.ID, self.ID)
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of a map object widget.
]]
---@class NoirSerializedMapObjectWidget: NoirSerializedWidget
---@field Title string The title of this map object
---@field Text string The text of this map object
---@field ObjectType SWMarkerTypeEnum The map object type to use (changes the icon)
---@field Position SWMatrix The position the map object should be shown on the map at
---@field Radius number The radius of this map object
---@field ColorR number The red color value of this map object
---@field ColorG number The green color value of this map object
---@field ColorB number The blue color value of this map object
---@field ColorA number The alpha color value of this map object
---@field AttachmentBodyID integer|nil The ID of the body to attach this map object to
---@field AttachmentObjectID integer|nil The ID of the object to attach this map object to
---@field AttachmentOffset SWMatrix The offset to apply to the body/object attachment
---@field AttachmentMode SWPositionTypeEnum The attachment mode to use

--------------------------------------------------------
-- [Noir] Classes - Screen Popup Widget
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a screen popup widget to be shown to players via UIService.<br>
    Not to be confused with a popup which is shown in 3D space.
]]
---@class NoirScreenPopupWidget: NoirWidget
---@field New fun(self: NoirScreenPopupWidget, ID: integer, visible: boolean, text: string, X: number, Y: number, player: NoirPlayer|nil): NoirScreenPopupWidget
---@field Text string The text shown in the popup
---@field X number The X position of the popup on the screen (-1 (left) to 1 (right))
---@field Y number The Y position of the popup on the screen (-1 (bottom) to 1 (top))
Noir.Classes.ScreenPopupWidget = Noir.Class("ScreenPopupWidget", Noir.Classes.Widget)

--[[
    Initializes class objects from this class.
]]
---@param ID integer
---@param visible boolean
---@param text string
---@param X number
---@param Y number
---@param player NoirPlayer|nil
function Noir.Classes.ScreenPopupWidget:Init(ID, visible, text, X, Y, player)
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:Init()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:Init()", "X", X, "number")
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:Init()", "Y", Y, "number")
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:Init()", "player", player, Noir.Classes.Player, "nil")

    self:InitFrom(
        Noir.Classes.Widget,
        ID,
        visible,
        "ScreenPopup",
        player
    )

    self.Text = text
    self.X = X
    self.Y = Y
end

--[[
    Serializes this screen popup widget.
]]
---@return NoirSerializedScreenPopupWidget
function Noir.Classes.ScreenPopupWidget:_Serialize() ---@diagnostic disable-next-line missing-return
    return {
        Text = self.Text,
        X = self.X,
        Y = self.Y
    }
end

--[[
    Deserializes a screen popup widget.
]]
---@param serializedWidget NoirSerializedScreenPopupWidget
---@return NoirScreenPopupWidget|nil
function Noir.Classes.ScreenPopupWidget:Deserialize(serializedWidget)
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:Deserialize()", "serializedWidget", serializedWidget, "table")

    return self:New(
        serializedWidget.ID,
        serializedWidget.Visible,
        serializedWidget.Text,
        serializedWidget.X,
        serializedWidget.Y,
        Noir.Services.UIService:_GetSerializedPlayer(serializedWidget.Player)
    )
end

--[[
    Handles updating this widget.
]]
---@param player NoirPlayer
function Noir.Classes.ScreenPopupWidget:_Update(player)
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:_Update()", "player", player, Noir.Classes.Player)

    server.setPopupScreen(
        player.ID,
        self.ID,
        "",
        self.Visible,
        self.Text,
        self.X,
        self.Y
    )
end

--[[
    Handles destroying this widget.
]]
---@param player NoirPlayer
function Noir.Classes.ScreenPopupWidget:_Destroy(player)
    Noir.TypeChecking:Assert("Noir.Classes.ScreenPopupWidget:_Destroy()", "player", player, Noir.Classes.Player)

    server.setPopupScreen( -- `server.removePopup` shows a tutorial popup for a brief moment, so we aren't using it
        player.ID,
        self.ID,
        "",
        false,
        "",
        0,
        0
    )
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of a screen popup widget.
]]
---@class NoirSerializedScreenPopupWidget: NoirSerializedWidget
---@field Text string The text shown in the screen popup
---@field X number The X position of the popup on the screen (-1 (left) to 1 (right))
---@field Y number The Y position of the popup on the screen (-1 (bottom) to 1 (top))

--------------------------------------------------------
-- [Noir] Classes - Popup Widget
--------------------------------------------------------

--[[
    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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
    Represents a 3D space popup UI widget to be shown to players via UIService.
]]
---@class NoirPopupWidget: NoirWidget
---@field New fun(self: NoirPopupWidget, ID: number, visible: boolean, text: string, position: SWMatrix, renderDistance: number, player: NoirPlayer|nil): NoirPopupWidget
---@field Text string The text of the popup
---@field Position SWMatrix The 3D position of the popup
---@field RenderDistance number The distance at which the popup is visible
---@field AttachmentBody NoirBody|nil The body to optionally attach the popup to
---@field AttachmentObject NoirObject|nil The object to optionally attach the popup to
---@field AttachmentOffset SWMatrix The offset to apply when attached
---@field _AttachmentMode number The attachment mode (0 = none, 1 = body, 2 = object)
Noir.Classes.PopupWidget = Noir.Class("PopupWidget", Noir.Classes.Widget)

--[[
    Initializes a new popup widget.
]]
---@param ID number
---@param visible boolean
---@param text string
---@param position SWMatrix
---@param renderDistance number
---@param player NoirPlayer|nil
function Noir.Classes.PopupWidget:Init(ID, visible, text, position, renderDistance, player)
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:Init()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:Init()", "text", text, "string")
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:Init()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:Init()", "renderDistance", renderDistance, "number")
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:Init()", "player", player, Noir.Classes.Player, "nil")

    self:InitFrom(
        Noir.Classes.Widget,
        ID,
        visible,
        "Popup",
        player
    )

    self.Text = text
    self.Position = position
    self.RenderDistance = renderDistance

    self.AttachmentOffset = matrix.translation(0, 0, 0)
    self._AttachmentMode = 0
end

--[[
    Attaches this popup to a body.<br>
    Upon doing so, the popup will follow the body's position until detached with the `:Detach()` method.<br>
    You can offset the popup from the body by setting the `AttachmentOffset` property.<br>
    Note that `:Update()` is called automatically.
]]
---@param body NoirBody
function Noir.Classes.PopupWidget:AttachToBody(body)
    self.AttachmentBody = body
    self._AttachmentMode = 1

    self:Update()
end

--[[
    Attaches this popup to an object.<br>
    Upon doing so, the popup will follow the object's position until detached with the `:Detach()` method.<br>
    You can offset the popup from the object by setting the `AttachmentOffset` property.<br>
    Note that `:Update()` is called automatically.
]]
---@param object NoirObject
function Noir.Classes.PopupWidget:AttachToObject(object)
    self.AttachmentObject = object
    self._AttachmentMode = 2

    self:Update()
end

--[[
    Detaches this popup from any body or object.
]]
function Noir.Classes.PopupWidget:Detach()
    self.AttachmentBody = nil
    self.AttachmentObject = nil
    self._AttachmentMode = 0

    self:Update()
end

--[[
    Serializes this popup widget.
]]
---@return NoirSerializedPopupWidget
function Noir.Classes.PopupWidget:_Serialize() ---@diagnostic disable-next-line missing-return
    return {
        Text = self.Text,
        Position = self.Position,
        RenderDistance = self.RenderDistance,
        AttachmentBodyID = self.AttachmentBody and self.AttachmentBody.ID or nil,
        AttachmentObjectID = self.AttachmentObject and self.AttachmentObject.ID or nil,
        AttachmentOffset = self.AttachmentOffset,
        AttachmentMode = self._AttachmentMode
    }
end

--[[
    Deserializes a popup widget.
]]
---@param serializedWidget NoirSerializedPopupWidget
---@return NoirPopupWidget|nil
function Noir.Classes.PopupWidget:Deserialize(serializedWidget)
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:Deserialize()", "serializedWidget", serializedWidget, "table")

    local widget = self:New(
        serializedWidget.ID,
        serializedWidget.Visible,
        serializedWidget.Text,
        serializedWidget.Position,
        serializedWidget.RenderDistance,
        Noir.Services.UIService:_GetSerializedPlayer(serializedWidget.Player)
    )

    widget._AttachmentMode = serializedWidget.AttachmentMode
    widget.AttachmentOffset = serializedWidget.AttachmentOffset

    if serializedWidget.AttachmentMode == 1 then
        local body = Noir.Services.VehicleService:GetBody(serializedWidget.AttachmentBodyID)

        if not body then
            self:Detach()
            return widget
        end

        widget.AttachmentBody = body
    elseif serializedWidget.AttachmentMode == 2 then
        local object = Noir.Services.ObjectService:GetObject(serializedWidget.AttachmentObjectID)

        if not object or not object:Exists() then
            self:Detach()
            return widget
        end

        widget.AttachmentObject = object
    end

    return widget
end

--[[
    Handles updating this widget.
]]
---@param player NoirPlayer
function Noir.Classes.PopupWidget:_Update(player)
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:_Update()", "player", player, Noir.Classes.Player)

    server.setPopup(
        player.ID,
        self.ID,
        "",
        self.Visible,
        self.Text,
        self._AttachmentMode == 0 and self.Position[13] or self.AttachmentOffset[13],
        self._AttachmentMode == 0 and self.Position[14] or self.AttachmentOffset[14],
        self._AttachmentMode == 0 and self.Position[15] or self.AttachmentOffset[15],
        self.RenderDistance,
        self._AttachmentMode == 1 and self.AttachmentBody.ID or 0,
        self._AttachmentMode == 2 and self.AttachmentObject.ID or 0
    )
end

--[[
    Handles destroying this widget.
]]
---@param player NoirPlayer
function Noir.Classes.PopupWidget:_Destroy(player)
    Noir.TypeChecking:Assert("Noir.Classes.PopupWidget:_Destroy()", "player", player, Noir.Classes.Player)

    server.setPopup(
        player.ID,
        self.ID,
        "",
        false,
        "",
        0,
        0,
        0,
        0,
        0,
        0
    )
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of a popup widget.
]]
---@class NoirSerializedPopupWidget: NoirSerializedWidget
---@field Text string The text of the popup
---@field Position SWMatrix The 3D position of the popup
---@field RenderDistance number The distance at which the popup is visible
---@field AttachmentBodyID number|nil The ID of the body to attach this popup to
---@field AttachmentObjectID number|nil The ID of the object to attach this popup to
---@field AttachmentOffset SWMatrix The offset to apply to the attachment
---@field AttachmentMode number The attachment mode (0 = none, 1 = body, or 2 = object)

--------------------------------------------------------
-- [Noir] Classes - Map Line Widget
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Represents a map line UI widget to be shown to players via UIService.
]]
---@class NoirMapLineWidget: NoirWidget
---@field New fun(self: NoirMapLineWidget, ID: integer, visible: boolean, startPosition: SWMatrix, endPosition: SWMatrix, width: number, colorR: number, colorG: number, colorB: number, colorA: number, player: NoirPlayer|nil): NoirMapLineWidget
---@field StartPosition SWMatrix The starting position of the line
---@field EndPosition SWMatrix The ending position of the line
---@field Width number The width of the line
---@field ColorR number The red color value of this map object (0-255)
---@field ColorG number The green color value of this map object (0-255)
---@field ColorB number The blue color value of this map object (0-255)
---@field ColorA number The alpha color value of this map object (0-255)
Noir.Classes.MapLineWidget = Noir.Class("MapLineWidget", Noir.Classes.Widget)

--[[
    Initializes class objects from this class.
]]
---@param ID integer
---@param visible boolean
---@param startPosition SWMatrix
---@param endPosition SWMatrix
---@param width number
---@param colorR number
---@param colorG number
---@param colorB number
---@param colorA number
---@param player NoirPlayer|nil
function Noir.Classes.MapLineWidget:Init(ID, visible, startPosition, endPosition, width, colorR, colorG, colorB, colorA, player)
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "startPosition", startPosition, "table")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "endPosition", endPosition, "table")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "width", width, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "colorR", colorR, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "colorG", colorG, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "colorB", colorB, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "colorA", colorA, "number")
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Init()", "player", player, Noir.Classes.Player, "nil")

    self:InitFrom(
        Noir.Classes.Widget,
        ID,
        visible,
        "MapLine",
        player
    )

    self.StartPosition = startPosition
    self.EndPosition = endPosition
    self.Width = width
    self.ColorR = colorR
    self.ColorG = colorG
    self.ColorB = colorB
    self.ColorA = colorA
end

--[[
    Serializes this map line widget.
]]
---@return NoirSerializedMapLineWidget
function Noir.Classes.MapLineWidget:_Serialize()
    return {
        StartPosition = self.StartPosition,
        EndPosition = self.EndPosition,
        Width = self.Width,
        ColorR = self.ColorR,
        ColorG = self.ColorG,
        ColorB = self.ColorB,
        ColorA = self.ColorA
    }
end

--[[
    Deserializes a map line widget.
]]
---@param serializedWidget NoirSerializedMapLineWidget
---@return NoirMapLineWidget|nil
function Noir.Classes.MapLineWidget:Deserialize(serializedWidget)
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:Deserialize()", "serializedWidget", serializedWidget, "table")

    return self:New(
        serializedWidget.ID,
        serializedWidget.Visible,
        serializedWidget.StartPosition,
        serializedWidget.EndPosition,
        serializedWidget.Width,
        serializedWidget.ColorR,
        serializedWidget.ColorG,
        serializedWidget.ColorB,
        serializedWidget.ColorA,
        Noir.Services.UIService:_GetSerializedPlayer(serializedWidget.Player)
    )
end

--[[
    Handles updating this widget.
]]
---@param player NoirPlayer
function Noir.Classes.MapLineWidget:_Update(player)
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:_Update()", "player", player, Noir.Classes.Player)

    server.addMapLine(
        player.ID,
        self.ID,
        self.StartPosition,
        self.EndPosition,
        self.Width,
        self.ColorR,
        self.ColorG,
        self.ColorB,
        self.ColorA
    )
end

--[[
    Handles destroying this widget.
]]
---@param player NoirPlayer
function Noir.Classes.MapLineWidget:_Destroy(player)
    Noir.TypeChecking:Assert("Noir.Classes.MapLineWidget:_Destroy()", "player", player, Noir.Classes.Player)
    server.removeMapLine(player.ID, self.ID)
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a serialized version of a map line widget.
]]
---@class NoirSerializedMapLineWidget: NoirSerializedWidget
---@field StartPosition SWMatrix The starting position of the line
---@field EndPosition SWMatrix The ending position of the line
---@field Width number The width of the line
---@field ColorR number The red component of the color (0-255)
---@field ColorG number The green component of the color (0-255)
---@field ColorB number The blue component of the color (0-255)
---@field ColorA number The alpha component of the color (0-255)

--------------------------------------------------------
-- [Noir] Libraries
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A module of Noir that allows you to create your own libraries to use throughout your code.

    MyLibrary = Noir.Libraries:Create("MyLibrary")

    function MyLibrary:add(num1, num2)
        return num1 + num2
    end
]]
Noir.Libraries = {}

--[[
    Returns a library starter pack for you to use when creating libraries for your addon.

    MyLibrary = Noir.Libraries:Create("MyLibrary")

    function MyLibrary:add(num1, num2)
        return num1 + num2
    end
]]
---@param name string
---@param shortDescription string|nil
---@param longDescription string|nil
---@param authors table<integer, string>|nil
---@return NoirLibrary
function Noir.Libraries:Create(name, shortDescription, longDescription, authors)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries:Create()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Libraries:Create()", "shortDescription", shortDescription, "string", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries:Create()", "longDescription", longDescription, "string", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries:Create()", "authors", authors, "table", "nil")

    -- Create library
    local library = Noir.Classes.Library:New(name, shortDescription or "N/A", longDescription or "N/A", authors or {})

    -- Return library
    return library
end

--------------------------------------------------------
-- [Noir] Libraries - Base64
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing helper methods to serialize strings into Base64 and back.<br>
    This code is from https://gist.github.com/To0fan/ca3ebb9c029bb5df381e4afc4d27b4a6
]]
---@class NoirBase64Lib: NoirLibrary
Noir.Libraries.Base64 = Noir.Libraries:Create(
    "Base64",
    "A library containing helper methods to serialize strings into Base64 and back.",
    "",
    {"Cuh4"}
)

--[[
    Character table as a string.<br>
    Used internally, do not use in your code.
]]
Noir.Libraries.Base64.Characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

--[[
    Encode a string into Base64.
]]
---@param data string
---@return string
function Noir.Libraries.Base64:Encode(data)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Base64:Encode()", "data", data, "string")

    -- Encode the string into Base64
    ---@param str string
    local encoded = (data:gsub(".", function(str)
        return self:_EncodeInitial(str)
    end).."0000")

    ---@param str string
    return encoded:gsub("%d%d%d?%d?%d?%d?", function(str)
        return self:_EncodeFinal(str)
    end)..({"", "==", "="})[#data % 3 + 1]
end

--[[
    Used internally, do not use in your code.
]]
---@param data string
---@return string
function Noir.Libraries.Base64:_EncodeInitial(data)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Base64:_EncodeInitial()", "data", data, "string")

    -- Main logic
    local r, b = "", data:byte()

    for i = 8, 1, -1 do
        r = r..(b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
    end

    return r
end

--[[
    Used internally, do not use in your code.
]]
---@param data string
---@return string
function Noir.Libraries.Base64:_EncodeFinal(data)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Base64:_EncodeFinal()", "data", data, "string")

    -- Main logic
    if (#data < 6) then
        return ""
    end

    local c = 0

    for i = 1, 6 do
        c = c + (data:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
    end

    return self.Characters:sub(c + 1, c + 1)
end

--[[
    Decode a string from Base64.
]]
---@param data string
---@return string
function Noir.Libraries.Base64:Decode(data)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Base64:Decode()", "data", data, "string")

    -- Decode the Base64 string into a normal string
    local decoded = data:gsub("[^"..self.Characters.."=]", "")

    ---@param str string
    decoded = decoded:gsub(".", function(str)
        return self:_DecodeInitial(str)
    end)

    ---@param str string
    return (decoded:gsub("%d%d%d?%d?%d?%d?%d?%d?", function(str)
        return self:_DecodeFinal(str)
    end))
end

--[[
    Used internally, do not use in your code.
]]
---@param str string
---@return string
function Noir.Libraries.Base64:_DecodeInitial(str)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Base64:_DecodeInitial()", "str", str, "string")

    -- Main logic
    if str == "=" then
        return ""
    end

    local r, f = "", (self.Characters:find(str)) - 1

    for i = 6, 1, -1 do
        r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
    end

    return r
end

--[[
    Used internally, do not use in your code.
]]
---@param str string
---@return string
function Noir.Libraries.Base64:_DecodeFinal(str)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Base64:_DecodeFinal()", "str", str, "string")

    -- Main logic
    if #str ~= 8 then
        return ""
    end

    local c = 0

    for i = 1, 8 do
        c = c + (str:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
    end

    if not Noir.Libraries.Number:IsInteger(c) then
        error("Noir.Libraries.Base64:_DecodeFinal()", "'c' is not an integer.")
    end

    return string.char(c)
end

--------------------------------------------------------
-- [Noir] Libraries - Dataclasses
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library that allows you to create dataclasses, similar to Python.

    local InventoryItem = Noir.Libraries.Dataclasses:New("InventoryItem", {
        Noir.Libraries.Dataclasses:Field("Name", "string"),
        Noir.Libraries.Dataclasses:Field("Weight", "number"),
        Noir.Libraries.Dataclasses:Field("Stackable", "boolean")
    })

    local item = InventoryItem:New("Sword", 5, true)
    print(item.Name, item.Weight, item.Stackable)
]]
---@class NoirDataclassesLib: NoirLibrary
Noir.Libraries.Dataclasses = Noir.Libraries:Create(
    "Dataclasses",
    "A library that allows you to create dataclasses, similar to Python.",
    nil,
    {"Cuh4"}
)

--[[
    Create a new dataclass.

    local InventoryItem = Noir.Libraries.Dataclasses:New("InventoryItem", {
        Noir.Libraries.Dataclasses:Field("Name", "string"),
        Noir.Libraries.Dataclasses:Field("Weight", "number"),
        Noir.Libraries.Dataclasses:Field("Stackable", "boolean")
    })

    local item = InventoryItem:New("Sword", 5, true)
    print(item.Name, item.Weight, item.Stackable)
]]
---@param name string
---@param fields table<integer, NoirDataclassField>
---@return NoirDataclass
function Noir.Libraries.Dataclasses:New(name, fields)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Dataclasses:New()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.Dataclasses:New()", "fields", fields, "table")

    -- Create dataclass
    ---@class NoirDataclass: NoirClass
    ---@field New fun(self: NoirDataclass, ...: any): NoirDataclass
    local dataclass = Noir.Class(name)

    function dataclass:Init(...)
        local args = {...} ---@type table<integer, any>

        for index, field in pairs(fields) do
            local argument = args[index]

            -- If nil and nil isn't allowed, raise error
            if argument == nil and not Noir.Libraries.Table:Find(field.Types, "nil") then
                error(("%s (Dataclass)"):format(name), "Missing argument #%d. Expected %s, got nil.", index, table.concat(field.Types, " | "))
            end

            -- Perform type check
            Noir.TypeChecking:Assert(("%s:Init()"):format(name), field.Name, argument, table.unpack(field.Types))

            -- Ensure we're not overwriting
            if self[field.Name] then
                error(("%s (Dataclass)"):format(name), "'%s' overwrites an existing field (possibly a built-in field to a class like 'ClassName'). To fix this, rename the field to something else.", field.Name)
            end

            -- Insert field
            self[field.Name] = argument
        end
    end

    -- Return
    return dataclass
end

--[[
    Returns a dataclass field to be used with Noir.Libraries.Dataclasses:New().
]]
---@param name string
---@param ... NoirTypeCheckingType
---@return NoirDataclassField
function Noir.Libraries.Dataclasses:Field(name, ...)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Dataclasses:Field()", "name", name, "string")
    Noir.TypeChecking:AssertMany("Noir.Libraries.Dataclasses:Field()", "...", {...}, "string")

    -- Construct and return field
    return {Name = name, Types = {...}}
end

-------------------------------
-- // Intellisense
-------------------------------

--[[
    Represents a field for a dataclass.
]]
---@class NoirDataclassField
---@field Name string
---@field Types table<integer, NoirTypeCheckingType>

--------------------------------------------------------
-- [Noir] Libraries - Deprecation
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library that allows you to mark functions as deprecated.

    ---@deprecated <-- intellisense. recommended to add
    function HelloWorld()
        Noir.Libraries.Deprecation:Deprecated("HelloWorld", "AnOptionalReplacementFunction", "An optional note appended to the deprecation message")
        print("Hello World")
    end
]]
---@class NoirDeprecationLib: NoirLibrary
Noir.Libraries.Deprecation = Noir.Libraries:Create(
    "Deprecation",
    "A library that allows you to mark functions as deprecated.",
    "A library that allows you to mark functions as deprecated. No function wrapping is used.",
    {"Cuh4"}
)

--[[
    Mark a function as deprecated.
    
    ---@deprecated <-- intellisense. recommended to add
    function HelloWorld()
        Noir.Libraries.Deprecation:Deprecated("HelloWorld", "AnOptionalReplacementFunction", "An optional note appended to the deprecation message")
        print("Hello World")
    end
]]
---@param name string
---@param replacement string|nil
---@param note string|nil
function Noir.Libraries.Deprecation:Deprecated(name, replacement, note)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Deprecation:Deprecated()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.Deprecation:Deprecated()", "replacement", replacement, "string", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries.Deprecation:Deprecated()", "note", note, "string", "nil")

    -- Setup message
    local _replacement = ""

    if replacement then
        _replacement = (" Please use '%s' instead."):format(replacement)
    end

    local _note = ""

    if note then
        _note = "\n"..note
    end

    -- Send message
    Noir.Libraries.Logging:Warning("Deprecated", "'%s' is deprecated.".._replacement.._note, name)
end

--------------------------------------------------------
-- [Noir] Libraries - Events
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library that allows you to create events.

    local MyEvent = Events:Create()

    MyEvent:Connect(function()
        print("Fired")
    end)

    MyEvent:Once(function() -- Automatically disconnected upon event being fired
        print("Fired (once)")
    end)

    MyEvent:Fire()
]]
---@class NoirEventsLib: NoirLibrary
Noir.Libraries.Events = Noir.Libraries:Create(
    "Events",
    "A library that allows you to create events.",
    "A library that allows you to create events. Functions can then be connected or disconnected from these events. Events can be fired which calls all connected functions with the provided arguments.",
    {"Cuh4", "Avril112113"}
)

--[[
    Create an event. This event can then be fired with the :Fire() method.

    local MyEvent = Noir.Libraries.Events:Create()

    local connection = MyEvent:Connect(function()
        print("Fired")
    end)

    connection:Disconnect() -- Disconnects the callback from the event

    local connection2 = MyEvent:Once(function() -- Automatically disconnected upon fire
        print("Fired. This won't be printed ever again even if the event is fired again")
    end)

    MyEvent:Fire() -- "Fired. This won't be printed ever again even if the event is fired again"
]]
---@return NoirEvent
function Noir.Libraries.Events:Create()
    local event = Noir.Classes.Event:New()
    return event
end

--[[
    Return this in the function provided to `:Connect()` to disconnect the function from the connected event after it is called.<br>
    This is similar to calling `:Disconnect()` after a connection to an event was fired.
    
    local MyEvent = Noir.Libraries.Events:Create()

    MyEvent:Connect(function()
        print("Fired")
        return Noir.Libraries.Events.DismissAction
    end)

    MyEvent:Fire()
    -- "Fired"
    MyEvent:Fire()
    -- N/A
]]
Noir.Libraries.Events.DismissAction = {}

--------------------------------------------------------
-- [Noir] Libraries - HTTP
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing helper methods relating to HTTP.
]]
---@class NoirHTTPLib: NoirLibrary
Noir.Libraries.HTTP = Noir.Libraries:Create(
    "HTTP",
    "A library containing helper methods relating to HTTP.",
    "A library containing helper methods relating to HTTP. Comes with methods for encoding/decoding URLs, etc.",
    {"Cuh4"}
)

--[[
    Encode a string into a URL-safe string.
]]
---@param str string
---@return string
function Noir.Libraries.HTTP:URLEncode(str)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.HTTP:URLEncode()", "str", str, "string")

    -- Encode and return
    return (str:gsub(
        "([^%w%-%_%.%~])",

        ---@param c string
        function(c)
            return ("%%%02X"):format(c:byte())
        end
    ))
end

--[[
    Decode a URL-safe string into a string.
]]
---@param str string
---@return string
function Noir.Libraries.HTTP:URLDecode(str)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.HTTP:URLDecode()", "str", str, "string")

    -- Decode and return
    return (str:gsub(
        "%%(%x%x)",

        ---@param c string
        function(c)
            return string.char(tonumber(c, 16))
        end
    ))
end

--[[
    Convert a table of URL parameters into a string.
]]
---@param parameters table<string, any>
---@return string
function Noir.Libraries.HTTP:URLParameters(parameters)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.HTTP:URLParameters()", "parameters", parameters, "table")

    -- Convert
    local str = ""
    local count = 0

    for key, value in pairs(parameters) do
        count = count + 1

        if count == 1 then
            str = ("?%s=%s"):format(self:URLEncode(tostring(key)), self:URLEncode(tostring(value)))
        else
            str = ("%s&%s=%s"):format(str, self:URLEncode(tostring(key)), self:URLEncode(tostring(value)))
        end
    end

    -- Return
    return str
end

--[[
    Returns whether or not a response to a HTTP request is ok.
]]
---@param response string
---@return boolean
function Noir.Libraries.HTTP:IsResponseOk(response)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.HTTP:IsResponseOk()", "response", response, "string")

    -- Return
    return ({
        ["Connection closed unexpectedly"] = true,
        ["connect(): Connection refused"] = true,
        ["recv(): Connection reset by peer"] = true,
        ["timeout"] = true,
		["connect(): Can't assign requested address"] = true
    })[response] == nil
end

--------------------------------------------------------
-- [Noir] Libraries - JSON
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing helper methods to serialize Lua objects into JSON and back.<br>
    This code is from https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
]]
---@class NoirJSONLib: NoirLibrary
Noir.Libraries.JSON = Noir.Libraries:Create(
    "JSON",
    "A library containing helper methods to serialize Lua objects into JSON and back.",
    nil,
    {"Cuh4"}
)

--[[
    Returns the type of the provided object.<br>
    Used internally. Do not use in your code.
]]
---@param obj any
---@return "nil"|"boolean"|"number"|"string"|"table"|"function"|"array"
function Noir.Libraries.JSON:KindOf(obj)
    if type(obj) ~= "table" then
        return type(obj) ---@diagnostic disable-line
    end

    local i = 1

    for _ in pairs(obj) do
        if obj[i] ~= nil then
            i = i + 1
        else
            return "table"
        end
    end

    if i == 1 then
        return "table"
    else
        return "array"
    end
end

--[[
    Escapes a string for JSON.<br>
    Used internally. Do not use in your code.
]]
---@param str string
---@return string
function Noir.Libraries.JSON:EscapeString(str)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:EscapeString()", "str", str, "string")

    -- Escape the string
    local inChar  = { "\\", "\"", "/", "\b", "\f", "\n", "\r", "\t" }
    local outChar = { "\\", "\"", "/", "b", "f", "n", "r", "t" }

    for i, c in ipairs(inChar) do
        str = str:gsub(c, "\\" .. outChar[i])
    end

    return str
end

--[[
    Finds the point where a delimiter is and simply returns the point after.<br>
    Used internally. Do not use in your code.
]]
---@param str string
---@param pos integer
---@param delim string
---@param errIfMissing boolean|nil
---@return integer
---@return boolean
function Noir.Libraries.JSON:SkipDelim(str, pos, delim, errIfMissing)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:SkipDelim()", "str", str, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:SkipDelim()", "pos", pos, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:SkipDelim()", "delim", delim, "string")

    -- Main logic
    pos = pos + #str:match("^%s*", pos)

    if str:sub(pos, pos) ~= delim then
        if errIfMissing then
            return 0, false
        end

        return pos, false
    end

    return pos + 1, true
end

--[[
    Parses a string.<br>
    Used internally. Do not use in your code.
]]
---@param str string
---@param pos integer
---@param val string|nil
---@return string
---@return integer
function Noir.Libraries.JSON:ParseStringValue(str, pos, val)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:ParseStringValue()", "str", str, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:ParseStringValue()", "pos", pos, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:ParseStringValue()", "val", val, "string", "nil")

    -- Parsing
    val = val or ""

    -- local earlyEndError = "End of input found while parsing string."

    if pos > #str then
        return "", 0
    end

    local c = str:sub(pos, pos)

    if c == "\"" then
        return val, pos + 1
    end

    if c ~= "\\" then return
        self:ParseStringValue(str, pos + 1, val .. c)
    end

    local escMap = {b = "\b", f = "\f", n = "\n", r = "\r", t = "\t"}
    local nextc = str:sub(pos + 1, pos + 1)

    if not nextc then
        return "", 0
    end

    return self:ParseStringValue(str, pos + 2, val..(escMap[nextc] or nextc))
end

--[[
    Parses a number.<br>
    Used internally. Do not use in your code.
]]
---@param str string
---@param pos integer
---@return integer
---@return integer
function Noir.Libraries.JSON:ParseNumberValue(str, pos)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:ParseNumberValue()", "str", str, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:ParseNumberValue()", "pos", pos, "number")

    -- Parse number
    local numStr = str:match("^-?%d+%.?%d*[eE]?[+-]?%d*", pos)
    local val = tonumber(numStr)

    if not val then
        return 0, 0
    end

    return val, pos + #numStr
end

--[[
    Encodes a Lua object as a JSON string.

    local str = {1, 2, 3}
    Noir.Libraries.JSON:Encode(str) -- "{1, 2, 3}"
]]
---@param obj table|number|string|boolean|nil
---@param asKey boolean|nil
---@return string
function Noir.Libraries.JSON:Encode(obj, asKey)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:Encode()", "obj", obj, "table", "number", "string", "boolean", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:Encode()", "asKey", asKey, "boolean", "nil")

    -- Encode the object into a JSON string
    local s = {}
    local kind = self:KindOf(obj)

    if kind == "array" then
        if asKey then
            return ""
        end

        s[#s + 1] = "["

        for i, val in ipairs(obj --[[@as table]]) do
            if i > 1 then
                s[#s + 1] = ", "
            end

            s[#s + 1] = self:Encode(val)
        end

        s[#s + 1] = "]"
    elseif kind == "table" then
        if asKey then
            return ""
        end

        s[#s + 1] = "{"

        for k, v in pairs(obj --[[@as table]]) do
            if #s > 1 then
                s[#s + 1] = ", "
            end

            s[#s + 1] = self:Encode(k, true)
            s[#s + 1] = ":"
            s[#s + 1] = self:Encode(v)
        end

        s[#s + 1] = "}"
    elseif kind == "string" then
        return "\""..self:EscapeString(obj --[[@as string]]).."\""
    elseif kind == "number" then
        if asKey then
            return "\"" .. tostring(obj) .. "\""
        end

        return tostring(obj)
    elseif kind == "boolean" then
        return tostring(obj)
    elseif kind == "nil" then
        return "null"
    else
        return ""
    end

    return table.concat(s)
end

--[[
    Represents a null value.<br>
    You do not need to reference this. Null values will just be nil in a decoded JSON object.<br>
    Used internally. Do not use this in your code.
]]
Noir.Libraries.JSON._Null = {}

--[[
    Decodes a JSON string into a Lua object.

    local obj = "{1, 2, 3}"
    Noir.Libraries.JSON:Decode(obj) -- {1, 2, 3}
]]
---@param str string
---@param pos integer|nil
---@param endDelim string|nil
---@return any
---@return integer
function Noir.Libraries.JSON:Decode(str, pos, endDelim)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:Decode()", "str", str, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:Decode()", "pos", pos, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries.JSON:Decode()", "endDelim", endDelim, "string", "nil")

    -- Decode a JSON string into a Lua object
    pos = pos or 1

    if pos > #str then
        return nil, 0
    end

    pos = pos + #str:match("^%s*", pos)
    local first = str:sub(pos, pos)

    if first == "{" then
        local obj, key, delimFound = {}, true, true
        pos = pos + 1

        while true do
            key, pos = self:Decode(str, pos, "}")

            if key == nil then
                return obj, pos
            end

            if not delimFound then
                return nil, 0
            end

            pos = self:SkipDelim(str, pos, ":", true)

            obj[key], pos = self:Decode(str, pos)
            pos, delimFound = self:SkipDelim(str, pos, ",")
        end
    elseif first == "[" then
        local arr, val, delimFound = {}, true, true
        pos = pos + 1

        while true do
            val, pos = self:Decode(str, pos, "]")

            if val == nil then
                return arr, pos
            end

            if not delimFound then
                return nil, 0
            end

            arr[#arr + 1] = val
            pos, delimFound = self:SkipDelim(str, pos, ",")
        end
    elseif first == "\"" then
        return self:ParseStringValue(str, pos + 1)
    elseif first == "-" or first:match("%d") then
        return self:ParseNumberValue(str, pos)
    elseif first == endDelim then
        return nil, pos + 1
    else
        local literals = {
            ["true"] = true,
            ["false"] = false,
            ["null"] = self._Null
        }

        for litStr, litVal in pairs(literals) do
            local litEnd = pos + #litStr - 1

            if str:sub(pos, litEnd) == litStr then
                if litVal == self._Null then
                    return nil, litEnd + 1
                end

                return litVal, litEnd + 1
            end
        end

        return nil, 0
    end
end

--------------------------------------------------------
-- [Noir] Libraries - Logging
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing methods related to logging.
]]
---@class NoirLoggingLib: NoirLibrary
Noir.Libraries.Logging = Noir.Libraries:Create(
    "Logging",
    "A library containing methods related to logging.",
    nil,
    {"Cuh4"}
)

--[[
    The mode to use when logging.<br>
    - "DebugLog": Sends logs to DebugView<br>
    - "Chat": Sends logs to chat
]]
Noir.Libraries.Logging.LoggingMode = "DebugLog" ---@type NoirLoggingMode

--[[
    An event called when a log is sent.<br>
    Arguments: (log: string)
]]
Noir.Libraries.Logging.OnLog = Noir.Libraries.Events:Create()

--[[
    Represents the logging layout.<br>
    Requires two '%s' in the layout. First %s is the addon name, second %s is the log type, and the third %s is the log title. The message is then added after the layout.
]]
Noir.Libraries.Logging.Layout = "[Noir] [%s] [%s] [%s]: "

--[[
    Set the logging mode.

    Noir.Libraries.Logging:SetMode("DebugLog")
]]
---@param mode NoirLoggingMode
function Noir.Libraries.Logging:SetMode(mode)
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:SetMode()", "mode", mode, "string")
    self.LoggingMode = mode
end

--[[
    Sends a log.

    Noir.Libraries.Logging:Log("Warning", "Title", "Something went wrong relating to %s", "something.")
]]
---@param logType string
---@param title string
---@param message any
---@param ... any
function Noir.Libraries.Logging:Log(logType, title, message, ...)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:Log()", "logType", logType, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:Log()", "title", title, "string")

    -- Format
    local formattedText = self:_FormatLog(logType, title, message, ...)

    -- Send log
    if self.LoggingMode == "DebugLog" then
        debug.log(formattedText)
    elseif self.LoggingMode == "Chat" then
        debug.log(formattedText)
        server.announce("Noir", formattedText) -- this goes against the rules of noir libraries as they should not interact with the game, but i suppose this is a special case. whups!
    else
        self:Error("Logging", "'%s' is not a valid logging mode.", true, tostring(Noir.Libraries.LoggingMode))
    end

    -- Send event
    self.OnLog:Fire(formattedText)
end

--[[
    Format a log.<br>
    Used internally.
]]
---@param logType string
---@param title string
---@param message any
---@param ... any
function Noir.Libraries.Logging:_FormatLog(logType, title, message, ...)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:_FormatLog()", "logType", logType, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:_FormatLog()", "title", title, "string")

    -- Validate args
    local validatedLogType = tostring(logType)
    local validatedTitle = tostring(title)
    local validatedMessage = type(message) == "table" and Noir.Libraries.Table:ToString(message) or (... and tostring(message):format(...) or tostring(message))

    -- Format text
    local formattedMessage = (self.Layout:format(Noir.AddonName, validatedLogType, validatedTitle)..validatedMessage):gsub("\n", "\n"..self.Layout:format(Noir.AddonName, validatedLogType, validatedTitle))

    -- Return
    return formattedMessage
end

--[[
    Sends an error log.

    Noir.Libraries.Logging:Error("Title", "Something went wrong relating to %s", "something.")
]]
---@param title string
---@param message any
---@param ... any
function Noir.Libraries.Logging:Error(title, message, ...)
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:Error()", "title", title, "string")
    self:Log("Error", title, message, ...)
end

--[[
    Sends a warning log.

    Noir.Libraries.Logging:Warning("Title", "Something went unexpected relating to %s", "something.")
]]
---@param title string
---@param message any
---@param ... any
function Noir.Libraries.Logging:Warning(title, message, ...)
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:Warning()", "title", title, "string")
    self:Log("Warning", title, message, ...)
end

--[[
    Sends an info log.

    Noir.Libraries.Logging:Info("Title", "Something went okay relating to %s", "something.")
]]
---@param title string
---@param message any
---@param ... any
function Noir.Libraries.Logging:Info(title, message, ...)
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:Info()", "title", title, "string")
    self:Log("Info", title, message, ...)
end

--[[
    Sends a success log.

    Noir.Libraries.Logging:Success("Title", "Something went right relating to %s", "something.")
]]
---@param title string
---@param message any
---@param ... any
function Noir.Libraries.Logging:Success(title, message, ...)
    Noir.TypeChecking:Assert("Noir.Libraries.Logging:Success()", "title", title, "string")
    self:Log("Success", title, message, ...)
end

-------------------------------
-- // Intellisense
-------------------------------

---@alias NoirLoggingMode
---| "Chat" Sends via server.announce and via debug.log
---| "DebugLog" Sends only via debug.log

--------------------------------------------------------
-- [Noir] Libraries - Table
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing helper methods relating to Stormworks matrices.
]]
---@class NoirMatrixLib: NoirLibrary
Noir.Libraries.Matrix = Noir.Libraries:Create(
    "Matrix",
    "A library containing helper methods relating to Stormworks matrices.",
    nil,
    {"Cuh4"}
)

--[[
    Offsets the position of a matrix.
]]
---@param pos SWMatrix
---@param xOffset integer|nil
---@param yOffset integer|nil
---@param zOffset integer|nil
---@return SWMatrix
function Noir.Libraries.Matrix:Offset(pos, xOffset, yOffset, zOffset)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Offset()", "pos", pos, "table")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Offset()", "xOffset", xOffset, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Offset()", "yOffset", yOffset, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Offset()", "zOffset", zOffset, "number", "nil")

    -- Offset the matrix
    return matrix.multiply(pos, matrix.translation(xOffset or 0, yOffset or 0, zOffset or 0))
end

--[[
    Returns an empty matrix. Equivalent to matrix.translation(0, 0, 0)
]]
---@return SWMatrix
function Noir.Libraries.Matrix:Empty()
    return matrix.translation(0, 0, 0)
end

--[[
    Returns a scaled matrix. Multiply this with another matrix to scale up said matrix.<br>
    This can be used to enlarge vehicles spawned via server.spawnAddonComponent, server.spawnAddonVehicle, etc.
]]
---@param scaleX number
---@param scaleY number
---@param scaleZ number
---@return SWMatrix
function Noir.Libraries.Matrix:Scale(scaleX, scaleY, scaleZ)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Scale()", "scaleX", scaleX, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Scale()", "scaleY", scaleY, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Scale()", "scaleZ", scaleZ, "number")

    -- Scale the matrix
    local pos = self:Empty()
    pos[1] = scaleX
    pos[6] = scaleY
    pos[11] = scaleZ

    -- Return
    return pos
end

--[[
    Offset a matrix by a random amount.
]]
---@param pos SWMatrix
---@param xRange number
---@param yRange number
---@param zRange number
---@return SWMatrix
function Noir.Libraries.Matrix:RandomOffset(pos, xRange, yRange, zRange)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:RandomOffset()", "pos", pos, "table")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:RandomOffset()", "xRange", xRange, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:RandomOffset()", "yRange", yRange, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:RandomOffset()", "zRange", zRange, "number")

    -- Offset the matrix randomly
    return self:Offset(pos, math.random(-xRange, xRange), math.random(-yRange, yRange), math.random(-zRange, zRange))
end

--[[
    Converts a matrix to a readable format.
]]
---@param pos SWMatrix
---@return string
function Noir.Libraries.Matrix:ToString(pos)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:ToString()", "pos", pos, "table")

    -- Convert the matrix to a string
    local x, y, z = matrix.position(pos)
    return ("%.1f, %.1f, %.1f"):format(x, y, z)
end

--[[
    Returns the magnitude of a matrix's XYZ vector.
]]
---@param pos SWMatrix
---@return number
function Noir.Libraries.Matrix:Magnitude(pos)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Matrix:Magnitude()", "pos", pos, "table")

    -- Return
    local x, y, z = matrix.position(pos)
    return math.sqrt((x * x) + (y * y) + (z * z))
end

--------------------------------------------------------
-- [Noir] Libraries - Number
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing helper methods relating to numbers.
]]
---@class NoirNumberLib: NoirLibrary
Noir.Libraries.Number = Noir.Libraries:Create(
    "Number",
    "Provides helper methods relating to numbers.",
    nil,
    {"Cuh4"}
)

--[[
    Returns whether or not the provided number is between the two provided values.

    local number = 5
    local isWithin = Noir.Libraries.Number:IsWithin(number, 1, 10) -- true

    local number = 5
    local isWithin = Noir.Libraries.Number:IsWithin(number, 10, 20) -- false
]]
---@param number number
---@param start number
---@param stop number
---@return boolean
function Noir.Libraries.Number:IsWithin(number, start, stop)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Number:IsWithin()", "number", number, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Number:IsWithin()", "start", start, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Number:IsWithin()", "stop", stop, "number")

    -- Clamp the number
    return number >= start and number <= stop
end

--[[
    Clamps a number between two values.

    local number = 5
    local clamped = Noir.Libraries.Number:Clamp(number, 1, 10) -- 5

    local number = 15
    local clamped = Noir.Libraries.Number:Clamp(number, 1, 10) -- 10
]]
---@param number number
---@param min number
---@param max number
---@return number
function Noir.Libraries.Number:Clamp(number, min, max)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Number:Clamp()", "number", number, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Number:Clamp()", "min", min, "number")
    Noir.TypeChecking:Assert("Noir.Libraries.Number:Clamp()", "max", max, "number")

    -- Clamp the number
    return math.min(math.max(number, min), max)
end

--[[
    Rounds the number to the provided number of decimal places (defaults to 0).

    local number = 5.5
    local rounded = Noir.Libraries.Number:Round(number) -- 6

    local number = 5.5
    local rounded = Noir.Libraries.Number:Round(number, 1) -- 5.5

    local number = 5.537
    local rounded = Noir.Libraries.Number:Round(number, 2) -- 5.54
]]
---@param number number
---@param decimalPlaces number|nil
---@return number
function Noir.Libraries.Number:Round(number, decimalPlaces)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Number:Round()", "number", number, "number")

    -- Round the number
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(number * mult + 0.5) / mult
end

--[[
    Returns whether or not the provided number is an integer.

    Noir.Libraries.Number:IsInteger(5) -- true
    Noir.Libraries.Number:IsInteger(5.5) -- false
]]
---@param number number
---@return boolean
function Noir.Libraries.Number:IsInteger(number)
    Noir.TypeChecking:Assert("Noir.Libraries.Number:IsInteger()", "number", number, "number")
    return math.floor(number) == number
end

--[[
    Returns the average of the provided numbers.

    local numbers = {1, 2, 3, 4, 5}
    Noir.Libraries.Number:Average(numbers) -- 3
]]
---@param numbers table<integer, number>
---@return number
function Noir.Libraries.Number:Average(numbers)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Number:Average()", "numbers", numbers, "table")

    -- Get sum
    local sum = 0

    for _, number in pairs(numbers) do
        sum = sum + number
    end

    -- Return average
    return sum / #numbers
end

--------------------------------------------------------
-- [Noir] Libraries - String
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing helper methods relating to strings.
]]
---@class NoirStringLib: NoirLibrary
Noir.Libraries.String = Noir.Libraries:Create(
    "String",
    "A library containing helper methods relating to strings.",
    nil,
    {"Cuh4"}
)

--[[
    Splits a string by the provided separator (defaults to " ").

    local myString = "hello world"
    Noir.Libraries.String:Split(myString, " ") -- {"hello", "world"}
    Noir.Libraries.String:Split(myString) -- {"hello", "world"}
]]
---@param str string
---@param separator string|nil
---@return table<integer, string>
function Noir.Libraries.String:Split(str, separator)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.String:Split()", "str", str, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.String:Split()", "separator", separator, "string", "nil")

    -- Default separator
    separator = separator or " "

    -- Split the string
    local split = {}

    for part in str:gmatch("([^"..separator.."]+)") do
        table.insert(split, part)
    end

    -- Return the split string
    return split
end

--[[
    Splits a string by their lines.

    local myString = "hello\nworld"
    Noir.Libraries.String:SplitLines(myString) -- {"hello", "world"}
]]
---@param str string
---@return table<integer, string>
function Noir.Libraries.String:SplitLines(str)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.String:SplitLines()", "str", str, "string")

    -- Split the string by newlines
    return self:Split(str, "\n")
end

--[[
    Returns whether or not the provided string starts with the provided prefix.

    local myString = "hello world"
    Noir.Libraries.String:StartsWith(myString, "hello") -- true
    Noir.Libraries.String:StartsWith(myString, "world") -- false
]]
---@param str string
---@param prefix string
---@return boolean
function Noir.Libraries.String:StartsWith(str, prefix)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.String:StartsWith()", "str", str, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.String:StartsWith()", "prefix", prefix, "string")

    -- Return
    if prefix == "" then
        return false
    end

    return str:sub(1, #prefix) == prefix
end

--[[
    Returns whether or not the provided string ends with the provided suffix.

    local myString = "hello world"
    Noir.Libraries.String:EndsWith(myString, "world") -- true
    Noir.Libraries.String:EndsWith(myString, "hello") -- false
]]
---@param str string
---@param suffix string
---@return boolean
function Noir.Libraries.String:EndsWith(str, suffix)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.String:EndsWith()", "str", str, "string")
    Noir.TypeChecking:Assert("Noir.Libraries.String:EndsWith()", "suffix", suffix, "string")

    -- Return
    if suffix == "" then
        return false
    end

    return str:sub(-#suffix) == suffix
end

--------------------------------------------------------
-- [Noir] Libraries - Table
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library containing helper methods relating to tables.
]]
---@class NoirTableLib: NoirLibrary
Noir.Libraries.Table = Noir.Libraries:Create(
    "Table",
    "A library containing helper methods relating to tables.",
    nil,
    {"Cuh4"}
)

--[[
    Returns the length of the provided table.

    local myTbl = {1, 2, 3}
    local length = Noir.Libraries.Table:Length(myTbl)
    print(length) -- 3

    local complexTable = {
        [5] = true,
        [true] = 25
    }
    local complexLength = Noir.Libraries.Table:Length(complexTable)
    print(length) -- 2
]]
---@param tbl table
---@return integer
function Noir.Libraries.Table:Length(tbl)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Length()", "tbl", tbl, "table")

    -- Calculate the length of the table
    local length = 0

    for _ in pairs(tbl) do
        length = length + 1
    end

    return length
end

--[[
    Returns a random value in the provided table.

    local myTbl = {1, 2, 3}
    local random = Noir.Libraries.Table:Random(myTbl)
    print(random) -- 1|2|3
]]
---@param tbl table
---@return any
function Noir.Libraries.Table:Random(tbl)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Random()", "tbl", tbl, "table")

    -- Prevent an error if the table is empty
    if #tbl == 0 then
        return
    end

    -- Return a random value
    return tbl[math.random(1, #tbl)]
end

--[[
    Return the keys of the provided table.

    local myTbl = {
        [true] = 1
    }

    local keys = Noir.Libraries.Table:Keys(myTbl)
    print(keys) -- {true}
]]
---@generic tbl: table
---@param tbl table
---@return tbl
function Noir.Libraries.Table:Keys(tbl)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Keys()", "tbl", tbl, "table")

    -- Create a new table with the keys of the provided table
    local keys = {}

    for index, _ in pairs(tbl) do
        table.insert(keys, index)
    end

    return keys
end

--[[
    Return the values of the provided table.

    local myTbl = {
        [true] = 1
    }

    local values = Noir.Libraries.Table:Values(myTbl)
    print(values) -- {1}
]]
---@generic tbl: table
---@param tbl tbl
---@return tbl
function Noir.Libraries.Table:Values(tbl)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Values()", "tbl", tbl, "table")

    -- Create a new table with the values of the provided table
    local values = {}

    for _, value in pairs(tbl) do
        table.insert(values, value)
    end

    return values
end

--[[
    Get a portion of a table between two points.

    local myTbl = {1, 2, 3, 4, 5, 6}
    local trimmed = Noir.Libraries.Table:Slice(myTbl, 2, 4)
    print(trimmed) -- {2, 3, 4}
]]
---@generic tbl: table
---@param tbl tbl
---@param start number|nil
---@param finish number|nil
---@return tbl
function Noir.Libraries.Table:Slice(tbl, start, finish)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Slice()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Slice()", "start", start, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Slice()", "finish", finish, "number", "nil")

    -- Slice the table
    return {table.unpack(tbl, start, finish)}
end

--[[
    Converts a table to a string by iterating deep through the table.

    local myTbl = {1, 2, {}, "foo"}
    local string = Noir.Libraries.Table:ToString(myTbl)
    print(string) -- 1: 1\n2: 2\n3: {}\n4: "foo"
    
]]
---@param tbl table
---@param indent integer|nil
---@return string
function Noir.Libraries.Table:ToString(tbl, indent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:ToString()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Libraries.Table:ToString()", "indent", indent, "number", "nil")

    -- Set default indent
    if not indent then
        indent = 0
    end

    -- Create a table for later
    local toConcatenate = {}

    -- Convert the table to a string
    for index, value in pairs(tbl) do
        -- Get value type
        local valueType = type(value)

        -- Format the index for later
        local formattedIndex = ("[%s]:"):format(type(index) == "string" and "\""..index.."\"" or tostring(index):gsub("\n", "\\n"))

        -- Format the value
        local toAdd = formattedIndex

        if valueType == "table" then
            -- Format table
            local nextIndent = indent + 2
            local formattedValue = Noir.Libraries.Table:ToString(value, nextIndent)

            -- Check if empty table
            if formattedValue == "" then
                formattedValue = "{}"
            else
                formattedValue = "\n"..formattedValue
            end

            -- Add to string
            toAdd = toAdd..(" %s"):format(formattedValue)
        elseif valueType == "number" or valueType == "boolean" then
            toAdd = toAdd..(" %s"):format(tostring(value))
        else
            toAdd = toAdd..(" \"%s\""):format(tostring(value):gsub("\n", "\\n"))
        end

        -- Add to table
        table.insert(toConcatenate, ("  "):rep(indent)..toAdd)
    end

    -- Return the table as a formatted string
    return table.concat(toConcatenate, "\n")
end

--[[
    Copy a table (shallow).

    local myTbl = {1, 2, 3}
    local copy = Noir.Libraries.Table:Copy(myTbl)
    print(copy) -- {1, 2, 3}
]]
---@generic tbl: table
---@param tbl tbl
---@return tbl
function Noir.Libraries.Table:Copy(tbl)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Copy()", "tbl", tbl, "table")

    -- Perform a shallow copy
    local new = {}

    for index, value in pairs(tbl) do
        new[index] = value
    end

    return new
end
--[[
    Copy a table (deep).

    local myTbl = {1, 2, 3}
    local copy = Noir.Libraries.Table:DeepCopy(myTbl)
    print(copy) -- {1, 2, 3}
]]
---@generic tbl: table
---@param tbl tbl
---@return tbl
function Noir.Libraries.Table:DeepCopy(tbl)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:DeepCopy()", "tbl", tbl, "table")

    -- Perform a deep copy
    local new = {}

    for index, value in pairs(tbl) do
        if type(value) == "table" then
            new[index] = self:DeepCopy(value)
        else
            new[index] = value
        end
    end

    return new
end

--[[
    Merge two tables together (unforced).

    local myTbl = {1, 2, 3}
    local otherTbl = {4, 5, 6}
    local merged = Noir.Libraries.Table:Merge(myTbl, otherTbl)
    print(merged) -- {1, 2, 3, 4, 5, 6}
]]
---@param tbl table
---@param other table
---@return table
function Noir.Libraries.Table:Merge(tbl, other)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Merge()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Merge()", "other", other, "table")

    -- Merge the tables
    local new = self:Copy(tbl)

    for _, value in pairs(other) do
        table.insert(new, value)
    end

    return new
end

--[[
    Merge two tables together (forced).

    local myTbl = {1, 2, 3}
    local otherTbl = {4, 5, 6}
    local merged = Noir.Libraries.Table:ForceMerge(myTbl, otherTbl)
    print(merged) -- {4, 5, 6} <-- This is because the indexes are the same, so the values of myTbl were overwritten
]]
---@param tbl table
---@param other table
---@return table
function Noir.Libraries.Table:ForceMerge(tbl, other)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:ForceMerge()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Libraries.Table:ForceMerge()", "other", other, "table")

    -- Merge the tables forcefully
    local new = self:Copy(tbl)

    for index, value in pairs(other) do
        new[index] = value
    end

    return new
end

--[[
    Find a value in a table. Returns the index, or nil if not found.

    local myTbl = {["hello"] = true}

    local index = Noir.Libraries.Table:Find(myTbl, true)
    print(index) -- "hello"
]]
---@param tbl table
---@param value any
---@return any|nil
function Noir.Libraries.Table:Find(tbl, value)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:Find()", "tbl", tbl, "table")

    -- Find the value
    for index, iterValue in pairs(tbl) do
        if iterValue == value then
            return index
        end
    end
end

--[[
    Find a value in a table. Unlike `:Find()`, this method will recursively search through nested tables to find the value.

    local myTbl = {
        mySecondTbl = {
            hello = true
        }
    }
    
    local index, table = Noir.Libraries.Table:FindDeep(myTbl, true)
    print(index) -- "hello"
    print(table) -- {["hello"] = true}
]]
---@param tbl table
---@param value any
---@return any|nil, table|nil
function Noir.Libraries.Table:FindDeep(tbl, value)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Libraries.Table:FindDeep()", "tbl", tbl, "table")

    -- Find the value
    for index, iterValue in pairs(tbl) do
        if iterValue == value then
            return index, tbl
        elseif type(iterValue) == "table" then
            return self:FindDeep(iterValue, value)
        end
    end
end

--------------------------------------------------------
-- [Noir] Services
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A module of Noir that allows you to create organized services.<br>
    These services can be used to hold methods that are all designed for a specific purpose.

    local service = Noir.Services:GetService("MyService")
    service.initPriority = 1 -- Initialize before any other services

    function service:ServiceInit()
        -- Do something
    end

    function service:ServiceStart()
        -- Do something
    end
]]
Noir.Services = {}

--[[
    A table containing created services.<br>
    You probably do not need to modify or access this table directly. Please use `Noir.Services:GetService(name)` instead.
]]
Noir.Services.CreatedServices = {} ---@type table<string, NoirService>

--[[
    Create a service.<br>
    This service will be initialized and started after `Noir:Start()` is called.

    local service = Noir.Services:CreateService("MyService")
    service.initPriority = 1 -- Initialize before any other services

    function service:ServiceInit()
        Noir.Services:GetService("MyOtherService") -- This will likely error if the other service hasn't initialized yet. Use :GetService() in :ServiceStart() always!
        self.saveSomething = "something"
    end

    function service:ServiceStart()
        print(self.saveSomething)
    end
]]
---@param name string
---@param isBuiltIn boolean|nil
---@param shortDescription string|nil
---@param longDescription string|nil
---@param authors table<integer, string>|nil
---@return NoirService
function Noir.Services:CreateService(name, isBuiltIn, shortDescription, longDescription, authors)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services:CreateService()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Services:CreateService()", "isBuiltIn", isBuiltIn, "boolean", "nil")
    Noir.TypeChecking:Assert("Noir.Services:CreateService()", "shortDescription", shortDescription, "string", "nil")
    Noir.TypeChecking:Assert("Noir.Services:CreateService()", "longDescription", longDescription, "string", "nil")
    Noir.TypeChecking:Assert("Noir.Services:CreateService()", "authors", authors, "table", "nil")

    -- Check if service already exists
    if self.CreatedServices[name] then
        error(":CreateService()", "Attempted to create a service with the same name as an already-existing service. Name: %s", name)
    end

    -- Create service
    local service = Noir.Classes.Service:New(name, isBuiltIn or false, shortDescription or "N/A", longDescription or "N/A", authors or {})

    -- Register service internally
    self.CreatedServices[name] = service

    -- Return service
    return service
end

--[[
    Retrieve a service by its name.<br>
    This will error if the service hasn't initialized yet.

    local service = Noir.Services:GetService("MyService")
    print(service.name) -- "MyService"
]]
---@param name string
---@return NoirService
function Noir.Services:GetService(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services:GetService()", "name", name, "string")

    -- Get service
    local service = self.CreatedServices[name]

    -- Check if service exists
    if not service then
        error(":GetService()", "Attempted to retrieve a service that doesn't exist ('%s').", name)
    end

    -- Check if service has been initialized
    if not service.Initialized then
        error(":GetService()", "Attempted to retrieve a service that hasn't initialized yet ('%s').", service.Name)
    end

    return service
end

--[[
    Remove a service.
]]
---@param name string
function Noir.Services:RemoveService(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services:RemoveService()", "name", name, "string")

    -- Check if service exists
    if not self.CreatedServices[name] then
        error(":RemoveService()", "Attempted to remove a service that doesn't exist ('%s').", name)
    end

    -- Remove service
    self.CreatedServices[name] = nil
end

--[[
    Format a service into a string.<br>
    Returns the service name as well as the author(s) if any.
]]
---@param service NoirService
---@return string
function Noir.Services:FormatService(service)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services:FormatService()", "service", service, Noir.Classes.Service)

    -- Format service
    return ("'%s'%s%s"):format(service.Name, #service.Authors >= 1 and " by "..table.concat(service.Authors, ", ") or "", service.IsBuiltIn and " (Built-In)" or "")
end

--[[
    Returns all built-in Noir services.
]]
---@return table<string, NoirService>
function Noir.Services:GetBuiltInServices()
    local services = {}

    for index, service in pairs(self.CreatedServices) do
        if service.IsBuiltIn then
            services[index] = service
        end
    end

    return services
end

--[[
    Removes built-in services from Noir. This may give a very slight performance increase.<br>
    **Use before calling Noir:Start().**
]]
---@param exceptions table<integer, string> A table containing exact names of services to not remove
function Noir.Services:RemoveBuiltInServices(exceptions)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services:RemoveBuiltInServices()", "exceptions", exceptions, "table")

    -- Remove built-in services
    for _, service in pairs(self:GetBuiltInServices()) do
        if Noir.Libraries.Table:Find(exceptions, service.Name) then
            goto continue
        end

        self:RemoveService(service.Name)

        ::continue::
    end
end

--------------------------------------------------------
-- [Noir] Services - Command Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for easily creating commands with support for command aliases, permissions, etc.

    Noir.Services.CommandService:CreateCommand("info", {"i"}, {"Nerd"}, false, false, false, "Shows random information.", function(player, message, args, hasPermission)
        if not hasPermission then
            server.announce("Server", "Sorry, you don't have permission to use this command. Try again though.", player.ID)
            player:SetPermission("Nerd")
            return
        end

        server.announce("Info", "This addon uses Noir!")
    end)
]]
---@class NoirCommandService: NoirService
---@field Commands table<string, NoirCommand> A table of registered commands
---@field _OnCustomCommandConnection NoirConnection Represents the connection to the OnCustomCommand game callback
Noir.Services.CommandService = Noir.Services:CreateService(
    "CommandService",
    true,
    "A service that allows you to create commands.",
    "A service that allows you to create commands with support for aliases, permissions, etc.",
    {"Cuh4"}
)

function Noir.Services.CommandService:ServiceInit()
    self.Commands = {}
end

function Noir.Services.CommandService:ServiceStart()
    self._OnCustomCommandConnection = Noir.Callbacks:Connect("onCustomCommand", function(message, peer_id, _, _, commandName, ...)
        -- Get the player
        local player = Noir.Services.PlayerService:GetPlayer(peer_id)

        if not player then -- can occur because of `server.command` calls
            return
        end

        -- Remove ? prefix
        commandName = commandName:sub(2)

        -- Get the command
        local command = self:FindCommand(commandName)

        if not command then
            return
        end

        -- Trigger the command
        command:_Use(player, message, {...})
    end)
end

--[[
    Get a command by the name or alias.
]]
---@param query string
---@return NoirCommand|nil
function Noir.Services.CommandService:FindCommand(query)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.CommandService:FindCommand()", "query", query, "string")

    -- Find the command
    for _, command in pairs(self:GetCommands()) do
        if command:_Matches(query) then
            return command
        end
    end
end

--[[
    Create a new command.

    Noir.Services.CommandService:CreateCommand("help", {"h"}, {"Nerd"}, false, false, false, "Example Command", function(player, message, args, hasPermission)
        if not hasPermission then
            player:Notify("Lacking Permissions", "Sorry, you don't have permission to run this command. Try again.", 3)
            player:SetPermission("Nerd")
            return
        end

        player:Notify("Help", "TODO: Add a help message", 4)
    end)
]]
---@param name string The name of the command (eg: if you provided "help", the player would need to type "?help" in chat)
---@param aliases table<integer, string> The aliases of the command
---@param requiredPermissions table<integer, string>|nil The required permissions for this command
---@param requiresAuth boolean|nil Whether or not this command requires auth
---@param requiresAdmin boolean|nil Whether or not this command requires admin
---@param capsSensitive boolean|nil Whether or not this command is case-sensitive
---@param description string|nil The description of this command
---@param callback fun(player: NoirPlayer, message: string, args: table<integer, string>, hasPermission: boolean)
---@return NoirCommand
function Noir.Services.CommandService:CreateCommand(name, aliases, requiredPermissions, requiresAuth, requiresAdmin, capsSensitive, description, callback)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "aliases", aliases, "table")
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "requiredPermissions", requiredPermissions, "table", "nil")
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "requiresAuth", requiresAuth, "boolean", "nil")
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "requiresAdmin", requiresAdmin, "boolean", "nil")
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "capsSensitive", capsSensitive, "boolean", "nil")
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "description", description, "string", "nil")
    Noir.TypeChecking:Assert("Noir.Services.CommandService:CreateCommand()", "callback", callback, "function")

    -- Create command
    local command = Noir.Classes.Command:New(name, aliases, requiredPermissions or {}, requiresAuth or false, requiresAdmin or false, capsSensitive or false, description or "")

    -- Connect to event
    command.OnUse:Connect(callback)

    -- Save and return
    self.Commands[name] = command
    return command
end

--[[
    Get a command by the name.
]]
---@param name string
---@return NoirCommand|nil
function Noir.Services.CommandService:GetCommand(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.CommandService:GetCommand()", "name", name, "string")

    -- Return the command
    return self.Commands[name]
end

--[[
    Remove a command.
]]
---@param name string
function Noir.Services.CommandService:RemoveCommand(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.CommandService:RemoveCommand()", "name", name, "string")

    -- Remove the command
    self.Commands[name] = nil
end

--[[
    Returns all commands.
]]
---@return table<string, NoirCommand>
function Noir.Services.CommandService:GetCommands()
    return self.Commands
end

--------------------------------------------------------
-- [Noir] Services - Game Settings Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for changing and accessing the game's settings.

    Noir.Services.GameSettingsService:GetSetting("infinite_batteries") -- false
    Noir.Services.GameSettingsService:SetSetting("infinite_batteries", true)
]]
---@class NoirGameSettingsService: NoirService
Noir.Services.GameSettingsService = Noir.Services:CreateService(
    "GameSettingsService",
    true,
    "A basic service for changing and accessing the game's settings.",
    nil,
    {"Cuh4"}
)

--[[
    Returns a list of all game settings.
]]
---@return SWGameSettings
function Noir.Services.GameSettingsService:GetSettings()
    return server.getGameSettings()
end

--[[
    Returns the value of the provided game setting.

    Noir.Services.GameSettingsService:GetSetting("infinite_batteries") -- false
]]
---@param name SWGameSettingEnum
---@return any
function Noir.Services.GameSettingsService:GetSetting(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.GameSettingsService:GetSetting()", "name", name, "string")

    -- Get a setting
    local settings = self:GetSettings()
    local setting = settings[name]

    if setting == nil then
        error("GameSettingsService:GetSetting()", "'%s' is not a valid game setting.", name)
    end

    return setting
end

--[[
    Sets the value of the provided game setting.

    Noir.Services.GameSettingsService:SetSetting("infinite_batteries", true)
]]
---@param name SWGameSettingEnum
---@param value any
function Noir.Services.GameSettingsService:SetSetting(name, value)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.GameSettingsService:SetSetting()", "name", name, "string")

    -- Set the setting
    if self:GetSettings()[name] == nil then
        error("GameSettingsService:SetSetting()", "'%s' is not a valid game setting.", name)
    end

    server.setGameSetting(name, value)
end

--------------------------------------------------------
-- [Noir] Services - HTTP Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for sending HTTP requests.<br>
    Requests are localhost only due to Stormworks limitations.

    Noir.Services.HTTPService:GET("/items/5", 8000, function(response)
        if not response:IsOk() then
            return
        end

        local item = response:JSON()
        Noir.Libraries.Logging:Info("Item", item.Name)
    end)
]]
---@class NoirHTTPService: NoirService
---@field ActiveRequests table<integer, NoirHTTPRequest> A table of unanswered HTTP requests.
---@field _PortRangeMin integer The minimum acceptable port number.
---@field _PortRangeMax integer The maximum acceptable port number.
---@field _HTTPReplyConnection NoirConnection A connection to the httpReply event
Noir.Services.HTTPService = Noir.Services:CreateService(
    "HTTPService",
    true,
    "A service for sending HTTP requests.",
    "A service for sending HTTP requests. Comes with helper HTTP functions.",
    {"Cuh4"}
)

function Noir.Services.HTTPService:ServiceInit()
    self.ActiveRequests = {}

    self._PortRangeMin = 1
    self._PortRangeMax = 65535
end

function Noir.Services.HTTPService:ServiceStart()
    self._HTTPReplyConnection = Noir.Callbacks:Connect("httpReply", function(port, URL, response)
        -- Check if port is valid
        if not self:IsPortValid(port) then
            return
        end

        -- Find request
        local request, index = self:_FindRequest(URL, port)

        if not request then
            return
        end

        -- Trigger response
        request.OnResponse:Fire(Noir.Classes.HTTPResponse:New(response))

        -- Remove request
        table.remove(self.ActiveRequests, index)
    end)
end

--[[
    Get earliest request for a URL and port.<br>
    Used internally.
]]
---@param URL string
---@param port integer
---@return NoirHTTPRequest|nil, integer|nil
function Noir.Services.HTTPService:_FindRequest(URL, port)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.HTTPService:_FindRequest()", "URL", URL, "string")
    Noir.TypeChecking:Assert("Noir.Services.HTTPService:_FindRequest()", "port", port, "number")

    -- Find request
    for index, request in ipairs(self:GetActiveRequests()) do
        if request.URL == URL and request.Port == port then
            return request, index
        end
    end
end

--[[
    Returns if a port is within the valid port range.
]]
---@param port integer
---@return boolean
function Noir.Services.HTTPService:IsPortValid(port)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.HTTPService:IsPortValid()", "port", port, "number")

    -- Return
    return port >= self._PortRangeMin and port <= self._PortRangeMax
end

--[[
    Send a GET request.<br>
    All requests are localhost only. This is a Stormworks limitation.

    Noir.Services.HTTPService:GET("/items/5", 8000, function(response)
        if not response:IsOk() then
            return
        end

        local item = response:JSON()
        Noir.Libraries.Logging:Info("Item", item.Name)
    end)
]]
---@param URL string
---@param port integer
---@param callback fun(response: NoirHTTPResponse)|nil
---@return NoirHTTPRequest
function Noir.Services.HTTPService:GET(URL, port, callback)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.HTTPService:GET()", "URL", URL, "string")
    Noir.TypeChecking:Assert("Noir.Services.HTTPService:GET()", "port", port, "number")
    Noir.TypeChecking:Assert("Noir.Services.HTTPService:GET()", "callback", callback, "function", "nil")

    -- Check if port is valid
    if not self:IsPortValid(port) then
        error("HTTPService", "Port is out of range, expected a port between %d and %d.", self._PortRangeMin, self._PortRangeMax)
    end

    -- Create request object
    local request = Noir.Classes.HTTPRequest:New(URL, port)

    if callback then
        request.OnResponse:Once(callback)
    end

    -- Send request
    server.httpGet(port, URL)
    table.insert(self.ActiveRequests, request)

    -- Return it
    return request
end

--[[
    Returns all active requests.
]]
---@return table<integer, NoirHTTPRequest>
function Noir.Services.HTTPService:GetActiveRequests()
    return self.ActiveRequests
end

--------------------------------------------------------
-- [Noir] Services - Message Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for storing, accessing and sending messages.

    ---@param message NoirMessage
    Noir.Services.MessageService.OnMessage:Connect(function(message)
        Noir.Libraries.Logging:Info("Message", "(%s) > %s (%s)", message.Title, message.Content, message.IsAddon and "Sent by addon" or "Sent by player")
    end)

    Noir.Services.MessageService:SendMessage(nil, "[Server]", "Hello world!")
]]
---@class NoirMessageService: NoirService
---@field Messages table<integer, NoirMessage> A table of all messages that have been sent.
---@field _SavedMessages table<integer, NoirSerializedMessage> A table of all messages that have been sent (g_savedata version).
---@field _MessageLimit integer The maximum amount of messages that can be stored.
---
---@field OnMessage NoirEvent Arguments: message (NoirMessage) | Fired when a message is sent.
---
---@field _OnChatMessageConnection NoirConnection The connection to the `onChatMessage` event.
Noir.Services.MessageService = Noir.Services:CreateService(
    "MessageService",
    true,
    "A service for storing, accessing and sending messages.",
    nil,
    {"Cuh4"}
)

function Noir.Services.MessageService:ServiceInit()
    self.Messages = {}
    self._SavedMessages = self:Load("Messages", {})
    self._MessageLimit = 220

    self.OnMessage = Noir.Libraries.Events:Create()
    self:_LoadSavedMessages()
end

function Noir.Services.MessageService:ServiceStart()
    self._OnChatMessageConnection = Noir.Callbacks:Connect("onChatMessage", function(peerID, title, message)
        -- Get author of message (player)
        local author = Noir.Services.PlayerService:GetPlayer(peerID)

        if not author then
            error("MessageService", "Failed to get author of message via 'onChatMessage' callback.")
        end

        -- Register message
        self:_RegisterMessage(
            title,
            message,
            author,
            false,
            nil,
            nil,
            true
        )
    end)
end

--[[
    Load all saved messages.<br>
    Used internally.
]]
function Noir.Services.MessageService:_LoadSavedMessages()
    -- Get messages
    local messages = Noir.Libraries.Table:Copy(self._SavedMessages)

    -- Ensure correct order
    table.sort(messages, function(a, b)
        return a.SentAt < b.SentAt
    end)

    -- Clear saved messages
    self._SavedMessages = {}
    self:Save("Messages", self._SavedMessages)

    -- Register saved messages
    for _, message in pairs(messages) do
        self:_RegisterMessage(
            message.Title,
            message.Content,
            message.Author and Noir.Services.PlayerService:GetPlayer(message.Author),
            message.IsAddon,
            message.SentAt,
            message.Recipient and Noir.Services.PlayerService:GetPlayer(message.Recipient),
            false
        )
    end
end

--[[
    Insert a value into a table, removing the first value if the table is full.<br>
    Used internally.
]]
---@param tbl table
---@param value any
---@param limit integer
function Noir.Services.MessageService:_InsertIntoTable(tbl, value, limit)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_InsertIntoTable()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_InsertIntoTable()", "limit", limit, "number")

    -- Insert
    table.insert(tbl, value)

    -- Remove
    if #tbl > limit then
        table.remove(tbl, 1)
    end
end

--[[
    Register a message.<br>
    Used internally.
]]
---@param title string
---@param content string
---@param author NoirPlayer|nil
---@param isAddon boolean
---@param sentAt number|nil
---@param recipient NoirPlayer|nil
---@param fireEvent boolean|nil
---@return NoirMessage
function Noir.Services.MessageService:_RegisterMessage(title, content, author, isAddon, sentAt, recipient, fireEvent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_RegisterMessage()", "title", title, "string")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_RegisterMessage()", "content", content, "string")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_RegisterMessage()", "author", author, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_RegisterMessage()", "isAddon", isAddon, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_RegisterMessage()", "sentAt", sentAt, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_RegisterMessage()", "recipient", recipient, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_RegisterMessage()", "fireEvent", fireEvent, "boolean", "nil")

    -- Create message
    local message = Noir.Classes.Message:New(
        author,
        isAddon,
        content,
        title,
        sentAt or server.getTimeMillisec(),
        recipient
    )

    -- Register
    self:_InsertIntoTable(self.Messages, message, self._MessageLimit)

    -- Save
    self:_SaveMessage(message)

    -- Fire event
    if fireEvent then
        self.OnMessage:Fire(message)
    end

    -- Return
    return message
end

--[[
    Save a message.<br>
    Used internally.
]]
---@param message NoirMessage
function Noir.Services.MessageService:_SaveMessage(message)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.MessageService:_SaveMessage()", "message", message, Noir.Classes.Message)

    -- Save
    self:_InsertIntoTable(self._SavedMessages, message:_Serialize(), self._MessageLimit)
    self:Save("Messages", self._SavedMessages)
end

--[[
    Send a message to a player or all players.

    Noir.Services.MessageService:SendMessage(nil, "[Server]", "Hello, %s!", "world") -- "[Server] Hello, world!"
]]
---@param player NoirPlayer|nil nil = everyone
---@param title string
---@param content string
---@param ... any
---@return NoirMessage
function Noir.Services.MessageService:SendMessage(player, title, content, ...)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.MessageService:SendMessage()", "player", player, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:SendMessage()", "title", title, "string")
    Noir.TypeChecking:Assert("Noir.Services.MessageService:SendMessage()", "content", content, "string")

    -- Send message
    local formattedContent = ... and content:format(...) or content
    server.announce(title, formattedContent, player and player.ID or -1)

    -- Register message
    local message = self:_RegisterMessage(
        title,
        formattedContent,
        nil,
        true,
        nil,
        player,
        true
    )

    -- Return message
    return message
end

--[[
    Returns all messages sent by a player.
]]
---@param player NoirPlayer
---@return table<integer, NoirMessage>
function Noir.Services.MessageService:GetMessagesByPlayer(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.MessageService:GetMessagesByPlayer()", "player", player, Noir.Classes.Player)

    -- Get messages
    local messages = {}

    for _, message in pairs(self:GetAllMessages()) do
        if message.Author and Noir.Services.PlayerService:IsSamePlayer(player, message.Author) then
            table.insert(messages, message)
        end
    end

    -- Return
    return messages
end

--[[
    Returns all messages.<br>
    Earliest entries in table = Oldest messages
]]
---@param copy boolean|nil Whether or not to copy the table (recommended), but may be slow
---@return table<integer, NoirMessage>
function Noir.Services.MessageService:GetAllMessages(copy)
    Noir.TypeChecking:Assert("Noir.Services.MessageService:GetAllMessages()", "copy", copy, "boolean", "nil")
    return copy and Noir.Libraries.Table:Copy(self.Messages) or self.Messages
end

--------------------------------------------------------
-- [Noir] Services - Notification Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for sending notifications to players.

    -- Notify multiple
    local player1, player2 = Noir.Services.PlayerService:GetPlayer(0), Noir.Services.PlayerService:GetPlayer(1)
    Noir.Services.NotificationService:Info("Money", "Your money is $%d.", {player1, player2}, 1000)

    -- Notify one
    local player = Noir.Services.PlayerService:GetPlayer(0)
    Noir.Services.NotificationService:Info("Money", "Your money is $1000.", player) -- FYI: This is the same message as above

    -- Notify everyone
    Noir.Services.NotificationService:Info("Money", "Your money is $1000.", Noir.Services.PlayerService:GetPlayers())
]]
---@class NoirNotificationService: NoirService
---@field SuccessTitlePrefix string The title prefix for success notifications
---@field WarningTitlePrefix string The title prefix for warning notifications
---@field ErrorTitlePrefix string The title prefix for error notifications
---@field InfoTitlePrefix string The title prefix for info notifications
Noir.Services.NotificationService = Noir.Services:CreateService(
    "NotificationService",
    true,
    "A service for notifying players.",
    "A minimal service for notifying players.",
    {"Cuh4"}
)

function Noir.Services.NotificationService:ServiceInit()
    self.SuccessTitlePrefix = "[Success] "
    self.WarningTitlePrefix = "[Warning] "
    self.ErrorTitlePrefix = "[Error] "
    self.InfoTitlePrefix = "[Info] "
end

--[[
    Notify a player or multiple players.
]]
---@param title string
---@param message string
---@param notificationType SWNotificationTypeEnum
---@param player NoirPlayer|table<integer, NoirPlayer>|nil
---@param ... any
function Noir.Services.NotificationService:Notify(title, message, notificationType, player, ...)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.NotificationService:Notify()", "title", title, "string")
    Noir.TypeChecking:Assert("Noir.Services.NotificationService:Notify()", "message", message, "string")
    Noir.TypeChecking:Assert("Noir.Services.NotificationService:Notify()", "notificationType", notificationType, "number")
    Noir.TypeChecking:Assert("Noir.Services.NotificationService:Notify()", "player", player, Noir.Classes.Player, "table", "nil")

    -- Convert to table if needed
    local players

    if player == nil then
        players = Noir.Services.PlayerService:GetPlayers(true)
    else
        players = (type(player) == "table" and not Noir.Classes.Player:IsClass(player)) and player or {player}
    end

    -- Format message
    local formattedMessage = ... and message:format(...) or message

    -- Notify
    for _, playerToNotify in pairs(players) do
        playerToNotify:Notify(title, formattedMessage, notificationType)
    end
end

--[[
    Send a success notification to a player.
]]
---@param title string
---@param message string
---@param player NoirPlayer|table<integer, NoirPlayer>|nil
---@param ... any
function Noir.Services.NotificationService:Success(title, message, player, ...)
    self:Notify(self.SuccessTitlePrefix..title, message, 4, player, ...)
end

--[[
    Send a warning notification to a player.
]]
---@param title string
---@param message string
---@param player NoirPlayer|table<integer, NoirPlayer>|nil
---@param ... any
function Noir.Services.NotificationService:Warning(title, message, player, ...)
    self:Notify(self.WarningTitlePrefix..title, message, 1, player, ...)
end

--[[
    Send an error notification to a player.
]]
---@param title string
---@param message string
---@param player NoirPlayer|table<integer, NoirPlayer>|nil
---@param ... any
function Noir.Services.NotificationService:Error(title, message, player, ...)
    self:Notify(self.ErrorTitlePrefix..title, message, 3, player, ...)
end

--[[
    Send an info notification to a player.
]]
---@param title string
---@param message string
---@param player NoirPlayer|table<integer, NoirPlayer>|nil
---@param ... any
function Noir.Services.NotificationService:Info(title, message, player, ...)
    self:Notify(self.InfoTitlePrefix..title, message, 7, player, ...)
end

--------------------------------------------------------
-- [Noir] Services - Object Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for wrapping SW objects in classes.

    local object_id = 5
    local object = Noir.Services.ObjectService:GetObject(object_id)

    object:GetData()
    object:Despawn()
    object:GetPosition()
    object:Teleport()

    object.OnLoad:Connect(function()
        -- Code
    end)

    object.OnUnload:Connect(function()
        -- Code
    end)
]]
---@class NoirObjectService: NoirService
---@field Objects table<integer, NoirObject> A table containing all objects
---@field OnRegister NoirEvent Fired when an object is registered. This is NOT when an object spawns, only when this serviec finds an object (first arg: NoirObject)
---@field OnUnregister NoirEvent Fired when an object is unregistered, usually on despawn by this addon (first arg: NoirObject)
---@field OnLoad NoirEvent Fired when an object is loaded (first arg: NoirObject)
---@field OnUnload NoirEvent Fired when an object is unloaded (first arg: NoirObject)
---@field _OnObjectLoadConnection NoirConnection A connection to the onObjectLoad game callback
---@field _OnObjectUnloadConnection NoirConnection A connection to the onObjectUnload game callback
Noir.Services.ObjectService = Noir.Services:CreateService(
    "ObjectService",
    true,
    "A service for wrapping SW objects in classes.",
    "A service for wrapping SW objects in classes as well as providing useful object-related utilities.",
    {"Cuh4"}
)

Noir.Services.ObjectService.InitPriority = 4

function Noir.Services.ObjectService:ServiceInit()
    self.Objects = {}

    self.OnRegister = Noir.Libraries.Events:Create()
    self.OnUnregister = Noir.Libraries.Events:Create()
    self.OnLoad = Noir.Libraries.Events:Create()
    self.OnUnload = Noir.Libraries.Events:Create()

    -- Load saved objects
    self:_LoadObjects()
end

function Noir.Services.ObjectService:ServiceStart()
    -- Listen for object loading/unloading
    self._OnObjectLoadConnection = Noir.Callbacks:Connect("onObjectLoad", function(object_id)
        local object = self:GetObject(object_id) -- creates an object if it doesn't already exist
        self:_OnObjectLoad(object)
    end)

    self._OnObjectUnloadConnection = Noir.Callbacks:Connect("onObjectUnload", function(object_id)
        local object = self:GetObject(object_id)
        self:_OnObjectUnload(object)
    end)
end

--[[
    Load saved objects.<br>
    Used internally. Do not use in your code.
]]
function Noir.Services.ObjectService:_LoadObjects()
    for _, object in pairs(self:_GetSavedObjects()) do
        self:_RegisterObject(object.ID, true)
    end
end

--[[
    Run code that would normally be ran when an object is loaded.<br>
    Used internally. Do not use in your code.
]]
---@param object NoirObject
function Noir.Services.ObjectService:_OnObjectLoad(object)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_OnObjectLoad()", "object", object, Noir.Classes.Object)

    -- Fire event, set loaded
    object.Loaded = true
    object.OnLoad:Fire()
    self.OnLoad:Fire(object)

    -- Save
    self:_SaveObjectSavedata(object)
end

--[[
    Run code that would normally be ran when an object is unloaded.<br>
    Used internally. Do not use in your code.
]]
---@param object NoirObject
function Noir.Services.ObjectService:_OnObjectUnload(object)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_OnObjectUnload()", "object", object, Noir.Classes.Object)

    -- Fire events, set loaded
    object.Loaded = false
    object.OnUnload:Fire()
    self.OnUnload:Fire(object)

    -- Remove from savedata (this should be done when the object is despawned, but it is impossible afaik to find out if this object despawned via this callback)
    self:_RemoveObjectSavedata(object.ID)
end


--[[
    Registers an object by ID.<br>
    Used internally. Use :GetObject() to retrieve an object instead.
]]
---@param object_id integer
---@param _preventEventTrigger boolean|nil
---@return NoirObject
function Noir.Services.ObjectService:_RegisterObject(object_id, _preventEventTrigger)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_RegisterObject()", "object_id", object_id, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_RegisterObject()", "_preventEventTrigger", _preventEventTrigger, "boolean", "nil")

    -- Check if the object exists and is loaded
    local loaded, exists = server.getObjectSimulating(object_id)

    -- Create object
    local object = Noir.Classes.Object:New(object_id)
    object.Loaded = loaded and exists

    self.Objects[object_id] = object

    -- Fire event
    if not _preventEventTrigger then -- this is here for objects that are being registered from g_savedata
        self.OnRegister:Fire(object)
    end

    -- Save to g_savedata
    self:_SaveObjectSavedata(object)

    -- Return
    return object
end

--[[
    Removes the object with the given ID.<br>
    Used internally. Do not use in your code.
]]
---@param object NoirObject
function Noir.Services.ObjectService:_RemoveObject(object)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_RemoveObject()", "object", object, Noir.Classes.Object)

    -- Fire event
    object.OnUnregister:Fire()
    self.OnUnregister:Fire(object)

    -- Remove object
    self.Objects[object.ID] = nil

    -- Remove from g_savedata
    self:_RemoveObjectSavedata(object.ID)
end

--[[
    Overwrite saved objects.<br>
    Used internally. Do not use in your code.
]]
---@param objects table<integer, NoirSerializedObject>
function Noir.Services.ObjectService:_SaveObjects(objects)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_SaveObjects()", "objects", objects, "table")

    -- Save to g_savedata
    self:Save("objects", objects)
end

--[[
    Get saved objects.<br>
    Used internally. Do not use in your code.
]]
---@return table<integer, NoirSerializedObject>
function Noir.Services.ObjectService:_GetSavedObjects()
    return Noir.Libraries.Table:Copy(self:Load("objects", {}))
end

--[[
    Save an object to g_savedata.<br>
    Used internally. Do not use in your code.
]]
---@param object NoirObject
function Noir.Services.ObjectService:_SaveObjectSavedata(object)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_SaveObjectSavedata()", "object", object, Noir.Classes.Object)

    -- Save to g_savedata
    local saved = self:_GetSavedObjects()
    saved[object.ID] = object:_Serialize()

    self:_SaveObjects(saved)
end

--[[
    Remove an object from g_savedata.<br>
    Used internally. Do not use in your code.
]]
---@param object_id integer
function Noir.Services.ObjectService:_RemoveObjectSavedata(object_id)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:_RemoveObjectSavedata()", "object_id", object_id, "number")

    -- Remove from g_savedata
    local saved = self:_GetSavedObjects()
    saved[object_id] = nil

    self:_SaveObjects(saved)
end

--[[
    Get all objects.
]]
---@return table<integer, NoirObject>
function Noir.Services.ObjectService:GetObjects()
    return Noir.Libraries.Table:Copy(self.Objects)
end

--[[
    Returns the object with the given ID.
]]
---@param object_id integer
---@return NoirObject
function Noir.Services.ObjectService:GetObject(object_id)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:GetObject()", "object_id", object_id, "number")

    -- Get object
    return self.Objects[object_id] or self:_RegisterObject(object_id)
end

--[[
    Spawn an object.
]]
---@param objectType SWObjectTypeEnum
---@param position SWMatrix
---@return NoirObject
function Noir.Services.ObjectService:SpawnObject(objectType, position)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnObject()", "objectType", objectType, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnObject()", "position", position, "table")

    -- Spawn the object
    local object_id, success = server.spawnObject(position, objectType)

    if not success then
        error("ObjectService:SpawnObject()", "server.spawnObject() was unsuccessful. is `objectType` valid?")
    end

    -- Wrap object in a class
    local object = self:GetObject(object_id)

    if not object then
        error("ObjectService:SpawnObject()", ":GetObject() returned nil.")
    end

    -- Return
    return object
end

--[[
    Spawn a character.
]]
---@param outfitType SWOutfitTypeEnum
---@param position SWMatrix
---@return NoirObject
function Noir.Services.ObjectService:SpawnCharacter(outfitType, position)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnCharacter()", "outfitType", outfitType, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnCharacter()", "position", position, "table")

    -- Spawn the character
    local object_id, success = server.spawnCharacter(position, outfitType)

    if not success then
        error("ObjectService:SpawnCharacter()", "server.spawnCharacter() was unsuccessful. Is `outfitType` valid?")
    end

    -- Wrap object in a class
    local object = self:GetObject(object_id)

    if not object then
        error("ObjectService:SpawnCharacter()", ":GetObject() returned nil.")
    end

    -- Return
    return object
end

--[[
    Spawn a creature.
]]
---@param creatureType SWCreatureTypeEnum
---@param position SWMatrix
---@param sizeMultiplier number|nil Default: 1
---@return NoirObject
function Noir.Services.ObjectService:SpawnCreature(creatureType, position, sizeMultiplier)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnCreature()", "creatureType", creatureType, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnCreature()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnCreature()", "sizeMultiplier", sizeMultiplier, "number", "nil")

    -- Spawn the creature
    local object_id, success = server.spawnCreature(position, creatureType, sizeMultiplier or 1)

    if not success then
        error("ObjectService:SpawnCreature()", "server.spawnCreature() was unsuccessful. is `creatureType` valid?")
    end

    -- Wrap object in a class
    local object = self:GetObject(object_id)

    if not object then
        error("ObjectService:SpawnCreature()", ":GetObject() returned nil.")
    end

    -- Return
    return object
end

--[[
    Spawn an animal.
]]
---@param animalType SWAnimalTypeEnum
---@param position SWMatrix
---@param sizeMultiplier number|nil Default: 1
---@return NoirObject
function Noir.Services.ObjectService:SpawnAnimal(animalType, position, sizeMultiplier)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnAnimal()", "animalType", animalType, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnAnimal()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnAnimal()", "sizeMultiplier", sizeMultiplier, "number", "nil")

    -- Spawn the animal
    local object_id, success = server.spawnAnimal(position, animalType, sizeMultiplier or 1)

    if not success then
        error("ObjectService:SpawnAnimal()", "server.spawnAnimal() was unsuccessful. Is `animalType` valid?")
    end

    -- Wrap object in a class
    local object = self:GetObject(object_id)

    if not object then
        error("ObjectService:SpawnAnimal()", ":GetObject() returned nil.")
    end

    -- Return
    return object
end

--[[
    Spawn an equipment item.
]]
---@param equipmentType SWEquipmentTypeEnum
---@param position SWMatrix
---@param int integer
---@param float integer
---@return NoirObject
function Noir.Services.ObjectService:SpawnEquipment(equipmentType, position, int, float)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnEquipment()", "equipmentType", equipmentType, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnEquipment()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnEquipment()", "int", int, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnEquipment()", "float", float, "number")

    -- Spawn the equipment
    local object_id, success = server.spawnEquipment(position, equipmentType, int, float)

    if not success then
        error("ObjectService:SpawnEquipment()", "server.spawnEquipment() was unsuccessful. Is `equipmentType` valid?")
    end

    -- Wrap object in a class
    local object = self:GetObject(object_id)

    if not object then
        error("ObjectService:SpawnEquipment()", ":GetObject() returned nil.")
    end

    -- Return
    return object
end

--[[
    Spawn a fire.
]]
---@param position SWMatrix
---@param size number 0 - 10
---@param magnitude number -1 explodes instantly. Nearer to 0 means the explosion takes longer to happen. Must be below 0 for explosions to work.
---@param isLit boolean Lights the fire. If the magnitude is >1, this will need to be true for the fire to first warm up before exploding.
---@param isExplosive boolean
---@param parentBody NoirBody|nil
---@param explosionMagnitude number The size of the explosion (0-5)
---@return NoirObject
function Noir.Services.ObjectService:SpawnFire(position, size, magnitude, isLit, isExplosive, parentBody, explosionMagnitude)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnFire()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnFire()", "size", size, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnFire()", "magnitude", magnitude, "number")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnFire()", "isLit", isLit, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnFire()", "isExplosive", isExplosive, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnFire()", "parentBody", parentBody, Noir.Classes.Body, "nil")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnFire()", "explosionMagnitude", explosionMagnitude, "number")

    -- Spawn the fire
    local object_id, success = server.spawnFire(position, size, magnitude, isLit, isExplosive, parentBody and parentBody.ID or 0, explosionMagnitude)

    if not success then
        error("ObjectService:SpawnFire()", "server.spawnFire() was unsuccessful. Ensure the provided parameters are correct.")
    end

    -- Wrap object in a class
    local object = self:GetObject(object_id)

    if not object then
        error("ObjectService:SpawnFire()", ":GetObject() returned nil.")
    end

    -- Return
    return object
end

--[[
    Spawn an explosion.
]]
---@param position SWMatrix
---@param magnitude number 0-1
function Noir.Services.ObjectService:SpawnExplosion(position, magnitude)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnExplosion()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.ObjectService:SpawnExplosion()", "magnitude", magnitude, "number")

    -- Spawn the explosion
    server.spawnExplosion(position, magnitude)
end

--------------------------------------------------------
-- [Noir] Services - Player Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service that wraps SW players in a class. Essentially makes players OOP.

    local player = Noir.Services.PlayerService:GetPlayer(0)
    player:IsAdmin() -- true
    player:Teleport(matrix.translation(10, 0, 10))

    ---@param player NoirPlayer
    Noir.Services.PlayerService.OnJoin:Once(function(player) -- Ban the first player who joins
        player:Ban()
    end)
]]
---@class NoirPlayerService: NoirService
---@field OnJoin NoirEvent Arguments: player (NoirPlayer) | Fired when a player joins the server
---@field OnLeave NoirEvent Arguments: player (NoirPlayer) | Fired when a player leaves the server
---@field OnDie NoirEvent Arguments: player (NoirPlayer) | Fired when a player dies
---@field OnSit NoirEvent Arguments: player (NoirPlayer), body (NoirBody|nil), seatName (string) | Fired when a player sits in a seat (body can be nil if the player sat on a map object, etc)
---@field OnUnsit NoirEvent Arguments: player (NoirPlayer), body (NoirBody|nil), seatName (string) | Fired when a player unsits in a seat (body can be nil if the player sat on a map object, etc)
---@field OnRespawn NoirEvent Arguments: player (NoirPlayer) | Fired when a player respawns
---@field Players table<integer, NoirPlayer> The players in the server
---@field _JoinCallback NoirConnection A connection to the onPlayerDie event
---@field _LeaveCallback NoirConnection A connection to the onPlayerLeave event
---@field _DieCallback NoirConnection A connection to the onPlayerDie event
---@field _RespawnCallback NoirConnection A connection to the onPlayerRespawn event
---@field _SitCallback NoirConnection A connection to the onPlayerSit event
---@field _UnsitCallback NoirConnection A connection to the onPlayerUnsit event
Noir.Services.PlayerService = Noir.Services:CreateService(
    "PlayerService",
    true,
    "A service that wraps SW players in a class.",
    "A service that wraps SW players in a class following an OOP format. Player data persistence across addon reloads is also handled, and player-related events are provided.",
    {"Cuh4"}
)

Noir.Services.PlayerService.InitPriority = 1

function Noir.Services.PlayerService:ServiceInit()
    self.OnJoin = Noir.Libraries.Events:Create()
    self.OnLeave = Noir.Libraries.Events:Create()
    self.OnDie = Noir.Libraries.Events:Create()
    self.OnRespawn = Noir.Libraries.Events:Create()
    self.OnSit = Noir.Libraries.Events:Create()
    self.OnUnsit = Noir.Libraries.Events:Create()

    self.Players = {}

    self:GetSaveData().PlayerProperties = self:_GetSavedProperties() or {}
    self:GetSaveData().RecognizedIDs = self:GetSaveData().RecognizedIDs or {}

    -- Load players in game
    if Noir.AddonReason == "AddonReload" then -- Only load players in-game if the addon was reloaded, otherwise onPlayerJoin will be called for the players that join when the save is loaded/created and we can just listen for that
        self:_LoadPlayers()
    end
end

function Noir.Services.PlayerService:ServiceStart()
    -- Create callbacks
    self._JoinCallback = Noir.Callbacks:Connect("onPlayerJoin", function(steam_id, name, peer_id, admin, auth)
        -- Give data
        local player = self:_GivePlayerData(steam_id, name, peer_id, admin, auth)

        if not player then
            return
        end

        -- Call join event
        self.OnJoin:Fire(player)
    end)

    self._LeaveCallback = Noir.Callbacks:Connect("onPlayerLeave", function(steam_id, name, peer_id, admin, auth)
        -- Get player
        local player = self:GetPlayer(peer_id)

        if not player then -- likely unnamed client
            return
        end

        -- Remove player
        self:_RemovePlayerData(player)

        -- Call leave event
        self.OnLeave:Fire(player)
    end)

    self._DieCallback = Noir.Callbacks:Connect("onPlayerDie", function(steam_id, name, peer_id, admin, auth)
        -- Get player
        local player = self:GetPlayer(peer_id)

        if not player then
            error("PlayerService", "A player just died, but they don't have data.")
        end

        -- Call die event
        self.OnDie:Fire(player)
    end)

    self._RespawnCallback = Noir.Callbacks:Connect("onPlayerRespawn", function(peer_id)
        -- Get player
        local player = self:GetPlayer(peer_id)

        if not player then
            error("PlayerService", "A player just respawned, but they don't have data.")
        end

        -- Call respawn event
        self.OnRespawn:Fire(player)
    end)

    self._SitCallback = Noir.Callbacks:Connect("onPlayerSit", function(peer_id, vehicle_id, seat_name)
        -- Get player
        local player = self:GetPlayer(peer_id)

        if not player then
            error("PlayerService", "A player just sat in a body, but they don't have data.")
        end

        -- Get body
        local body = Noir.Services.VehicleService:GetBody(vehicle_id) -- can be nil if the player sat on a bed on the map

        -- Call sit event
        self.OnSit:Fire(player, body, seat_name)
    end)

    self._UnsitCallback = Noir.Callbacks:Connect("onPlayerUnsit", function(peer_id, vehicle_id, seat_name)
        -- Get player
        local player = self:GetPlayer(peer_id)

        if not player then
            error("PlayerService", "A player just got up from a body seat, but they don't have data.")
        end

        -- Get body
        local body = Noir.Services.VehicleService:GetBody(vehicle_id) -- can be nil if the player sat on a bed on the map

        -- Call unsit event
        self.OnUnsit:Fire(player, body, seat_name)
    end)
end

--[[
    Load players current in-game.
]]
function Noir.Services.PlayerService:_LoadPlayers()
    for _, player in pairs(server.getPlayers()) do
        -- Check if server
        if player.steam_id == 0 then
            goto continue
        end

        -- Check if unnamed client
        if player.name == "unnamed client" and not player.object_id then -- i don't like this. what if a player actually has their name as unnamed client? i'm also not entirely sure if actual players have an object_id when loading in
            return
        end

        -- Check if already loaded
        if self:GetPlayer(player.id) then
            goto continue
        end

        -- Give data
        local createdPlayer = self:_GivePlayerData(player.steam_id, player.name, player.id, player.admin, player.auth)

        if not createdPlayer then
            error("PlayerService:_LoadPlayers()", "Player data creation failed.")
        end

        -- Load saved properties (eg: permissions)
        local savedProperties = self:_GetSavedPropertiesForPlayer(createdPlayer)

        if savedProperties then
            for property, value in pairs(savedProperties) do
                createdPlayer[property] = value
            end
        end

        -- Call onJoin if unrecognized
        if not self:_IsRecognized(createdPlayer) then
            self.OnJoin:Fire(createdPlayer)
        end

        ::continue::
    end

    self:_ClearRecognized() -- prevent table getting massive over time, especially on popular saves
end

--[[
    Gives data to a player.<br>
    Used internally.
]]
---@param steam_id integer|string
---@param name string
---@param peer_id integer
---@param admin boolean
---@param auth boolean
---@return NoirPlayer|nil
function Noir.Services.PlayerService:_GivePlayerData(steam_id, name, peer_id, admin, auth)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_GivePlayerData()", "steam_id", steam_id, "number", "string")
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_GivePlayerData()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_GivePlayerData()", "peer_id", peer_id, "number")
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_GivePlayerData()", "admin", admin, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_GivePlayerData()", "auth", auth, "boolean")

    -- Check if the player is the server itself (applies to dedicated servers)
    if self:_IsHost(peer_id) then
        return
    end

    -- Check if player already exists
    if self:GetPlayer(peer_id) then
        error("PlayerService:_GivePlayerData()", "Attempted to give data to a player that already exists.")
    end

    -- Create player
    local player = Noir.Classes.Player:New(
        name,
        peer_id,
        tostring(steam_id),
        admin,
        auth,
        {}
    )

    -- Save player
    self.Players[peer_id] = player

    -- Save peer ID so we know if we can call onJoin for this player or not if the addon reloads
    self:_MarkRecognized(player)

    -- Return
    return player
end

--[[
    Removes data for a player.<br>
    Used internally.
]]
---@param player NoirPlayer
function Noir.Services.PlayerService:_RemovePlayerData(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_RemovePlayerData()", "player", player, Noir.Classes.Player)

    -- Check if player exists in this service
    if not self:GetPlayer(player.ID) then
        error("PlayerService:_RemovePlayerData()", "Attempted to remove a player from the service that isn't in the service.")
    end

    -- Remove player
    player.InGame = false
    self.Players[player.ID] = nil

    -- Remove saved properties
    self:_RemoveSavedProperties(player)

    -- Unmark as recognized
    self:_UnmarkRecognized(player)
end

--[[
    Returns whether or not a player is the server's host. Only applies in dedicated servers.<br>
    Used internally.
]]
---@param peer_id integer
---@return boolean
function Noir.Services.PlayerService:_IsHost(peer_id)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_IsHost()", "peer_id", peer_id, "number")

    -- Return true if the provided peer_id is that of the server host player
    return peer_id == 0 and Noir.IsDedicatedServer
end

--[[
    Mark a player as recognized to prevent onJoin being called for them after an addon reload.<br>
    Used internally.
]]
---@param player NoirPlayer
function Noir.Services.PlayerService:_MarkRecognized(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_MarkRecognized()", "player", player, Noir.Classes.Player)

    -- Mark as recognized
    self:GetSaveData().RecognizedIDs[player.ID] = true
end

--[[
    Returns whether or not a player is recognized.<br>
    Used internally.
]]
---@param player NoirPlayer
---@return boolean
function Noir.Services.PlayerService:_IsRecognized(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_IsRecognized()", "player", player, Noir.Classes.Player)

    -- Return true if recognized
    return self:GetSaveData().RecognizedIDs[player.ID] ~= nil
end

--[[
    Clear the list of recognized players.<br>
    Used internally.
]]
function Noir.Services.PlayerService:_ClearRecognized()
    self:GetSaveData().RecognizedIDs = {}
end

--[[
    Mark a player as not recognized.<br>
    Used internally.
]]
---@param player NoirPlayer
function Noir.Services.PlayerService:_UnmarkRecognized(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_UnmarkRecognized()", "player", player, Noir.Classes.Player)

    -- Remove from recognized
    self:GetSaveData().RecognizedIDs[player.ID] = nil
end

--[[
    Returns all saved player properties saved in g_savedata.<br>
    Used internally. Do not use in your code.
]]
---@return NoirSavedPlayerProperties
function Noir.Services.PlayerService:_GetSavedProperties()
    return self:GetSaveData().PlayerProperties
end

--[[
    Save a player's property to g_savedata.<br>
    Used internally. Do not use in your code.
]]
---@param player NoirPlayer
---@param property string
function Noir.Services.PlayerService:_SaveProperty(player, property)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_SaveProperty()", "player", player, Noir.Classes.Player)
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_SaveProperty()", "property", property, "string")

    -- Property saving
    local properties = self:_GetSavedProperties()

    if not properties[player.ID] then
        properties[player.ID] = {}
    end

    properties[player.ID][property] = player[property]
end

--[[
    Get a player's saved properties.<br>
    Used internally. Do not use in your code.
]]
---@param player NoirPlayer
---@return table<string, boolean>|nil
function Noir.Services.PlayerService:_GetSavedPropertiesForPlayer(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_GetSavedPropertiesForPlayer()", "player", player, Noir.Classes.Player)

    -- Return saved properties for player
    return self:_GetSavedProperties()[player.ID]
end

--[[
    Removes a player's saved properties from g_savedata.<br>
    Used internally. Do not use in your code.
]]
---@param player NoirPlayer
function Noir.Services.PlayerService:_RemoveSavedProperties(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:_RemoveSavedProperties()", "player", player, Noir.Classes.Player)

    -- Remove saved properties
    local properties = self:_GetSavedProperties()
    properties[player.ID] = nil
end

--[[
    Returns all players.<br>
    This is the preferred way to get all players instead of using `Noir.Services.PlayerService.Players`.
]]
---@param usePeerIDsAsIndex boolean|nil If true, the indices of the returned table will match the peer ID of the value (player) matched to the index. Having this as true is slightly faster
---@return table<integer, NoirPlayer>
function Noir.Services.PlayerService:GetPlayers(usePeerIDsAsIndex)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:GetPlayers()", "usePeerIDsAsIndex", usePeerIDsAsIndex, "boolean", "nil")

    -- Return players
    return usePeerIDsAsIndex and self.Players or Noir.Libraries.Table:Values(self.Players)
end

--[[
    Returns a player by their peer ID.<br>
    This is the preferred way to get a player.
]]
---@param ID integer
---@return NoirPlayer|nil
function Noir.Services.PlayerService:GetPlayer(ID)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:GetPlayer()", "ID", ID, "number")

    -- Return player if any
    return self:GetPlayers(true)[ID]
end

--[[
    Returns a player by their Steam ID.<br>
    Note that two players or more can have the same Steam ID if they spoof their Steam ID or join the server on two Stormworks instances.
]]
---@param steam string
---@return NoirPlayer|nil
function Noir.Services.PlayerService:GetPlayerBySteam(steam)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:GetPlayerBySteam()", "steam", steam, "string")

    -- Get player
    for _, player in pairs(self:GetPlayers(true)) do
        if player.Steam == steam then
            return player
        end
    end
end

--[[
    Returns a player by their exact name.<br>
    Consider using `:SearchPlayerByName()` if the player name only needs to match partially.
]]
---@param name string
---@return NoirPlayer|nil
function Noir.Services.PlayerService:GetPlayerByName(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:GetPlayerByName()", "name", name, "string")

    -- Get player
    for _, player in pairs(self:GetPlayers(true)) do
        if player.Name == name then
            return player
        end
    end
end

--[[
    Get a player by their character.
]]
---@param character NoirObject
---@return NoirPlayer|nil
function Noir.Services.PlayerService:GetPlayerByCharacter(character)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:GetPlayerByCharacter()", "character", character, Noir.Classes.Object)

    -- Get player
    for _, player in pairs(self:GetPlayers(true)) do
        if player:GetCharacter() == character then
            return player
        end
    end
end

--[[
    Searches for a player by their name, similar to a Google search but way simpler under the hood.
]]
---@param name string
---@return NoirPlayer|nil
function Noir.Services.PlayerService:SearchPlayerByName(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:SearchPlayerByName()", "name", name, "string")

    -- Get player
    for _, player in pairs(self:GetPlayers(true)) do
        if player.Name:lower():gsub(" ", ""):find(name:lower():gsub(" ", "")) then
            return player
        end
    end
end

--[[
    Returns whether or not two players are the same.
]]
---@param playerA NoirPlayer
---@param playerB NoirPlayer
---@return boolean
function Noir.Services.PlayerService:IsSamePlayer(playerA, playerB)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:IsSamePlayer()", "playerA", playerA, Noir.Classes.Player)
    Noir.TypeChecking:Assert("Noir.Services.PlayerService:IsSamePlayer()", "playerB", playerB, Noir.Classes.Player)

    -- Return if both players are the same
    return playerA.ID == playerB.ID
end

-------------------------------
-- // Intellisense
-------------------------------

---@alias NoirSavedPlayerProperties table<integer, table<string, any>>

--------------------------------------------------------
-- [Noir] Services - Task Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for easily delaying or repeating tasks.

    local task = Noir.Services.TaskService:AddTask(function(toSay)
        server.announce("Server", toSay)
    end, 5, {"Hello World!"}, true) -- This task is repeating due to isRepeating being true (final argument)

    task:SetDuration(10) -- Duration changes from 5 to 10
]]
---@class NoirTaskService: NoirService
---@field Ticks integer The amount of `onTick` calls
---@field DeltaTicks number The amount of ticks that have technically passed since the last tick
---@field Tasks table<integer, NoirTask> A table containing active tasks
---@field _TaskID integer The ID of the most recent task
---@field TickIterationProcesses table<integer, NoirTickIterationProcess> A table of tick iteration processes
---@field _TickIterationProcessID integer The ID of the most recent tick iteration process
---@field _TaskTypeHandlers table<NoirTaskType, fun(task: NoirTask)>
---@field _OnTickConnection NoirConnection Represents the connection to the onTick game callback
Noir.Services.TaskService = Noir.Services:CreateService(
    "TaskService",
    true,
    "A service for calling functions after x amount of seconds.",
    "A service that allows you to call functions after x amount of seconds, either repeatedly or once.",
    {"Cuh4"}
)

function Noir.Services.TaskService:ServiceInit()
    -- Create attributes
    self.Ticks = 0
    self.DeltaTicks = 0

    self.Tasks = {}
    self._TaskID = 0

    self.TickIterationProcesses = {}
    self._TickIterationProcessID = 0

    self._TaskTypeHandlers = {}

    -- Create task handlers
    self._TaskTypeHandlers["Time"] = function(task)
        local time = self:GetTimeSeconds()

        if time < task.StopsAt then
            return
        end

        if task.IsRepeating then
            task.StartedAt = time
            task.StopsAt = time + task.Duration

            task.OnCompletion:Fire(table.unpack(task.Arguments))
        else
            self:RemoveTask(task)
            task.OnCompletion:Fire(table.unpack(task.Arguments))
        end
    end

    self._TaskTypeHandlers["Ticks"] = function(task)
        if self.Ticks < task.StopsAt then
            return
        end

        if task.IsRepeating then
            task.StartedAt = self.Ticks
            task.StopsAt = self.Ticks + task.Duration

            task.OnCompletion:Fire(table.unpack(task.Arguments))
        else
            self:RemoveTask(task)
            task.OnCompletion:Fire(table.unpack(task.Arguments))
        end
    end
end

function Noir.Services.TaskService:ServiceStart()
    -- Connect to onTick
    self._OnTickConnection = Noir.Callbacks:Connect("onTick", function(ticks)
        -- Increment ticks
        self.Ticks = self.Ticks + ticks
        self.DeltaTicks = ticks

        -- Handle tick iteration processes
        self:_HandleTickIterationProcesses()

        -- Check tasks
        self:_HandleTasks()
    end)
end

--[[
    Handles tick iteration processes.<br>
    Used internally.
]]
function Noir.Services.TaskService:_HandleTickIterationProcesses()
    for _, tickIterationProcess in pairs(self:GetTickIterationProcesses(true)) do
        if tickIterationProcess.Completed then
            self:RemoveTickIterationProcess(tickIterationProcess)
        else
            tickIterationProcess:Iterate()
        end
    end
end

--[[
    Handles tasks.<br>
    Used internally.
]]
function Noir.Services.TaskService:_HandleTasks()
    for _, task in pairs(self:GetTasks(true)) do
        if not self:_IsValidTaskType(task.TaskType) then
            error("TaskService:_HandleTasks()", "Task #%d has an invalid task type of '%s'. Please ensure when creating a task, you use the correct type (assuming you're using `:_AddTask()`)", task.ID, task.TaskType)
        end

        local handler = self._TaskTypeHandlers[task.TaskType]
        handler(task)

        ::continue::
    end
end

--[[
    Add a task to the TaskService.<br>
    Used internally.
]]
---@param callback function
---@param duration number
---@param arguments table
---@param isRepeating boolean
---@param taskType NoirTaskType
---@param startedAt number
---@return NoirTask
function Noir.Services.TaskService:_AddTask(callback, duration, arguments, isRepeating, taskType, startedAt)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:_AddTask()", "callback", callback, "function")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:_AddTask()", "duration", duration, "number")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:_AddTask()", "arguments", arguments, "table")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:_AddTask()", "isRepeating", isRepeating, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:_AddTask()", "taskType", taskType, "string")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:_AddTask()", "startedAt", startedAt, "number")

    -- Check task type
    if not self:_IsValidTaskType(taskType) then
        error("TaskService:_AddTask()", "Invalid task type of '%s'. Please ensure when creating a task, you use the correct type.", taskType)
    end

    -- Increment ID
    self._TaskID = self._TaskID + 1

    -- Create task
    local task = Noir.Classes.Task:New(self._TaskID, taskType, duration, isRepeating, arguments, startedAt)
    task.OnCompletion:Connect(callback)

    self.Tasks[task.ID] = task

    -- Return the task
    return task
end

--[[
    Returns whether or not a task type is valid.<br>
    Used internally.
]]
---@param taskType string
---@return boolean
function Noir.Services.TaskService:_IsValidTaskType(taskType)
    return self._TaskTypeHandlers[taskType] ~= nil
end

--[[
    Returns the current time in seconds.<br>
    Equivalent to: server.getTimeMillisec() / 1000
]]
---@return number
function Noir.Services.TaskService:GetTimeSeconds()
    return server.getTimeMillisec() / 1000
end

--[[
    Creates and adds a task to the TaskService using the task type `"Time"`.<br>
    This is less accurate than the other task types as it uses time to determine when to run the task. This is more convenient though.

    local task = Noir.Services.TaskService:AddTimeTask(function(toSay)
        server.announce("Server", toSay)
    end, 5, {"Hello World!"}, true) -- This task is repeating due to isRepeating being true (final argument)

    local anotherTask = Noir.Services.TaskService:AddTimeTask(server.announce, 5, {"Server", "Hello World!"}, true) -- This does the same as above
    Noir.Services.TaskService:RemoveTask(anotherTask) -- Removes the task
]]
---@param callback function
---@param duration number In seconds
---@param arguments table|nil
---@param isRepeating boolean|nil
---@return NoirTask
function Noir.Services.TaskService:AddTimeTask(callback, duration, arguments, isRepeating)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTimeTask()", "callback", callback, "function")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTimeTask()", "duration", duration, "number")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTimeTask()", "arguments", arguments, "table", "nil")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTimeTask()", "isRepeating", isRepeating, "boolean", "nil")

    -- Create task
    local task = self:_AddTask(callback, duration, arguments or {}, isRepeating or false, "Time", self:GetTimeSeconds())
    return task
end

--[[
    This is deprecated. Please use `:AddTimeTask()`.
]]
---@deprecated
---@param callback function
---@param duration number In seconds
---@param arguments table|nil
---@param isRepeating boolean|nil
---@return NoirTask
function Noir.Services.TaskService:AddTask(callback, duration, arguments, isRepeating)
    -- Deprecation
    Noir.Libraries.Deprecation:Deprecated("Noir.Services.TaskService:AddTask()", ":AddTimeTask()", "Due to the addition of task types, this method has been deprecated.")

    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTask()", "callback", callback, "function")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTask()", "duration", duration, "number")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTask()", "arguments", arguments, "table", "nil")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTask()", "isRepeating", isRepeating, "boolean", "nil")

    -- Create task
    return self:AddTimeTask(callback, duration, arguments, isRepeating)
end

--[[
    Creates and adds a task to the TaskService using the task type `"Ticks"`.<br>
    This is more accurate as it uses ticks to determine when to run the task.<br>
    It is highly recommended to multiply any calculations by `Noir.Services.TaskService.DeltaTicks` to account for when all players sleep.

    local last = Noir.Services.TaskService:GetTimeSeconds()
    local time = 0

    Noir.Services.TaskService:AddTickTask(function()
        local now = Noir.Services.TaskService:GetTimeSeconds()
        time = time + ((now - last) * Noir.Services.TaskService.DeltaTicks)
        last = now

        print(("%.1f seconds passed"):format(time))
    end, 1, nil, true) -- This task reoeats every tick
]]
---@param callback function
---@param duration integer In ticks
---@param arguments table|nil
---@param isRepeating boolean|nil
---@return NoirTask
function Noir.Services.TaskService:AddTickTask(callback, duration, arguments, isRepeating)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTickTask()", "callback", callback, "function")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTickTask()", "duration", duration, "number")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTickTask()", "arguments", arguments, "table", "nil")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:AddTickTask()", "isRepeating", isRepeating, "boolean", "nil")

    -- Create task
    local task = self:_AddTask(callback, duration, arguments or {}, isRepeating or false, "Ticks", self.Ticks)
    return task
end

--[[
    Converts seconds to ticks, accounting for TPS.

    local ticks = Noir.Services.TaskService:SecondsToTicks(2)
    print(ticks) -- 120 (assuming TPS is 60)
]]
---@param seconds integer
---@return integer
function Noir.Services.TaskService:SecondsToTicks(seconds)
    Noir.TypeChecking:Assert("Noir.Services.TaskService:SecondsToTicks()", "seconds", seconds, "number")
    return math.floor(seconds * Noir.Services.TPSService:GetTPS())
end

--[[
    Converts ticks to seconds, accounting for TPS.

    local seconds = Noir.Services.TaskService:TicksToSeconds(120)
    print(seconds) -- 2 (assuming TPS is 60)
]]
---@param ticks integer
---@return number
function Noir.Services.TaskService:TicksToSeconds(ticks)
    Noir.TypeChecking:Assert("Noir.Services.TaskService:TicksToSeconds()", "ticks", ticks, "number")
    return ticks / Noir.Services.TPSService:GetTPS()
end

--[[
    Returns all active tasks.
]]
---@param copy boolean|nil
---@return table<integer, NoirTask>
function Noir.Services.TaskService:GetTasks(copy)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:GetTasks()", "copy", copy, "boolean", "nil")

    -- Return tasks
    return copy and Noir.Libraries.Table:Copy(self.Tasks) or self.Tasks
end

--[[
    Removes a task.
]]
---@param task NoirTask
function Noir.Services.TaskService:RemoveTask(task)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:RemoveTask()", "task", task, Noir.Classes.Task)

    -- Remove task
    self.Tasks[task.ID] = nil
end

--[[
    Iterate a table over how many necessary ticks in chunks of x.<br>
    Useful for iterating through large tables without freezes due to taking too long in a tick.<br>
    Works for sequential and non-sequential tables, although **order is NOT guaranteed**.

    local tbl = {}

    for value = 1, 100000 do
        table.insert(tbl, value)
    end

    Noir.Services.TaskService:IterateOverTicks(tbl, 1000, function(value, currentTick, completed)
        print(value)
    end)
]]
---@param tbl table<integer, any>
---@param chunkSize integer How many values to iterate per tick
---@param callback fun(index: any, value: any, currentTick: integer|nil, completed: boolean|nil) `currentTick` and `completed` are never nil. this is just to mark the paramters as optional
---@return NoirTickIterationProcess
function Noir.Services.TaskService:IterateOverTicks(tbl, chunkSize, callback)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:IterateOverTicks()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:IterateOverTicks()", "chunkSize", chunkSize, "number")
    Noir.TypeChecking:Assert("Noir.Services.TaskService:IterateOverTicks()", "callback", callback, "function")

    -- Increment ID
    self._TickIterationProcessID = self._TickIterationProcessID + 1

    -- Create iteration process
    local iterationProcess = Noir.Classes.TickIterationProcess:New(self._TickIterationProcessID, tbl, chunkSize)
    iterationProcess.IterationEvent:Connect(callback)

    -- Store iteration process
    self.TickIterationProcesses[self._TickIterationProcessID] = iterationProcess

    -- Return iteration
    return iterationProcess
end

--[[
    Get all active tick iteration processes.
]]
---@param copy boolean|nil
---@return table<integer, NoirTickIterationProcess>
function Noir.Services.TaskService:GetTickIterationProcesses(copy)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:GetTickIterationProcesses()", "copy", copy, "boolean", "nil")

    -- Return tick iteration processes
    return copy and Noir.Libraries.Table:Copy(self.TickIterationProcesses) or self.TickIterationProcesses
end

--[[
    Removes a tick iteration process.
]]
---@param tickIterationProcess NoirTickIterationProcess
function Noir.Services.TaskService:RemoveTickIterationProcess(tickIterationProcess)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TaskService:RemoveTickIterationProcess()", "tickIterationProcess", tickIterationProcess, Noir.Classes.TickIterationProcess)

    -- Remove iteration process
    self.TickIterationProcesses[tickIterationProcess.ID] = nil
end

--------------------------------------------------------
-- [Noir] Services - TPS Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for retrieving the TPS (Ticks Per Second) of the server.
    TPS calculations are from Trapdoor: https://discord.com/channels/357480372084408322/905791966904729611/1270333300635992064 - https://discord.gg/stormworks

    Noir.Services.TPSService:GetTPS() -- 62.0
    Noir.Services.TPSService:GetAverageTPS() -- 61.527...
    Noir.Services.TPSService:SetPrecision(10) -- The average TPS will now be calculated every 10 ticks, meaning higher accuracy but slower
]]
---@class NoirTPSService: NoirService
---@field TPS number The TPS of the server, this accounts for sped up time which happens when all players sleep
---@field AverageTPS number The average TPS of the server, this accounts for sped up time which happens when all players sleep
---@field RawTPS number The raw TPS of the server, this doesn't account for sped up time which happens when all players sleep
---@field DesiredTPS number The desired TPS. This service will slow the game enough to achieve this. 0 = disabled
---@field _AverageTPSPrecision integer Tick rate for calculating the average TPS. Higher = more accurate, but will mean more iterations per tick. Use :SetPrecision() to modify
---@field _AverageTPSAccumulation table<integer, integer> TPS over time. Gets cleared after it is filled enough
---@field _Last number The last time the TPS was calculated
---@field _OnTickConnection NoirConnection Represents the connection to the onTick game callback
Noir.Services.TPSService = Noir.Services:CreateService(
    "TPSService",
    true,
    "A service for gathering the TPS of the server.",
    "A minimal service for gathering the TPS of the server. The average TPS can also be retrieved.",
    {"Cuh4"}
)

function Noir.Services.TPSService:ServiceInit()
    self.TPS = 0
    self.AverageTPS = 0
    self.RawTPS = 0
    self.DesiredTPS = 0

    self._AverageTPSPrecision = 10
    self._Last = server.getTimeMillisec()
    self._AverageTPSAccumulation = {}
end

function Noir.Services.TPSService:ServiceStart()
    self._OnTickConnection = Noir.Callbacks:Connect("onTick", function(ticks)
        -- Slow TPS to desired TPS
        local now = server.getTimeMillisec()

        if self.DesiredTPS ~= 0 then -- below is from Woe (https://discord.com/channels/357480372084408322/905791966904729611/1261911499723509820) @ https://discord.gg/stormworks
            while self:_CalculateTPS(self._Last, now, ticks) > self.DesiredTPS do
                now = server.getTimeMillisec()
            end
        end

        -- Calculate TPS
        self.TPS = self:_CalculateTPS(self._Last, now, ticks)
        self.RawTPS = self:_CalculateTPS(self._Last, now, 1)
        self._Last = server.getTimeMillisec()

        -- Calculate average TPS
        if #self._AverageTPSAccumulation >= self._AverageTPSPrecision then
            table.remove(self._AverageTPSAccumulation, 1)
        end

        table.insert(self._AverageTPSAccumulation, self.TPS)
        self.AverageTPS = Noir.Libraries.Number:Average(self._AverageTPSAccumulation)
    end)
end

--[[
    Calculates TPS from two points in time.
]]
---@param past number
---@param now number
---@param gameTicks number
---@return number
function Noir.Services.TPSService:_CalculateTPS(past, now, gameTicks)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TPSService:CalculateTPS()", "past", past, "number")
    Noir.TypeChecking:Assert("Noir.Services.TPSService:CalculateTPS()", "now", now, "number")
    Noir.TypeChecking:Assert("Noir.Services.TPSService:CalculateTPS()", "gameTicks", gameTicks, "number")

    -- Calculate TPS
    return 1000 / (now - past) * gameTicks
end

--[[
    Set the desired TPS. The service will then slow the game down until the desired TPS is achieved. Set to 0 to disable this.
]]
---@param desiredTPS number 0 = disabled
function Noir.Services.TPSService:SetTPS(desiredTPS)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.TPSService:SetTPS()", "desiredTPS", desiredTPS, "number")

    -- Set desired TPS, and validate
    if desiredTPS < 0 then
        desiredTPS = 0
    end

    self.DesiredTPS = desiredTPS
end

--[[
    Get the TPS of the server.
]]
---@return number
function Noir.Services.TPSService:GetTPS()
    return self.TPS
end

--[[
    Get the average TPS of the server.
]]
---@return number
function Noir.Services.TPSService:GetAverageTPS()
    return self.AverageTPS
end

--[[
    Set the amount of ticks to use when calculating the average TPS.<br>
    Eg: if this is set to 10, the average TPS will be calculated over a period of 10 ticks.
]]
---@param precision integer
function Noir.Services.TPSService:SetPrecision(precision)
    Noir.TypeChecking:Assert("Noir.Services.TPSService:SetPrecision()", "precision", precision, "number")
    self._AverageTPSPrecision = precision
end

--------------------------------------------------------
-- [Noir] Services - UI Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for showing UI to players in an OOP manner.
    Map UI, screen popups, physical popups, etc, are all supported.

    local widget = Noir.Services.UIService:CreateMapLabel(
        "My Custom Map Label", -- the text to show on the map label
        2, -- the map label type
        matrix.translation(0, 0, 0), -- the position the widget (map label) should be at
        false, -- if the widget (map label) starts visible. in this case, it starts invisible
        nil -- nil = all players can see. set this to a player to only show it for them
    )

    widget.Position = matrix.translation(15, 0, 0)
    widget.Visible = true
    widget:Update() -- we changed the widget's properties, so to reflect changes, we update

    widget:Remove() -- remove's the widget from the game and this service
]]
---@class NoirUIService: NoirService
---@field Widgets table<integer, NoirWidget> A table of all widgets currently being shown to players
---@field _OnJoinConnection NoirConnection The connection to PlayerService's `OnJoin` event
---@field _OnLeaveConnection NoirConnection The connection to PlayerService's `OnLeave` event
Noir.Services.UIService = Noir.Services:CreateService(
    "UIService",
    true,
    "A service for showing UI to players.",
    "A service for showing UI to players in an OOP manner. Map UI, screen popups, physical popups, etc, are all supported.",
    {"Cuh4"}
)

Noir.Services.UIService.InitPriority = 6 -- after VehicleService. `:_LoadWidgets()` depends on it

function Noir.Services.UIService:ServiceInit()
    self.Widgets = {}
    self:_LoadWidgets()
end

function Noir.Services.UIService:ServiceStart()
    ---@param player NoirPlayer
    self._OnJoinConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        for _, widget in pairs(self:GetWidgetsShownToPlayer(player)) do
            widget:_Update(player)
        end
    end)

    ---@param player NoirPlayer
    self._OnLeaveConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        for _, widget in pairs(self:GetWidgetsBelongingToPlayer(player)) do
            self:RemoveWidget(widget.ID)
        end
    end)
end

--[[
    Returns all saved widgets (serialized versions).<br>
    Used internally. Do not use in your code.
]]
---@return table<integer, NoirSerializedWidget>
function Noir.Services.UIService:_GetSavedWidgets()
    return self:EnsuredLoad("Widgets", {})
end

--[[
    Loads all widgets saved in g_savedata.<br>
    Used internally. Do not use in your code.
]]
function Noir.Services.UIService:_LoadWidgets()
    local savedWidgets = self:_GetSavedWidgets()

    for _, savedWidget in pairs(savedWidgets) do
        if savedWidget.Player ~= -1 and not Noir.Services.PlayerService:GetPlayer(savedWidget.Player) then -- player must've left. no need to load this widget
            goto continue
        end

        ---@type table<NoirWidgetType, function>
        local deserializers = {
            ["MapObject"] = function(serializedWidget)
                return Noir.Classes.MapObjectWidget:Deserialize(serializedWidget)
            end,

            ["MapLabel"] = function(serializedWidget)
                return Noir.Classes.MapLabelWidget:Deserialize(serializedWidget)
            end,

            ["Popup"] = function(serializedWidget)
                return Noir.Classes.PopupWidget:Deserialize(serializedWidget)
            end,

            ["ScreenPopup"] = function(serializedWidget)
                return Noir.Classes.ScreenPopupWidget:Deserialize(serializedWidget)
            end,

            ["MapLine"] = function(serializedWidget)
                return Noir.Classes.MapLineWidget:Deserialize(serializedWidget)
            end
        }

        if not deserializers[savedWidget.WidgetType] then
            Noir.Libraries.Logging:Warning("UIService", "Got unknown saved widget of type: %s", savedWidget.WidgetType)
            goto continue
        end

        local widget = deserializers[savedWidget.WidgetType](savedWidget)

        if not widget then
            goto continue
        end

        self:_AddWidget(widget)

        ::continue::
    end
end

--[[
    Saves a widget.<br>
    Used internally. Do not use in your code.
]]
---@param widget NoirWidget
function Noir.Services.UIService:_SaveWidget(widget)
    Noir.TypeChecking:Assert("Noir.Services.UIService:_SaveWidget()", "widget", widget, Noir.Classes.Widget)

    local savedWidgets = self:_GetSavedWidgets()
    savedWidgets[widget.ID] = widget:Serialize()

    self:Save("Widgets", savedWidgets)
end

--[[
    Unsaves a widget.<br>
    Used internally. Do not use in your code.
]]
---@param widget NoirWidget
function Noir.Services.UIService:_UnsaveWidget(widget)
    Noir.TypeChecking:Assert("Noir.Services.UIService:_UnsaveWidget()", "widget", widget, Noir.Classes.Widget)

    local savedWidgets = self:_GetSavedWidgets()
    savedWidgets[widget.ID] = nil

    self:Save("Widgets", savedWidgets)
end

--[[
    Adds a widget to the UIService.<br>
    Used internally. Do not use in your code.
]]
---@param widget NoirWidget The widget to add
function Noir.Services.UIService:_AddWidget(widget)
    Noir.TypeChecking:Assert("Noir.Services.UIService:_AddWidget()", "widget", widget, Noir.Classes.Widget)

    self.Widgets[widget.ID] = widget
    self:_SaveWidget(widget)
end

--[[
    Removes a widget from the UIService.<br>
    Used internally. Do not use in your code.
]]
---@param widget NoirWidget The widget to remove
function Noir.Services.UIService:_RemoveWidget(widget)
    Noir.TypeChecking:Assert("Noir.Services.UIService:_RemoveWidget()", "widget", widget, Noir.Classes.Widget)

    self.Widgets[widget.ID] = nil
    self:_UnsaveWidget(widget)
end

--[[
    Creates a map label widget.<br>
    This is a label that is shown on the map (duh), similar to what you see at shipwrecks, key locations (e.g: "Harrison Airbase").
]]
---@param text string
---@param labelType SWLabelTypeEnum
---@param position SWMatrix
---@param visible boolean
---@param player NoirPlayer|nil
---@return NoirMapLabelWidget
function Noir.Services.UIService:CreateMapLabel(text, labelType, position, visible, player)
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLabel()", "text", text, "string")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLabel()", "labelType", labelType, "number")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLabel()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLabel()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLabel()", "player", player, Noir.Classes.Player, "nil")

    local widget = Noir.Classes.MapLabelWidget:New(
        server.getMapID(),
        visible,
        text,
        labelType,
        position,
        player
    )

    widget:Update()
    self:_AddWidget(widget)

    return widget
end

--[[
    Creates a screen popup widget.<br>
    This is a rounded-rectangle with text shown on your screen, exactly the same as the tutorial popups
    you get when you start a singleplayer game.
]]
---@param text string
---@param X number -1 (left) to 1 (right)
---@param Y number -1 (top) to 1 (bottom)
---@param visible boolean
---@param player NoirPlayer|nil
---@return NoirScreenPopupWidget
function Noir.Services.UIService:CreateScreenPopup(text, X, Y, visible, player)
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateScreenPopup()", "text", text, "string")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateScreenPopup()", "X", X, "number")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateScreenPopup()", "X", Y, "number")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateScreenPopup()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateScreenPopup()", "player", player, Noir.Classes.Player, "nil")

    local widget = Noir.Classes.ScreenPopupWidget:New(
        server.getMapID(),
        visible,
        text,
        X,
        Y,
        player
    )

    widget:Update()
    self:_AddWidget(widget)

    return widget
end

--[[
    Creates a popup widget.<br>
    This is a 2D popup that is shown in 3D space. It can be attached to a body or an object too.<br>
    This is used in the Stormworks career tutorial.
]]
---@param text string
---@param position SWMatrix
---@param renderDistance number in meters
---@param visible boolean
---@param player NoirPlayer|nil
---@return NoirPopupWidget
function Noir.Services.UIService:CreatePopup(text, position, renderDistance, visible, player)
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreatePopup()", "text", text, "string")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreatePopup()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreatePopup()", "renderDistance", renderDistance, "number")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreatePopup()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreatePopup()", "player", player, Noir.Classes.Player, "nil")

    local widget = Noir.Classes.PopupWidget:New(
        server.getMapID(),
        visible,
        text,
        position,
        renderDistance,
        player
    )

    widget:Update()
    self:_AddWidget(widget)

    return widget
end

--[[
    Creates a map line widget.<br>
    Simply renders a line connecting two points on the map.
]]
---@param startPosition SWMatrix
---@param endPosition SWMatrix
---@param width number
---@param visible boolean
---@param colorR number|nil
---@param colorG number|nil
---@param colorB number|nil
---@param colorA number|nil
---@param player NoirPlayer|nil
---@return NoirMapLineWidget
function Noir.Services.UIService:CreateMapLine(startPosition, endPosition, width, visible, colorR, colorG, colorB, colorA, player)
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "startPosition", startPosition, "table")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "endPosition", endPosition, "table")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "width", width, "number")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "colorR", colorR, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "colorG", colorG, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "colorB", colorB, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "colorA", colorA, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapLine()", "player", player, Noir.Classes.Player, "nil")

    local widget = Noir.Classes.MapLineWidget:New(
        server.getMapID(),
        visible,
        startPosition,
        endPosition,
        width,
        colorR or 255,
        colorG or 255,
        colorB or 255,
        colorA or 255,
        player
    )

    widget:Update()
    self:_AddWidget(widget)

    return widget
end

--[[
    Creates a map object widget.<br>
    Similar to a map label, this is shown on the map. However, this comes with an interactive circular icon
    that when hovered over, shows a title and a subtitle.<br>
    This is what Stormworks missions use to show mission locations.
]]
---@param title string
---@param text string
---@param objectType SWMarkerTypeEnum
---@param position SWMatrix
---@param radius number
---@param visible boolean
---@param colorR number|nil
---@param colorG number|nil
---@param colorB number|nil
---@param colorA number|nil
---@param player NoirPlayer|nil
---@return NoirMapObjectWidget
function Noir.Services.UIService:CreateMapObject(title, text, objectType, position, radius, visible, colorR, colorG, colorB, colorA, player)
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "title", title, "string")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "text", text, "string")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "objectType", objectType, "number")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "radius", radius, "number")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "visible", visible, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "colorR", colorR, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "colorG", colorG, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "colorB", colorB, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "colorA", colorA, "number", "nil")
    Noir.TypeChecking:Assert("Noir.Services.UIService:CreateMapObject()", "player", player, Noir.Classes.Player, "nil")

    local widget = Noir.Classes.MapObjectWidget:New(
        server.getMapID(),
        visible,
        title,
        text,
        objectType,
        position,
        radius,
        colorR or 255,
        colorG or 255,
        colorB or 255,
        colorA or 255,
        player
    )

    widget:Update()
    self:_AddWidget(widget)

    return widget
end

--[[
    Returns a widget by ID.
]]
---@param ID integer
---@return NoirWidget|nil
function Noir.Services.UIService:GetWidget(ID)
    return self.Widgets[ID]
end

--[[
    Returns all widgets shown to a player.<br>
    Unlike `:GetWidgetsBelongingToPlayer()`, this will include widgets that are shown to all players including this player.
]]
---@param player NoirPlayer
---@return table<integer, NoirWidget>
function Noir.Services.UIService:GetWidgetsShownToPlayer(player)
    local widgets = {}

    for _, widget in pairs(self.Widgets) do
        if not widget.Player or Noir.Services.PlayerService:IsSamePlayer(player, widget.Player) then
            table.insert(widgets, widget)
        end
    end

    return widgets
end

--[[
    Returns all widgets belonging to a player (ignoring widgets belonging to all players).
]]
---@param player NoirPlayer
---@return table<integer, NoirWidget>
function Noir.Services.UIService:GetWidgetsBelongingToPlayer(player)
    local widgets = {}

    for _, widget in pairs(self.Widgets) do
        if not widget.Player then
            goto continue
        end

        if Noir.Services.PlayerService:IsSamePlayer(player, widget.Player) then
            table.insert(widgets, widget)
        end

        ::continue::
    end

    return widgets
end

--[[
    Remove a widget by ID. This will also hide the widget from players.
]]
---@param ID integer
function Noir.Services.UIService:RemoveWidget(ID)
    local widget = self:GetWidget(ID)

    if not widget then
        error("Noir.Services.UIService:RemoveWidget()", "No widget with ID %d exists.", ID)
    end

    widget:Destroy()
    self:_RemoveWidget(widget)
end

--[[
    Returns the player a serialized widget belongs to.<br>
    Raises an error if the player does not exist and peer id is not -1.
]]
---@param ID integer The peer ID of the player, or -1 if everyone
---@return NoirPlayer|nil
function Noir.Services.UIService:_GetSerializedPlayer(ID)
    Noir.TypeChecking:Assert("Noir.Services.UIService:_GetSerializedPlayer()", "ID", ID, "number")

    if ID == -1 then
        return
    end

    local player = Noir.Services.PlayerService:GetPlayer(ID)

    if not player then
        error("Noir.Services.UIService:_GetSerializedPlayer()", "Player with ID %d does not exist.", ID)
    end

    return player
end

--------------------------------------------------------
-- [Noir] Services - Vehicle Service
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for interacting with vehicles.<br>
    Note that vehicles are referred to as bodies, while vehicle groups are referred to as vehicles.

    ---@param body NoirBody
    Noir.Services.VehicleService.OnBodyLoad:Connect(function(body)
        -- Set tooltip
        body:SetTooltip("#"..body.ID)
        
        -- Set all tanks to have 0 contents
        local tanks = body:GetComponents().components.tanks

        for _, tank in pairs(tanks) do
            body:SetTankByVoxel(tank.pos.x, tank.pos.y, tank.pos.z, 0, tank.fluid_type)
        end

        -- Send notification when the vehicle body despawns
        body.OnDespawn:Once(function()
            Noir.Services.NotificationService:Error("Body Despawned", "A vehicle body belonging to you despawned!", body.Owner)
        end)
    end)
]]
---@class NoirVehicleService: NoirService
---@field Vehicles table<integer, NoirVehicle> A table of all spawned vehicles (in SW: vehicle groups)
---@field _SavedVehicles table<integer, NoirSerializedVehicle> A table of all saved vehicles
---@field Bodies table<integer, NoirBody> A table of all spawned bodies (in SW: vehicles)
---@field _SavedBodies table<integer, NoirSerializedBody> A table of all saved bodies
---
---@field OnVehicleSpawn NoirEvent Arguments: vehicle (NoirVehicle) | Fired when a vehicle is spawned
---@field OnVehicleDespawn NoirEvent Arguments: vehicle (NoirVehicle) | Fired when a vehicle is despawned
---@field OnBodySpawn NoirEvent Arguments: body (NoirBody) | Fired when a body is spawned
---@field OnBodyDespawn NoirEvent Arguments: body (NoirBody) | Fired when a body is despawned
---@field OnBodyLoad NoirEvent Arguments: body (NoirBody) | Fired when a body is loaded
---@field OnBodyUnload NoirEvent Arguments: body (NoirBody) | Fired when a body is unloaded
---@field OnBodyDamage NoirEvent Arguments: body (NoirBody), damage (number), voxelX (number), voxelY (number), voxelZ (number) | Fired when a body is damaged
---
---@field _OnGroupSpawnConnection NoirConnection A connection to the onGroupSpawn event
---@field _OnBodySpawnConnection NoirConnection A connection to the onVehicleSpawn event
---@field _OnBodyDespawnConnection NoirConnection A connection to the onVehicleDespawn event
---@field _OnBodyLoadConnection NoirConnection A connection to the onVehicleLoad event
---@field _OnBodyUnloadConnection NoirConnection A connection to the onVehicleUnload event
---@field _OnBodyDamageConnection NoirConnection A connection to the onVehicleDamage event
Noir.Services.VehicleService = Noir.Services:CreateService(
    "VehicleService",
    true,
    "A service for interacting with vehicles.",
    "A service for interacting with vehicles in an OOP-like manner.",
    {"Cuh4"}
)

Noir.Services.VehicleService.InitPriority = 5

function Noir.Services.VehicleService:ServiceInit()
    self.Vehicles = {}
    self._SavedVehicles = self:Load("SavedVehicles", {})

    self.Bodies = {}
    self._SavedBodies = self:Load("SavedBodies", {})

    self.OnVehicleSpawn = Noir.Libraries.Events:Create()
    self.OnVehicleDespawn = Noir.Libraries.Events:Create()

    self.OnBodySpawn = Noir.Libraries.Events:Create()
    self.OnBodyDespawn = Noir.Libraries.Events:Create()
    self.OnBodyLoad = Noir.Libraries.Events:Create()
    self.OnBodyUnload = Noir.Libraries.Events:Create()
    self.OnBodyDamage = Noir.Libraries.Events:Create()

    -- Load saved vehicles and bodies
    self:_LoadSavedBodies()
    self:_LoadSavedVehicles()
end

function Noir.Services.VehicleService:ServiceStart()
    -- Listen for vehicles spawning
    self._OnGroupSpawnConnection = Noir.Callbacks:Connect("onGroupSpawn", function(group_id, peer_id, x, y, z, group_cost)
        if self:GetVehicle(group_id) then -- vehicle was spawned by addon
            return
        end

        local player = Noir.Services.PlayerService:GetPlayer(peer_id)
        self:_RegisterVehicle(group_id, player, matrix.translation(x, y, z), group_cost, true)
    end)

    -- Listen for bodies spawning
    self._OnBodySpawnConnection = Noir.Callbacks:Connect("onVehicleSpawn", function(vehicle_id, peer_id, x, y, z, group_cost, group_id)
        if self:GetBody(vehicle_id) then -- body was spawned by addon
            return
        end

        local player = Noir.Services.PlayerService:GetPlayer(peer_id)
        self:_RegisterBody(vehicle_id, player, true)
    end)

    -- Listen for bodies despawning
    self._OnBodyDespawnConnection = Noir.Callbacks:Connect("onVehicleDespawn", function(vehicle_id, peer_id)
        local body = self:GetBody(vehicle_id)

        if not body then
            error("VehicleService", "A body was despawned that isn't recognized. ID: %s", vehicle_id)
        end

        self:_UnregisterBody(body, true, true)
    end)

    -- Listen for bodies loading
    self._OnBodyLoadConnection = Noir.Callbacks:Connect("onVehicleLoad", function(vehicle_id)
        local body = self:GetBody(vehicle_id)

        if not body then
            return
        end

        self:_LoadBody(body, true)
    end)

    -- Listen for bodies unloading
    self._OnBodyUnloadConnection = Noir.Callbacks:Connect("onVehicleUnload", function(vehicle_id)
        local body = self:GetBody(vehicle_id)

        if not body then
            return
        end

        self:_UnloadBody(body, true)
    end)

    -- Listen for bodies taking damage
    self._OnBodyDamageConnection = Noir.Callbacks:Connect("onVehicleDamaged", function(vehicle_id, damage, x, y, z, body_index)
        local body = self:GetBody(vehicle_id)

        if not body then
            return
        end

        self:_DamageBody(body, x, y, z, damage)
    end)
end

--[[
    Load all saved vehicles. It is important bodies are loaded beforehand. If this is not the case, they will be created automatically but possibly with incorrect data.<br>
    Used internally.
]]
function Noir.Services.VehicleService:_LoadSavedVehicles()
    for _, vehicle in pairs(self._SavedVehicles) do
        self:_RegisterVehicle(vehicle.ID, vehicle.Owner and Noir.Services.PlayerService:GetPlayer(vehicle.Owner), vehicle.SpawnPosition, vehicle.Cost, false)
    end
end

--[[
    Load all saved bodies.<br>
    Used internally.
]]
function Noir.Services.VehicleService:_LoadSavedBodies()
    for _, body in pairs(self._SavedBodies) do
        self:_RegisterBody(body.ID, body.Owner and Noir.Services.PlayerService:GetPlayer(body.Owner), false)
    end
end

--[[
    Register a vehicle to the vehicle service.<br>
    Used internally.
]]
---@param ID integer
---@param player NoirPlayer|nil
---@param spawnPosition SWMatrix
---@param cost number
---@param fireEvent boolean
---@return NoirVehicle
function Noir.Services.VehicleService:_RegisterVehicle(ID, player, spawnPosition, cost, fireEvent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterVehicle()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterVehicle()", "player", player, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterVehicle()", "spawnPosition", spawnPosition, "table")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterVehicle()", "cost", cost, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterVehicle()", "fireEvent", fireEvent, "boolean")

    -- Get bodies
    local bodyIDs, success = server.getVehicleGroup(ID)

    if not success then
        error("VehicleService:_RegisterVehicle()", "Failed to get bodies for a vehicle.")
    end

    -- Create bodies
    local bodies = {} ---@type table<integer, NoirBody>

    for _, bodyID in pairs(bodyIDs) do
        local body = self:GetBody(bodyID) or self:_RegisterBody(bodyID, player, fireEvent)

        if not body then
            goto continue
        end

        table.insert(bodies, body)

        ::continue::
    end

    -- Create vehicle
    local vehicle = Noir.Classes.Vehicle:New(ID, player, spawnPosition, cost)
    self.Vehicles[vehicle.ID] = vehicle

    -- Add bodies
    for _, body in pairs(bodies) do
        vehicle:_AddBody(body)
    end

    -- Save
    self:_SaveVehicle(vehicle)

    -- Fire event
    if fireEvent then
        self.OnVehicleSpawn:Fire(vehicle)
    end

    -- Return vehicle
    return vehicle
end

--[[
    Save a vehicle.<br>
    Used internally.
]]
---@param vehicle NoirVehicle
function Noir.Services.VehicleService:_SaveVehicle(vehicle)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_SaveVehicle()", "vehicle", vehicle, Noir.Classes.Vehicle)

    -- Save
    self._SavedVehicles[vehicle.ID] = vehicle:_Serialize()
    self:Save("SavedVehicles", self._SavedVehicles)
end

--[[
    Unsave a vehicle.<br>
    Used internally.
]]
---@param vehicle NoirVehicle
function Noir.Services.VehicleService:_UnsaveVehicle(vehicle)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnsaveVehicle()", "vehicle", vehicle, Noir.Classes.Vehicle)

    -- Unsave
    self._SavedVehicles[vehicle.ID] = nil
    self:Save("SavedVehicles", self._SavedVehicles)
end

--[[
    Unregister a vehicle from the vehicle service.<br>
    Used internally.
]]
---@param vehicle NoirVehicle
---@param fireEvent boolean
function Noir.Services.VehicleService:_UnregisterVehicle(vehicle, fireEvent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnregisterVehicle()", "vehicle", vehicle, Noir.Classes.Vehicle)
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnregisterVehicle()", "fireEvent", fireEvent, "boolean")

    -- Check if exists
    if not self:GetVehicle(vehicle.ID) then
        error("VehicleService:_UnregisterVehicle()", "Failed to unregister a vehicle because it doesn't exist.")
    end

    -- Remove vehicle
    vehicle.Spawned = false
    self.Vehicles[vehicle.ID] = nil

    -- Remove bodies
    for _, body in pairs(vehicle.Bodies) do
        self:_UnregisterBody(body, false, fireEvent)
    end

    -- Remove from saved
    self:_UnsaveVehicle(vehicle)

    -- Fire event
    if fireEvent then
        self.OnVehicleDespawn:Fire(vehicle)
        vehicle.OnDespawn:Fire()
    end
end

--[[
    Register a body to the vehicle service.<br>
    Used internally.
]]
---@param ID integer
---@param player NoirPlayer|nil
---@param fireEvent boolean
---@return NoirBody|nil
function Noir.Services.VehicleService:_RegisterBody(ID, player, fireEvent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterBody()", "ID", ID, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterBody()", "player", player, Noir.Classes.Player, "nil")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_RegisterBody()", "fireEvent", fireEvent, "boolean")

    -- Create body
    local body = Noir.Classes.Body:New(ID, player, false)

    -- Check if the body even exists anymore
    if not body:Exists() then
        self:_UnregisterBody(body, false, false)
        return
    end

    -- Set loaded
    body.Loaded = body:IsSimulating()

    -- Register body
    self.Bodies[body.ID] = body

    -- Save
    self:_SaveBody(body)

    -- Fire event
    if fireEvent then
        self.OnBodySpawn:Fire(body)
    end

    -- Return body
    return body
end

--[[
    Save a body.<br>
    Used internally.
]]
---@param body NoirBody
function Noir.Services.VehicleService:_SaveBody(body)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_SaveBody()", "body", body, Noir.Classes.Body)

    -- Save
    self._SavedBodies[body.ID] = body:_Serialize()
    self:Save("SavedBodies", self._SavedBodies)
end

--[[
    Unsave a body.<br>
    Used internally.
]]
---@param body NoirBody
function Noir.Services.VehicleService:_UnsaveBody(body)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnsaveBody()", "body", body, Noir.Classes.Body)

    -- Unsave
    self._SavedBodies[body.ID] = nil
    self:Save("SavedBodies", self._SavedBodies)
end

--[[
    Load a body internally.<br>
    Used internally.
]]
---@param body NoirBody
---@param fireEvent boolean
function Noir.Services.VehicleService:_LoadBody(body, fireEvent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_LoadBody()", "body", body, Noir.Classes.Body)
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_LoadBody()", "fireEvent", fireEvent, "boolean")

    -- Check if exists
    if not self:GetBody(body.ID) then
        error("VehicleService:_LoadBody()", "Failed to load a body because it doesn't exist.")
    end

    -- Load body
    body.Loaded = true

    -- Save
    self:_SaveBody(body)

    -- Fire event
    if fireEvent then
        body.OnLoad:Fire()
        self.OnBodyLoad:Fire(body)
    end
end

--[[
    Unload a body internally.<br>
    Used internally.
]]
---@param body NoirBody
---@param fireEvent boolean
function Noir.Services.VehicleService:_UnloadBody(body, fireEvent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnloadBody()", "body", body, Noir.Classes.Body)
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnloadBody()", "fireEvent", fireEvent, "boolean")

    -- Check if exists
    if not self:GetBody(body.ID) then
        error("VehicleService:_UnloadBody()", "Failed to unload a body because it doesn't exist.")
    end

    -- Unload body
    body.Loaded = false

    -- Save
    self:_SaveBody(body)

    -- Fire event
    if fireEvent then
        body.OnUnload:Fire()
        self.OnBodyUnload:Fire(body)
    end
end

--[[
    Fire events for body damage.<br>
    Used internally.
]]
---@param body NoirBody
---@param x number
---@param y number
---@param z number
---@param damage number
function Noir.Services.VehicleService:_DamageBody(body, x, y, z, damage)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_DamageBody()", "body", body, Noir.Classes.Body)
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_DamageBody()", "x", x, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_DamageBody()", "y", y, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_DamageBody()", "z", z, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_DamageBody()", "damage", damage, "number")

    -- Fire events
    body.OnDamage:Fire(damage, x, y, z)
    self.OnBodyDamage:Fire(body, damage, x, y, z)
end

--[[
    Unregister a body from the vehicle service.<br>
    Used internally.
]]
---@param body NoirBody
---@param autoDespawnParentVehicle boolean
---@param fireEvent boolean
function Noir.Services.VehicleService:_UnregisterBody(body, autoDespawnParentVehicle, fireEvent)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnregisterBody()", "body", body, Noir.Classes.Body)
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnregisterBody()", "autoDespawnParentVehicle", autoDespawnParentVehicle, "boolean")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_UnregisterBody()", "fireEvent", fireEvent, "boolean")

    -- Check if exists
    if not self:GetBody(body.ID) then
        error("VehicleService:_UnregisterBody()", "Failed to unregister a body because it doesn't exist.")
    end

    -- Remove body from service
    body.Spawned = false
    self.Bodies[body.ID] = nil

    -- Remove body from vehicle
    local parentVehicle = body.ParentVehicle

    if parentVehicle then
        parentVehicle:_RemoveBody(body)
        self:_SaveVehicle(parentVehicle)
    end

    -- Unsave
    self:_UnsaveBody(body)

    -- Fire event
    if fireEvent then
        self.OnBodyDespawn:Fire(body)
        body.OnDespawn:Fire()
    end

    -- If the parent vehicle has no more bodies, unregister it
    if autoDespawnParentVehicle and parentVehicle then
        local bodyCount = Noir.Libraries.Table:Length(parentVehicle.Bodies) -- questionable variable name

        if bodyCount <= 0 then
            self:_UnregisterVehicle(parentVehicle, fireEvent)
        end
    end
end

--[[
    Setup data for a spawned vehicle.
]]
---@param primaryVehicleID integer
---@param vehicleIDs table<integer, integer>
---@param position SWMatrix
---@return NoirVehicle
function Noir.Services.VehicleService:_SetupVehicle(primaryVehicleID, vehicleIDs, position)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_SetupVehicle()", "primaryVehicleID", primaryVehicleID, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_SetupVehicle()", "vehicleIDs", vehicleIDs, "table")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:_SetupVehicle()", "position", position, "table")

    -- Create bodies
    local primaryBody

    for _, vehicleID in pairs(vehicleIDs) do
        local body = self:_RegisterBody(vehicleID, nil, true)

        if primaryVehicleID == vehicleID then
            primaryBody = body
        end
    end

    -- Check if primaryBody exists
    if not primaryBody then
        error("VehicleService:_SetupVehicle()", "Failed to spawn a vehicle. `primaryBody` is nil.")
    end

    -- Get group ID
    local primaryBodyData = primaryBody:GetData()

    if not primaryBodyData then
        error("VehicleService:_SetupVehicle()", "Failed to spawn a vehicle. `primaryBodyData` is nil.")
    end

    local groupID = primaryBodyData.group_id

    -- Return vehicle
    return self:_RegisterVehicle(groupID, nil, position, 0, true)
end

--[[
    Spawn a vehicle from a mission component.<br>
    Uses `server.spawnAddonComponent` under the hood.
]]
---@param componentID integer
---@param locationID integer
---@param position SWMatrix
---@param addonIndex integer|nil Defaults to this addon's index
---@return NoirVehicle
function Noir.Services.VehicleService:SpawnVehicleFromMissionComponent(componentID, locationID, position, addonIndex)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicleFromMissionComponent()", "componentID", componentID, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicleFromMissionComponent()", "locationID", locationID, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicleFromMissionComponent()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicleFromMissionComponent()", "addonIndex", addonIndex, "number", "nil")

    -- Spawn vehicle
    local data, success = server.spawnAddonComponent(position, addonIndex or (server.getAddonIndex()), locationID, componentID)

    if not success then
        error("VehicleService:SpawnVehicleFromMissionComponent()", "Failed to spawn a vehicle. `server.spawnAddonComponent` returned unsuccessful.")
    end

    if data.type ~= 3 then
        error("VehicleService:SpawnVehicleFromMissionComponent()", "Failed to spawn a vehicle. Component is not a vehicle.")
    end

    return self:_SetupVehicle(data.id, data.vehicle_ids, position)
end

--[[
    Spawn a vehicle by file name.<br>
    Uses `server.spawnVehicle` under the hood.
]]
---@param fileName string
---@param position SWMatrix
---@return NoirVehicle
function Noir.Services.VehicleService:SpawnVehicleByFileName(fileName, position)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicleByFileName()", "fileName", fileName, "string")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicleByFileName()", "position", position, "table")

    -- Spawn vehicle
    local primaryVehicleID, success, vehicleIDs = server.spawnVehicle(position, fileName)

    if not success then
        error("VehicleService:SpawnVehicleByFileName()", "Failed to spawn a vehicle. `server.spawnVehicle` returned unsuccessful.")
    end

    return self:_SetupVehicle(primaryVehicleID, vehicleIDs, position)
end

--[[
    Spawn a vehicle.<br>
    Uses `server.spawnAddonVehicle` under the hood.
]]
---@param componentID integer
---@param position SWMatrix
---@param addonIndex integer|nil Defaults to this addon's index
---@return NoirVehicle
function Noir.Services.VehicleService:SpawnVehicle(componentID, position, addonIndex)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicle()", "componentID", componentID, "number")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicle()", "position", position, "table")
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:SpawnVehicle()", "addonIndex", addonIndex, "number", "nil")

    -- Spawn vehicle
    local primaryVehicleID, success, vehicleIDs = server.spawnAddonVehicle(position, addonIndex or (server.getAddonIndex()), componentID)

    if not success then
        error("VehicleService:SpawnVehicle()", "Failed to spawn a vehicle. `server.spawnAddonVehicle` returned unsuccessful.")
    end

    return self:_SetupVehicle(primaryVehicleID, vehicleIDs, position)
end

--[[
    Get a vehicle from the vehicle service.

    local vehicle = Noir.Services.VehicleService:GetVehicle(51)

    if vehicle then
        vehicle:Teleport(matrix.translation(0, 10, 0))
    end
]]
---@param ID integer
---@return NoirVehicle|nil
function Noir.Services.VehicleService:GetVehicle(ID)
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:GetVehicle()", "ID", ID, "number")
    return self.Vehicles[ID]
end

--[[
    Get a body from the vehicle service.

    local body = Noir.Services.VehicleService:GetBody(51)

    if body then
        body:SetTooltip("Hello World")
    end
]]
---@param ID integer
---@return NoirBody|nil
function Noir.Services.VehicleService:GetBody(ID)
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:GetBody()", "ID", ID, "number")
    return self.Bodies[ID]
end

--[[
    Get all spawned vehicles.

    for _, vehicle in pairs(Noir.Services.VehicleService:GetVehicles()) do
        vehicle:Move(matrix.translation(0, 10, 0))
    end
]]
---@return table<integer, NoirVehicle>
function Noir.Services.VehicleService:GetVehicles()
    return self.Vehicles
end

--[[
    Get all spawned bodies.<br>

    for _, body in pairs(Noir.Services.VehicleService:GetBodies()) do
        body:SetEditable(false)
    end
]]
---@return table<integer, NoirBody>
function Noir.Services.VehicleService:GetBodies()
    return self.Bodies
end

--[[
    Get all bodies spawned by a player.
]]
---@param player NoirPlayer
---@return table<integer, NoirBody>
function Noir.Services.VehicleService:GetBodiesFromPlayer(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:GetBodiesFromPlayer()", "player", player, Noir.Classes.Player)

    -- Get bodies
    local bodies = {}

    for _, body in pairs(self:GetBodies()) do
        if not body.Owner then
            goto continue
        end

        if Noir.Services.PlayerService:IsSamePlayer(body.Owner, player) then
            table.insert(bodies, body)
        end

        ::continue::
    end

    -- Return
    return bodies
end

--[[
    Get all vehicles spawned by a player.
]]
---@param player NoirPlayer
---@return table<integer, NoirVehicle>
function Noir.Services.VehicleService:GetVehiclesFromPlayer(player)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Services.VehicleService:GetVehiclesFromPlayer()", "player", player, Noir.Classes.Player)

    -- Get vehicles
    local vehicles = {}

    for _, vehicle in pairs(self:GetVehicles()) do
        if vehicle.Owner and Noir.Services.PlayerService:IsSamePlayer(vehicle.Owner, player) then
            table.insert(vehicles, vehicle)
        end
    end

    -- Return
    return vehicles
end

--------------------------------------------------------
-- [Noir] Debugging
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A module of Noir for debugging your code. This allows you to raise errors in the event something goes wrong
    as well as track functions to see how well they are performing and sort these functions in order of performance.<br>
    This can be useful for figuring out what functions are performing the worst which can help you optimize your addon.<br>
    This is not recommended to use in production it service may slow your addon. Please use it for debugging purposes only.

    -- Enabling debug
    Noir.Debugging.Enabled = true

    -- Raising an error
    Noir.Debugging:RaiseError(":Something()", "Something went wrong!")

    -- Tracking the performance of a function
    function myFunction()
        local value = 0

        for i = 1, 100000 do 
            value = value + i
        end
        
        return value
    end

    local tracker = Noir.Debugging:TrackFunction("myFunction", myFunction)
    myFunction = tracker:Mount()

    tracker:GetAverageExecutionTime() -- 0.01 ms
    tracker:GetLastExecutionTime() -- 0.02 ms
    print(tracker.FunctionName) -- "myFunction"

    -- Tracking the performance of all methods in a service
    local trackers = Noir.Debugging:TrackService(Noir.Services.VehicleService) -- Does the above but for all methods in VehicleService

    -- Tracking the performance of all functions in a table
    local myTbl = {
        foo = function()
            print("foo")
        end,

        bar = function()
            print("bar")
        end
    }

    local trackers = Noir.Debugging:TrackAll("myTbl", myTbl)
    -- To track all functions in your addon that are non-local, you can use the above method on `_ENV`. :TrackAll() will ignore non-local functions as they aren't in `_ENV` anyway

    -- Getting least performant functions
    Noir.Debugging:GetLeastPerformantTracked() -- A table of trackers. Index 1 being the least performant

    -- Showing least performant functions
    Noir.Debugging:ShowLeastPerformantTracked() -- Will send logs via logging library. You could call this every tick or in a command, etc
]]
Noir.Debugging = {}

--[[
    Enables/disables debugging. False by default, and it is recommended to keep it this way in production.
]]
Noir.Debugging.Enabled = false

--[[
    A table containing all created trackers for functions.
]]
Noir.Debugging.Trackers = {}

--[[
    A table containing all functions and tables that should not be tracked.
]]
Noir.Debugging._TrackingExceptions = {
    [Noir] = true
}

--[[
    Raises an error.<br>
    This method can still be called regardless of if debugging is enabled or not.<br>
    `error()` is aliased to this method.
]]
---@param source string
---@param message string
---@param ... any
function Noir.Debugging:RaiseError(source, message, ...)
    Noir.Libraries.Logging:Error("Error", source..": "..message, ...)
    _ENV["Noir: An error was raised. See logs for details."]()
end

--[[
    Raises an error.<br>
    This method can still be called regardless of if debugging is enabled or not.<br>
    This is an alias for `Noir.Debugging:RaiseError()`.
]]
---@param source string
---@param message string
---@param ... any
function error(source, message, ...)
    Noir.Debugging:RaiseError(source, message, ...)
end

--[[
    Returns all tracked functions with the option to copy.
]]
---@param copy boolean|nil
---@return table<integer, NoirTracker>
function Noir.Debugging:GetTrackedFunctions(copy)
    Noir.TypeChecking:Assert("Noir.Debugging:GetTrackedFunctions()", "copy", copy, "boolean", "nil")
    return copy and Noir.Libraries.Table:Copy(self.Trackers) or self.Trackers
end

--[[
    Returns the most recently called tracked functions.
]]
---@return table<integer, NoirTracker>
function Noir.Debugging:GetLastCalledTracked()
    local trackers = self:GetTrackedFunctions(true)

    table.sort(trackers, function(a, b)
        return a:GetLastExecutionTime() > b:GetLastExecutionTime()
    end)

    return trackers
end

--[[
    Shows the most recently called tracked functions.
]]
function Noir.Debugging:ShowLastCalledTracked()
    local trackers = self:GetLastCalledTracked()

    Noir.Libraries.Logging:Success("Debugging", "--- *Last* called functions:")

    for index, tracker in ipairs(trackers) do
        Noir.Libraries.Logging:Info("Debugging", "#%d: %s", index, tracker:ToFormattedString())
    end
end

--[[
    Returns the tracked functions with the worst performance.
]]
---@return table<integer, NoirTracker>
function Noir.Debugging:GetLeastPerformantTracked()
    local trackers = self:GetTrackedFunctions(true)

    table.sort(trackers, function(a, b)
        return a:GetAverageExecutionTime() > b:GetAverageExecutionTime()
    end)

    return trackers
end

--[[
    Shows the tracked functions with the worst performance.
]]
function Noir.Debugging:ShowLeastPerformantTracked()
    local trackers = self:GetLeastPerformantTracked()

    Noir.Libraries.Logging:Success("Debugging", "--- *Least* performant functions:")

    for index, tracker in ipairs(trackers) do
        Noir.Libraries.Logging:Info("Debugging", "#%d: %s", index, tracker:ToFormattedString())
    end
end

--[[
    Returns the tracked functions with the best performance.
]]
---@return table<integer, NoirTracker>
function Noir.Debugging:GetMostPerformantTracked()
    local trackers = self:GetTrackedFunctions(true)

    table.sort(trackers, function(a, b)
        return a:GetAverageExecutionTime() < b:GetAverageExecutionTime()
    end)

    return trackers
end

--[[
    Shows the tracked functions with the best performance.
]]
function Noir.Debugging:ShowMostPerformantTracked()
    local trackers = self:GetMostPerformantTracked()

    Noir.Libraries.Logging:Success("Debugging", "--- *Most* performant functions:")

    for index, tracker in ipairs(trackers) do
        Noir.Libraries.Logging:Info("Debugging", "#%d: %s", index, tracker:ToFormattedString())
    end
end

--[[
    Track a function. This returns a tracker which will track the performance of the function among other things.<br>
    Returns `nil` if the provided function isn't allowed to be tracked or if debugging isn't enabled.
    
    local tracker = Noir.Debugging:TrackFunction("myFunction", myFunction)
    myFunction = tracker:Mount()

    tracker:GetAverageExecutionTime() -- 0.01 ms
    tracker:GetLastExecutionTime() -- 0.02 ms
    -- etc
]]
---@param name string
---@param func function
---@return NoirTracker|nil
function Noir.Debugging:TrackFunction(name, func)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Debugging:TrackFunction()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Debugging:TrackFunction()", "func", func, "function")

    -- Checks
    if not self.Enabled then
        return
    end

    if self._TrackingExceptions[func] then
        return
    end

    -- Track
    local tracker = Noir.Classes.Tracker:New(name, func)
    table.insert(self.Trackers, tracker)

    -- Return
    return tracker
end

--[[
    Track all functions in a table. This will track all methods in the provided table, returning a table of all the trackers created.<br>
    Returns an empty table if debugging isn't enabled or the provided table is an exception.
]]
---@param name string
---@param tbl table<integer, function>
---@param _journey table<table, boolean>|nil Used internally to prevent infinite recursion
---@return table<integer, NoirTracker>
function Noir.Debugging:TrackAll(name, tbl, _journey)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Debugging:TrackAll()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Debugging:TrackAll()", "tbl", tbl, "table")
    Noir.TypeChecking:Assert("Noir.Debugging:TrackAll()", "_journey", _journey, "table", "nil")

    -- Checks
    if not _journey then
        _journey = {}
    end

    if not self.Enabled then
        return {}
    end

    if self._TrackingExceptions[tbl] then
        return {}
    end

    -- Track
    local trackers = {}

    for index, value in pairs(tbl) do
        if _journey[value] then
            goto continue
        end

        _journey[value] = true

        if type(value) == "table" then
            local _trackers = self:TrackAll(("%s.%s"):format(name, index), value, _journey)
            trackers = Noir.Libraries.Table:Merge(trackers, _trackers)

            goto continue
        end

        if type(value) ~= "function" then
            goto continue
        end

        local tracker = self:TrackFunction(("%s:%s"):format(name, index), value)

        if not tracker then
            goto continue
        end

        tbl[index] = tracker:Mount()

        table.insert(trackers, tracker)

        ::continue::
    end

    -- Return
    return trackers
end

--[[
    Track a service. This will track all methods in the provided service, returning a table of all the trackers created.
]]
---@param service NoirService
---@return table<integer, NoirTracker>
function Noir.Debugging:TrackService(service)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Debugging:TrackService()", "service", service, Noir.Classes.Service)

    -- Track
    return self:TrackAll(service.Name, service)
end

--------------------------------------------------------
-- [Noir] Callbacks
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A module of Noir that allows you to attach multiple functions to game callbacks.<br>
    These functions can be disconnected from the game callbacks at any time.

    Noir.Callbacks:Connect("onPlayerJoin", function()
        server.announce("Server", "A player joined!")
    end)

    Noir.Callbacks:Once("onPlayerJoin", function()
        server.announce("Server", "A player joined! (once) This will never be shown again.")
    end)
]]
Noir.Callbacks = {}

--[[
    A table of events assigned to game callbacks.<br>
    Do not directly modify this table.
]]
Noir.Callbacks.Events = {} ---@type table<string, NoirEvent>

--[[
    Connect to a game callback.

    Noir.Callbacks:Connect("onPlayerJoin", function()
        -- Code here
    end)
]]
---@param name string
---@param callback function
---@param hideStartWarning boolean|nil
---@return NoirConnection
---@overload fun(self, name: "onClearOilSpill", callback: fun(), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onTick", callback: fun(game_ticks: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreate", callback: fun(is_world_create: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onDestroy", callback: fun(), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCustomCommand", callback: fun(full_message: string, peer_id: number, is_admin: boolean, is_auth: boolean, command: string, ...: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onChatMessage", callback: fun(peer_id: number, sender_name: string, message: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerJoin", callback: fun(steam_id: number, name: string, peer_id: number, is_admin: boolean, is_auth: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerSit", callback: fun(peer_id: number, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerUnsit", callback: fun(peer_id: number, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCharacterSit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCharacterUnsit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCharacterPickup", callback: fun(object_id_actor: integer, object_id_target: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreatureSit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreatureUnsit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreaturePickup", callback: fun(object_id_actor: integer, object_id_target: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onEquipmentPickup", callback: fun(character_object_id: integer, equipment_object_id: integer, equipment_id: SWEquipmentTypeEnum), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onEquipmentDrop", callback: fun(character_object_id: integer, equipment_object_id: integer, equipment_id: SWEquipmentTypeEnum), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerRespawn", callback: fun(peer_id: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerLeave", callback: fun(steam_id: number, name: string, peer_id: number, is_admin: boolean, is_auth: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onToggleMap", callback: fun(peer_id: number, is_open: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerDie", callback: fun(steam_id: number, name: string, peer_id: number, is_admin: boolean, is_auth: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleSpawn", callback: fun(vehicle_id: integer, peer_id: number, x: number, y: number, z: number, group_cost: number, group_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onGroupSpawn", callback: fun(group_id: integer, peer_id: number, x: number, y: number, z: number, group_cost: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleDespawn", callback: fun(vehicle_id: integer, peer_id: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleLoad", callback: fun(vehicle_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleUnload", callback: fun(vehicle_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleTeleport", callback: fun(vehicle_id: integer, peer_id: number, x: number, y: number, z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onObjectLoad", callback: fun(object_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onObjectUnload", callback: fun(object_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onButtonPress", callback: fun(vehicle_id: integer, peer_id: number, button_name: string, is_pressed: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onSpawnAddonComponent", callback: fun(vehicle_or_object_id: integer, component_name: string, type_string: string, addon_index: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleDamaged", callback: fun(vehicle_id: integer, damage_amount: number, voxel_x: number, voxel_y: number, voxel_z: number, body_index: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "httpReply", callback: fun(port: number, request: string, reply: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onFireExtinguished", callback: fun(fire_x: number, fire_y: number, fire_z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onForestFireSpawned", callback: fun(fire_objective_id: number, fire_x: number, fire_y: number, fire_z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onForestFireExtinguished", callback: fun(fire_objective_id: number, fire_x: number, fire_y: number, fire_z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onTornado", callback: fun(transform: SWMatrix), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onMeteor", callback: fun(transform: SWMatrix, magnitude), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onTsunami", callback: fun(transform: SWMatrix, magnitude: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onWhirlpool", callback: fun(transform: SWMatrix, magnitude: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVolcano", callback: fun(transform: SWMatrix), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onOilSpill", callback: fun(tile_x: number, tile_z: number, delta: number, total: number, vehicle_id: integer), hideStartWarning: boolean?): NoirConnection
function Noir.Callbacks:Connect(name, callback, hideStartWarning)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Callbacks:Connect()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Callbacks:Connect()", "callback", callback, "function")
    Noir.TypeChecking:Assert("Noir.Callbacks:Connect()", "hideStartWarning", hideStartWarning, "boolean", "nil")

    -- Get or create event
    local event = self:_InstantiateCallback(name, hideStartWarning or false)

    -- Connect callback to event
    return event:Connect(callback)
end

--[[
    Connect to a game callback, but disconnect after the game callback has been called.

    Noir.Callbacks:Once("onPlayerJoin", function()
        -- Code here
    end)
]]
---@param name string
---@param callback function
---@param hideStartWarning boolean|nil
---@return NoirConnection
---@overload fun(self, name: "onClearOilSpill", callback: fun(), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onTick", callback: fun(game_ticks: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreate", callback: fun(is_world_create: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onDestroy", callback: fun(), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCustomCommand", callback: fun(full_message: string, peer_id: number, is_admin: boolean, is_auth: boolean, command: string, ...: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onChatMessage", callback: fun(peer_id: number, sender_name: string, message: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerJoin", callback: fun(steam_id: number, name: string, peer_id: number, is_admin: boolean, is_auth: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerSit", callback: fun(peer_id: number, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerUnsit", callback: fun(peer_id: number, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCharacterSit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCharacterUnsit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCharacterPickup", callback: fun(object_id_actor: integer, object_id_target: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreatureSit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreatureUnsit", callback: fun(object_id: integer, vehicle_id: integer, seat_name: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onCreaturePickup", callback: fun(object_id_actor: integer, object_id_target: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onEquipmentPickup", callback: fun(character_object_id: integer, equipment_object_id: integer, equipment_id: SWEquipmentTypeEnum), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onEquipmentDrop", callback: fun(character_object_id: integer, equipment_object_id: integer, equipment_id: SWEquipmentTypeEnum), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerRespawn", callback: fun(peer_id: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerLeave", callback: fun(steam_id: number, name: string, peer_id: number, is_admin: boolean, is_auth: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onToggleMap", callback: fun(peer_id: number, is_open: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onPlayerDie", callback: fun(steam_id: number, name: string, peer_id: number, is_admin: boolean, is_auth: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleSpawn", callback: fun(vehicle_id: integer, peer_id: number, x: number, y: number, z: number, group_cost: number, group_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onGroupSpawn", callback: fun(group_id: integer, peer_id: number, x: number, y: number, z: number, group_cost: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleDespawn", callback: fun(vehicle_id: integer, peer_id: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleLoad", callback: fun(vehicle_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleUnload", callback: fun(vehicle_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleTeleport", callback: fun(vehicle_id: integer, peer_id: number, x: number, y: number, z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onObjectLoad", callback: fun(object_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onObjectUnload", callback: fun(object_id: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onButtonPress", callback: fun(vehicle_id: integer, peer_id: number, button_name: string, is_pressed: boolean), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onSpawnAddonComponent", callback: fun(vehicle_or_object_id: integer, component_name: string, type_string: string, addon_index: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVehicleDamaged", callback: fun(vehicle_id: integer, damage_amount: number, voxel_x: number, voxel_y: number, voxel_z: number, body_index: integer), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "httpReply", callback: fun(port: number, request: string, reply: string), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onFireExtinguished", callback: fun(fire_x: number, fire_y: number, fire_z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onForestFireSpawned", callback: fun(fire_objective_id: number, fire_x: number, fire_y: number, fire_z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onForestFireExtinguished", callback: fun(fire_objective_id: number, fire_x: number, fire_y: number, fire_z: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onTornado", callback: fun(transform: SWMatrix), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onMeteor", callback: fun(transform: SWMatrix, magnitude), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onTsunami", callback: fun(transform: SWMatrix, magnitude: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onWhirlpool", callback: fun(transform: SWMatrix, magnitude: number), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onVolcano", callback: fun(transform: SWMatrix), hideStartWarning: boolean?): NoirConnection
---@overload fun(self, name: "onOilSpill", callback: fun(tile_x: number, tile_z: number, delta: number, total: number, vehicle_id: integer), hideStartWarning: boolean?): NoirConnection
function Noir.Callbacks:Once(name, callback, hideStartWarning)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Callbacks:Once()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Callbacks:Once()", "callback", callback, "function")
    Noir.TypeChecking:Assert("Noir.Callbacks:Once()", "hideStartWarning", hideStartWarning, "boolean", "nil")

    -- Get or create event
    local event = self:_InstantiateCallback(name, hideStartWarning or false)

    -- Connect callback to event
    return event:Once(callback)
end

--[[
    Get a game callback event. These events may not exist if `Noir.Callbacks:Connect()` or `Noir.Callbacks:Once()` was not called for them.<br>
    It's best to use `Noir.Callbacks:Connect()` or `Noir.Callbacks:Once()` instead of getting a callback event directly and connecting to it.

    local event = Noir.Callbacks:Get("onPlayerJoin") -- can be nil! use Noir.Callbacks:Connect() or Noir.Callbacks:Once() instead to guarantee an event

    event:Connect(function()
        server.announce("Server", "A player joined!")
    end)
]]
---@param name string
---@return NoirEvent
function Noir.Callbacks:Get(name)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Callbacks:Get()", "name", name, "string")

    -- Return
    return self.Events[name]
end

--[[
    Creates an event and an _ENV function for a game callback.<br>
    Used internally, do not use this in your addon.
]]
---@param name string
---@param hideStartWarning boolean
---@return NoirEvent
function Noir.Callbacks:_InstantiateCallback(name, hideStartWarning)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Callbacks:_InstantiateCallback()", "name", name, "string")
    Noir.TypeChecking:Assert("Noir.Callbacks:_InstantiateCallback()", "hideStartWarning", hideStartWarning, "boolean")

    -- Check if Noir has started
    if not Noir.HasStarted and not hideStartWarning then
        Noir.Libraries.Logging:Warning("Callbacks", "Noir has not started yet. It is not recommended to connect to callbacks before `Noir:Start()` is called and finalized. Please connect to the `Noir.Started` event and attach to game callbacks in that.")
    end

    -- For later
    local event = Noir.Callbacks.Events[name]

    -- Stop here if the event already exists
    if event then
        return event
    end

    -- Create event if it doesn't exist
    if not event then
        event = Noir.Libraries.Events:Create()
        self.Events[name] = event
    end

    -- Create function for game callback if it doesn't exist. If the user created the callback themselves, overwrite it
    local existing = _ENV[name]

    if existing then
        -- Inform developer that a function for a game callback already exists
        Noir.Libraries.Logging:Warning("Callbacks", "Your addon has a function for the game callback '%s'. Noir will wrap around it to prevent overwriting. Please use `Noir.Callbacks:Connect(\"%s\", function(...) end)` instead of `function %s(...) end` function to avoid this warning.", name, name, name)

        -- Wrap around existing function
        _ENV[name] = function(...)
            existing(...)
            event:Fire(...)
        end
    else
        -- Create function for game callback
        _ENV[name] = function(...)
            event:Fire(...)
        end
    end

    -- Return event
    return event
end

--------------------------------------------------------
-- [Noir] Bootstrapper
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    An internal module of Noir that is used to initialize and start services.<br>
    Do not use this in your code.
]]
Noir.Bootstrapper = {}

--[[
    Wraps user-created methods in a service with code to prevent them from being called if the service hasn't initialized yet.<br>
    Do not use this in your code. This is used internally.
]]
---@param service NoirService
function Noir.Bootstrapper:WrapServiceMethodsForService(service)
    -- Type checking
    Noir.TypeChecking:Assert("Noir.Bootstrapper:WrapServiceMethodsForService()", "service", service, Noir.Classes.Service)

    -- Prevent wrapping non-custom methods (aka methods not provided by the user)
    local blacklistedMethods = {}

    for name, _ in pairs(Noir.Classes.Service) do
        blacklistedMethods[name] = true
    end

    -- Wrap methods
    for name, method in pairs(service) do
        -- Check if the method is even a method
        if type(method) ~= "function" then
            goto continue
        end

        -- Check if the method is a user-created method or not
        if blacklistedMethods[name] then
            goto continue
        end

        -- Wrap the method
        service[name] = function(...)
            if not service.Initialized then
                error("Noir.Bootstrapper:WrapServiceMethodsForService()", "Attempted to call '%s()' of '%s' (service) when the service hasn't initialized yet.", name, service.Name)
            end

            return method(...)
        end

        ::continue::
    end
end

--[[
    Calls :WrapServiceMethodsForService() for all services.<br>
    Do not use this in your code. This is used internally.
]]
function Noir.Bootstrapper:WrapServiceMethodsForAllServices()
    for _, service in pairs(Noir.Services.CreatedServices) do
        self:WrapServiceMethodsForService(service)
    end
end

--[[
    Initialize all services.<br>
    This will order services by their `InitPriority` and then initialize them.<br>
    Do not use this in your code. This is used internally.
]]
function Noir.Bootstrapper:InitializeServices()
    -- Calculate order of service initialization
    local servicesToInit = Noir.Libraries.Table:Values(Noir.Services.CreatedServices)
    local lowestInitPriority = 0

    for _, service in pairs(servicesToInit) do
        local priority = service.InitPriority ~= nil and service.InitPriority or 0

        if priority >= lowestInitPriority then
            lowestInitPriority = priority
        end
    end

    for _, service in pairs(servicesToInit) do
        if not service.InitPriority then
            service.InitPriority = lowestInitPriority + 1
            lowestInitPriority = lowestInitPriority + 1
        end
    end

    ---@param serviceA NoirService
    ---@param serviceB NoirService
    table.sort(servicesToInit, function(serviceA, serviceB)
        if serviceA.IsBuiltIn ~= serviceB.IsBuiltIn then
            return serviceA.IsBuiltIn
        end

        return serviceA.InitPriority < serviceB.InitPriority
    end)

    -- Initialize services
    for _, service in pairs(servicesToInit) do
        Noir.Libraries.Logging:Info("Bootstrapper", "Initializing %s of priority %d.", Noir.Services:FormatService(service), service.InitPriority)
        service:_Initialize()
    end
end

--[[
    Start all services.<br>
    This will order services by their `StartPriority` and then start them.<br>
    Do not use this in your code. This is used internally.
]]
function Noir.Bootstrapper:StartServices()
    -- Calculate order of service start
    local servicesToStart = Noir.Libraries.Table:Values(Noir.Services.CreatedServices)
    local lowestStartPriority = 0

    for _, service in pairs(servicesToStart) do
        local priority = service.StartPriority ~= nil and service.StartPriority or 0

        if priority >= lowestStartPriority then
            lowestStartPriority = priority
        end
    end

    for _, service in pairs(servicesToStart) do
        if not service.StartPriority then
            service.StartPriority = lowestStartPriority + 1
            lowestStartPriority = lowestStartPriority + 1
        end
    end

    ---@param serviceA NoirService
    ---@param serviceB NoirService
    table.sort(servicesToStart, function(serviceA, serviceB)
        if serviceA.IsBuiltIn ~= serviceB.IsBuiltIn then
            return serviceA.IsBuiltIn
        end

        return serviceA.StartPriority < serviceB.StartPriority
    end)

    -- Start services
    for _, service in pairs(servicesToStart) do
        Noir.Libraries.Logging:Info("Bootstrapper", "Starting %s of priority %d.", Noir.Services:FormatService(service), service.StartPriority)
        service:_Start()
    end
end

--[[
    Determines whether or not the server this addon is being ran in is a dedicated server.<br>
    This evaluation is then used to set `Noir.IsDedicatedServer`.<br>
    Do not use this in your code. This is used internally.
]]
function Noir.Bootstrapper:SetIsDedicatedServer()
    local host = server.getPlayers()[1]
    Noir.IsDedicatedServer = host and (host.steam_id == 0 and host.object_id == nil)
end

--[[
    Sets the `Noir.AddonName` to the name of your addon.<br>
    Do not use this in your code. This is used internally.
]]
function Noir.Bootstrapper:SetAddonName()
    local index, success = server.getAddonIndex()

    if not success then
        error("Noir.Bootstrapper:SetAddonName()", "Failed to get addon index.")
    end

    local data = server.getAddonData(index)

    if not data then
        error("Noir.Bootstrapper:SetAddonName()", "Failed to get addon data.")
    end

    Noir.AddonName = data.name
end

--------------------------------------------------------
-- [Noir] Noir
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author(s): @Cuh4 (GitHub)
        GitHub Repository: https://github.com/cuhHub/Noir

    License:
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

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------

--[[
    The current version of Noir.<br>
    Follows [Semantic Versioning.](https://semver.org)
]]
Noir.Version = "2.1.0"

--[[
    Returns the MAJOR, MINOR, and PATCH of the current Noir version.

    major, minor, patch = Noir:GetVersion()
]]
---@return string major The MAJOR part of the version
---@return string minor The MINOR part of the version
---@return string patch The PATCH part of the version
function Noir:GetVersion()
    local major, minor, patch = table.unpack(Noir.Libraries.String:Split(self.Version, "."))
    return major, minor, patch
end

--[[
    This event is called when the framework is started.<br>
    Use this event to safely run your code.

    Noir.Started:Once(function()
        -- Your code
    end)
]]
Noir.Started = Noir.Libraries.Events:Create()

--[[
    The name of this addon.
]]
Noir.AddonName = ""

--[[
    This represents whether or not the framework has started.
]]
Noir.HasStarted = false

--[[
    This represents whether or not the framework is starting.
]]
Noir.IsStarting = false

--[[
    This represents whether or not the addon is being ran in a dedicated server.
]]
Noir.IsDedicatedServer = false

--[[
    This represents whether or not the addon was:<br>
    - Reloaded<br>
    - Started via a save load<br>
    - Started via a save creation
]]
Noir.AddonReason = "AddonReload" ---@type NoirAddonReason

--[[
    Starts the framework.<br>
    This will initialize all services, then upon completion, all services will be started.<br>
    Use the `Noir.Started` event to safely run your code.

    Noir.Started:Once(function()
        -- Your code
    end)

    Noir:Start()
]]
function Noir:Start()
    -- Checks
    if self.IsStarting then
        self.Debugging:RaiseError("Start", "The addon attempted to start Noir when it is in the process of starting.")
        return
    end

    if self.HasStarted then
        self.Debugging:RaiseError("Start", "The addon attempted to start Noir more than once.")
        return
    end

    -- Function to setup everything
    ---@param startTime number
    ---@param isSaveCreate boolean
    local function setup(startTime, isSaveCreate)
        -- Wait until onTick is first called to determine if the addon was reloaded, or if a save with the addon was loaded/created
        self.Callbacks:Once("onTick", function()
            -- Determine the addon reason
            local took = server.getTimeMillisec() - startTime
            self.AddonReason = isSaveCreate and "SaveCreate" or (took < 1000 and "AddonReload" or "SaveLoad")

            self.IsStarting = false
            self.HasStarted = true

            -- Set Noir.x
            self.Bootstrapper:SetIsDedicatedServer()
            self.Bootstrapper:SetAddonName()

            -- Initialize services
            self.Bootstrapper:InitializeServices()

            -- Fire event
            self.Started:Fire()

            -- Start services
            self.Bootstrapper:StartServices()

            -- Send log
            self.Libraries.Logging:Success("Start", "Noir v%s has started. Bootstrapper has initialized and started all services.\nTook: %sms | Addon Reason: %s", self.Version, took, Noir.AddonReason)

            -- Send log on addon stop
            self.Callbacks:Once("onDestroy", function()
                local addonData = server.getAddonData((server.getAddonIndex()))
                self.Libraries.Logging:Info("Stop", "%s, using Noir v%s, has stopped.", addonData.name, self.Version)
            end)
        end, true)
    end

    -- Wait for onCreate, then setup
    self.Callbacks:Once("onCreate", function(isSaveCreate)
        setup(server.getTimeMillisec(), isSaveCreate)
    end, true)

    self.IsStarting = true
end

-- Prevent user-created methods in services from being called before the service has been initialized
Noir.Bootstrapper:WrapServiceMethodsForAllServices()

-------------------------------
-- // Intellisense
-------------------------------

---@alias NoirAddonReason
---| "AddonReload" The addon was reloaded
---| "SaveCreate" A save was created with the addon enabled
---| "SaveLoad" A save with loaded into with the addon enabled

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
        How often to check if the PythonToSW server is alive when the PythonToSW server is not alive.
    ]]
    self.AliveCheckWhenNotAliveTickInterval = 5 * 64

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
        if self.Alive then
            self.CheckAliveTask:SetDuration(self.AliveCheckTickInterval)
        else
            -- request timeout takes a while and we don't want to hog http queue, so this is in place to prevent that
            self.CheckAliveTask:SetDuration(self.AliveCheckWhenNotAliveTickInterval)
        end

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
                warn(endpoint.." > Failed to send request to PythonToSW server: "..response.Text)
                self.Alive = false

                return
            end

            local data = response:JSON()

            if not data then
                warn(endpoint.." > Failed to parse response from PythonToSW server: "..response.Text)
                return
            end

            if data["detail"] and Noir.Libraries.String:StartsWith(data["detail"], "no_auth") then
                warn(endpoint.." > Can't send request. Outdated token. Try `?reload_scripts`.")
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

    self:Request("/ok", {}, function(response)
        self.Alive = true
    end, true)
end

--------------------------------------------------------
-- [SWToPython] Main
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
    Prints a warning.
]]
---@param message any
---@param ... any
warn = function(message, ...)
    return Noir.Libraries.Logging:Warning("Warn", message, ...)
end

--[[
    Prints a message.
]]
---@param message any
---@param ... any
print = function(message, ...)
    return Noir.Libraries.Logging:Info("Print", message, ...)
end

Noir.Libraries.Logging:SetMode("DebugLog")

-- Start Noir
Noir:Start()