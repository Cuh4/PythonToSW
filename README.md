![Banner](imgs/banner.png)

## 📚 | Overview
PythonToSW is a Python package that allows you to create addons in Stormworks: Build and Rescue with Python through HTTP using FastAPI under the hood.

### Working Example
```python
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
```

More examples can be found in the [examples directory](/examples/).

## ⚙️ | Installing this package
- Use `pip install PythonToSW --upgrade`
- Import the package with `import PythonToSW as PTS` in your code

## ✅ | Advantages
- Since the addon is running outside of the game, you get much more control with your addon and aren't limited by the limitations of Stormworks Lua.
    - You can send HTTP requests to places other than localhost, and using methods other than `GET`.
    - You can write to/read from files.
    - ... and so on.
- Classes (since we're using Python here)
- The source code of your addon can't be accessed via malicious actors.
    - Yup. If someone with malicious intent is in a server with an addon, they can get the addon's raw code (although difficult to do).
    - Because PythonToSW uses HTTP and doesn't compile code to Lua, the Python source code is completely hidden and the only code malicious actors can get is the Lua code that connects to the PythonToSW server (which is already open-source).

## ❌ | Disadvantages
- Noticeable delays. This project works through HTTP instead of converting Python code to Lua code, and HTTP is unfortunately slow (limited to one request every two ticks, aka 32 requests/sec).
- For your addon to function, the host of the server must run the Python script behind your addon. Closing the Python script will essentially stop the addon.
- Uploading your addon to the workshop is pointless as the Python code is what makes your addon work. Distributing your addon therefore becomes harder and less convenient for users to download and use.

## ✨ | Credit
- **Cuh4** ([GitHub](https://github.com/Cuh4)) 