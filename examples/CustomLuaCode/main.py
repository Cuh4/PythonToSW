"""
An example showcasing Lua code injection.

When the addon starts, `code.lua` is injected into the in-game addon's code.

The code contains a function which we call through Python.
The code also invokes a callback that we can connect to.
"""

import os
import time

from PythonToSW import (
    Addon
)

# Just so paths work regardless of current working directory
SELF_PATH = os.path.dirname(__file__)

addon = Addon(
    "Testing",
    path = SELF_PATH,
    port = 2000
)

def on_start():
    """
    Called when the addon starts (connects with in-game addon).
    """
    
    # Call `Foo.MyFunction` with arguments `time.time()`
    number, = addon.call_function("Foo.MyFunction", time.time())
    
    # ...and print what was returned:
    print(f"We got: {number}")
    
def on_stop():
    """
    Called when the addon stops (disconnects with in-game addon).
    """
    
    pass

def on_foo(message: str):
    """
    Custom callback triggered by the custom Lua code.
    """
    
    print(f"Foo called! Message: {message}")

# Inject custom Lua code to be ran in-game
addon.attach_lua_file(os.path.join(SELF_PATH, "code.lua"))
# addon.attach_lua_code("print('Hello world!')") # Also works

# Listen for custom callback
addon.connect("foo", on_foo)

# Start the addon
# `on_start` is called when the in-game addon connects
# `on_stop` is called when the in-game addon disconnects (game exited, etc.)
addon.start(on_start, on_stop)