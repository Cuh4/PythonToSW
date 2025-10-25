---
description: PythonToSW supports addons for Stormworks dedicated servers!
icon: server
---

# Dedicated Servers

## Setting Up An Addon

To create an addon for a dedicated server, use `DedicatedServerAddon` instead of `Addon`.

```python
from PythonToSW import DedicatedServerAddon

addon = DedicatedServerAddon(
    "Addon Name",
    path = ".",
    dedicated_server_path = "path/to/server",
    server_config_path = "path/to/server/server_config.xml",
    port = 2000
)
```

`dedicated_server_path` is the path to your dedicated server's root directory (the directory containing `server64.exe`, etc).

`server_config_path` is the path to your dedicated server's `server_config.xml` file. It's normally at `%appdata%/Stormworks/server_config.xml` unless you override it with a command line argument to `server/server64.exe`.

The other arguments are all covered in [your-first-addon.md](your-first-addon.md "mention").

## `Addon` vs `DedicatedServerAddon`

You can still make your addon work for dedicated servers by using the `Addon` class, but it's simply more inconvenient. You have to override a bunch of paths, set up your server config, etc.

The `DedicatedServerAddon` class handles this hassle for you. It automatically determines where to put your addon (`rom/data/missions` in your server's directory) and it updates your `server_config.xml` to include your addon if it's not in there already.

Essentially, for dedicated servers, always use the `DedicatedServerAddon` class. It inherits from `Addon`, so the behaviour will still be the same.
