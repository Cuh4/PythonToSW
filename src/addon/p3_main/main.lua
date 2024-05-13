--------------------------------------------------------
-- [Main] SW Python Addons
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
-- Setup CodeExecution
---@type CodeExecution
local CodeExecution = CodeExecution.new(__PORT__, 4) ---@diagnostic disable-line -- port is overridden by package
CodeExecution:start()