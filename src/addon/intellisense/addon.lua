--------------------------------------------------------
-- [Intellisense] Addon
--------------------------------------------------------

--[[
    ----------------------------

    CREDIT:
        Author: @cuh6_ (Discord)
        GitHub Repository: https://github.com/Cuh4/PythonToSW
        File Created: 14/01/2024 (dd/mm/yy)

    ----------------------------
]]

-------------------------------
-- // Lua LSP Diagnostics
-------------------------------
---@diagnostic disable

-------------------------------
-- // Save Data
-------------------------------

-------------------------------
-- // Main
-------------------------------
---@class ad_asteroids_asteroid: af_libs_class_class
_ = {
    __name__ = "asteroid",

    properties = {
        position = matrix.translation(),
        type = nil, ---@type ad_asteroids_asteroidType
        target = nil, ---@type af_services_player_player
        group = nil, ---@type af_services_group_group
        id = 0
    },

    ---@param self ad_asteroids_asteroid
    remove = function(self) end,

    ---@param self ad_asteroids_asteroid
    ---@param newPos SWMatrix
    move = function(self, newPos) end
}

---@class ad_asteroids_asteroidType: af_libs_class_class
_ = {
    __name__ = "asteroidType",

    properties = {
        sizeName = "",
        playlist_id = 0
    },

    ---@param self ad_asteroids_asteroidType
    ---@param position SWMatrix
    ---@return af_services_group_group
    spawn = function(self, position) end
}