foo = {}
foo.bar = {}

---@param time number
function foo.bar.myFunction(time)
    print("I was called! Time provided by the Python side: "..time)
    return 1
end