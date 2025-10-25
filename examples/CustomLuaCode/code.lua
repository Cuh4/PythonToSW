--[[
    This code simply sends up a callback ("foo")
    when the PythonToSW server connects.<br>

    It also provides a custom function ("Foo.MyFunction") which
    is called from the Python side.
]]

---@class Foo: NoirService
Foo = Noir.Services:CreateService("Foo")

function Foo:ServiceStart()
    SWToPython.Uplink.OnConnect:Connect(function()
        SWToPython.Uplink:InvokeCallback("foo", {"Hello from in-game!"})
    end)
end

---@param time number
function Foo.MyFunction(time)
    print("I was called! Time provided by the Python side: "..time)
    return 1
end