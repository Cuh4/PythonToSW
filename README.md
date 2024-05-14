# ⚙️ | PythonToSW

## 📚 | Overview
A Python package that allows you to create basic addons in Stormworks: Build and Rescue with Python.

Example:

```python
# imports
import time
import PythonToSW as PTS

# create addon
addon = PTS.Addon(addonName = "My Python Addon", port = 7800) # automatically creates an sw addon and places it in your game's addon directory

def main():
    # every 5 seconds, send a message to everyone
    while True:
        time.sleep(5)

        addon.execute(
            PTS.Announce("Server", "Hello World")
        )

addon.start(main)
```

## ⚙️ | Installing this package
⚠️ - This package isn't on PyPi or anything like that, and likely won't be. Sorry!
- Run `git clone https://github.com/Cuh4/PythonToSW`
- Extract `/src/PythonToSW`
- Import it with `import PythonToSW as PTS`

## 😔 | Quirks
- Noticeable delays. This project works through HTTP instead of converting Python code to Lua code, and HTTP is unfortunately slow.
- Lack of vehicle support. I likely won't add vehicle support, sorry! :-(
- For your addon to function, the host of the server must run the Python script behind your addon. Closing the Python script will essentially stop the addon.

## ✨ | Credit
- **Cuh4** ([GitHub](https://github.com/Cuh4)) 
