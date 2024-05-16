# ⚙️ | PythonToSW

## 📚 | Overview
A Python package that allows you to create basic addons in Stormworks: Build and Rescue with Python.

```python
import time
import PythonToSW as PTS

addon = PTS.Addon(addonName = "My Python Addon", port = 7800)

def main():
    # Every 5 seconds, send a message to everyone
    while True:
        time.sleep(5)

        addon.execute(
            PTS.Announce("Server", "Hello World", -1)
        )

addon.start(target = main) # Start the addon. This automatically creates an addon and places it in your Stormworks' addon directory, so you can easily use the addon in a save
```

## ⚙️ | Installing this package
- Use `pip install PythonToSW --upgrade`
- Import the package with `import PythonToSW as PTS` in your code

## 😔 | Quirks
- Noticeable delays. This project works through HTTP instead of converting Python code to Lua code, and HTTP is unfortunately slow.
- Lack of vehicle support. I likely won't add vehicle support, sorry! :-(
- For your addon to function, the host of the server must run the Python script behind your addon. Closing the Python script will essentially stop the addon.

## ✨ | Credit
- **Cuh4** ([GitHub](https://github.com/Cuh4)) 