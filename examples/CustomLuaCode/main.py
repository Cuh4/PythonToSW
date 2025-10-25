import time

from PythonToSW import (
    Addon
)

addon = Addon(
    "Testing",
    path = ".",
    port = 2000
)

def on_start():
    """
    Called when the addon starts (connects with in-game addon).
    """
    
    # Call `foo.bar.myFunction` with arguments `time.time()`
    number = addon.call_function("foo.bar.myFunction", time.time())
    
    # ...and print what was returned:
    print(f"We got: {number}")
    
def on_stop():
    """
    Called when the addon stops (disconnects with in-game addon).
    """
    
    pass

# Inject custom Lua code to be ran in-game
addon.attach_lua_file("code.lua")
# addon.attach_lua_code("print('Hello world!')") # Also works

# Start the addon
# `on_start` is called when the in-game addon connects
# `on_stop` is called when the in-game addon disconnects (game exited, etc.)
addon.start(on_start, on_stop)