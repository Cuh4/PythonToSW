--------------------------------------------------------
-- [Libraries] Base Library
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author: @cuh6_ (Discord)
        GitHub Repository: https://github.com/Cuh4/PythonToSW

    ----------------------------
]]

-------------------------------
-- // Main
-------------------------------
---@type BaseLibrary
BaseLibrary = Class("BaseLibrary", function(self, libraryName)
    self.libraryName = libraryName
    self.isLibrary = true
end)

function BaseLibrary:getLibraryName()
    return self.libraryName
end

-------------------------------
-- // Intellisense
-------------------------------
---@class BaseLibrary: Class
---@field libraryName string
---@field isLibrary boolean
---
---@field getLibraryName fun(self: BaseLibrary): string