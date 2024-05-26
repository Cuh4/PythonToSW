--------------------------------------------------------
-- [Dependencies] Class
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author: @Cuh4 (GitHub)
        GitHub Repository: https://github.com/Cuh4/PythonToSW (from: https://github.com/Cuh4/LuaClasses)

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

-- Create a class
---@param name string
---@param init fun(self: table, ...: any)
---@param parent Class|nil
function Class(name, init, parent)
    -- // Class Creation
    -- Create a class
    ---@type Class
    local class = {} ---@diagnostic disable-line
    class.__name = name
    class.__parent = parent
    class.__init = init

    -- Create a function that creates an object from this class
    ---@param ... any
    function class.new(...)
        -- create object
        ---@type ClassObject
        local object = {} ---@diagnostic disable-line
        class:__descend(object, {new = true})

        -- call init of object. this init function will provide the needed attributes to the object
        if object.__init then
            object.__init(object, ...)
        end

        -- return the object
        return object
    end

    -- Create function to provide values from a class or class object to a class object
    ---@param from Class|ClassObject
    ---@param object ClassObject
    ---@param exceptions table
    function class.__descend(from, object, exceptions)
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

    -- // Class Methods
    -- Create method to initialize and inherit from parent
    function class:initializeParent(...)
        if not self.__parent then
            return
        end

        local object = self.__parent.new(...)
        self.__descend(object, self, {})
    end

    -- Create comparison method
    ---@param object ClassObject
    function class:isSameType(object)
        return self.__name == object.__name
    end

    -- // Finalization
    -- Return the class
    return class
end

-------------------------------
-- // Intellisense
-------------------------------

---@class Class A class that can be used for OOP. use the .new() function to create an object from this class
---@field __name string The name of this class
---@field __init fun(self: ClassObject, ...) A function that initializes objects created from this class
---@field __parent Class|nil The parent class that this class inherits from
---
---@field new fun(...: any): ClassObject A function to create an object from this class
---@field __descend fun(from: Class|ClassObject, object: ClassObject, exceptions: table<any, boolean>) A helper function that copies important values from the class to an object
---@field initializeParent fun(self: ClassObject, ...: any) A method that initializes the parent class for this object
---@field isSameType fun(self: ClassObject, object: ClassObject): boolean A method that returns whether an object is identical to this one

---@class ClassObject: Class An object created from a class