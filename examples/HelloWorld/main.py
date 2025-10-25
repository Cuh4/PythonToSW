from PythonToSW import (
    Addon,
    CallEnum,
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
    
    # If you was to code a Lua addon with the same behaviour, it'd look like: server.announce("Server", "Hello world!")
    addon.call(CallEnum.ANNOUNCE, "Server", "Hello world!")
    
def on_stop():
    """
    Called when the addon stops (disconnects with in-game addon).
    """
    
    print("Whups, we lost connection!")
    
def on_tick():
    """
    Called every addon tick.
    """
    
    pass
    
# Call `on_tick` every addon tick
# Note that this doesn't connect to the in-game `onTick` callback as HTTP would not be able to keep up
# Instead, this is a simulated version that is called at a manageable rate (32 TPS, theoretical max)
addon.on_tick += on_tick

# Start the addon
# `on_start` is called when the in-game addon connects
# `on_stop` is called when the in-game addon disconnects (game exited, etc.)
addon.start(on_start, on_stop)