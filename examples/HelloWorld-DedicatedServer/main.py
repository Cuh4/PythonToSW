"""
A simple hello world addon.<br>
When the addon starts, "Hello world!" is sent into chat.<br>
This version is to be ran on a dedicated server, and shows that PythonToSW can handle that.
"""

import os

from PythonToSW import (
    DedicatedServerAddon,
    CallEnum,
)

# `DedicatedServerAddon` will handle the nifty bits for you.
# The dedicated server's config will automatically be updated to accommodate this addon,
# so you don't need to worry about that.
addon = DedicatedServerAddon(
    "Testing",
    path = os.path.dirname(__file__),
    dedicated_server_path = "C:/Path/To/Stormworks/Server/Directory",
    server_config_path = "C:/Path/To/Stormworks/Server/Directory/server_config.xml",    # usually at `%appdata%\\Stormworks\\server_config.xml` on Windows
    port = 2000                                                                         # unless overridden via server executable command-line argument
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