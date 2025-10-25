---
description: This guide will show you how to make your addon actually do something.
icon: laptop-code
---

# Providing Addon Functionality

{% hint style="warning" %}
The rest of this guide assumes you followed [your-first-addon.md](your-first-addon.md "mention"). If you haven't, this page might not make much sense to you.
{% endhint %}

## Calling In-Game Functions

In Stormworks Addon Lua, interacting with the game is done by calling functions in a `server` table. For example, to send a message to the chat, a typical Stormworks Lua addon would use `server.announce("Title", "Message")`.

PythonToSW allows us to do the same through Python, just like so:

{% code title="main.py" %}
```python
# ...

def on_start():
    """
    Called when the addon starts (connects with in-game addon).
    """

    addon.call(CallEnum.ANNOUNCE, "Title", "Message")
    
# ...
```
{% endcode %}

The first argument to `addon.call` represents the `server` function we want to call in-game. Every single callable `server` function is present in the `CallEnum` enum.

The rest of the arguments represent the arguments we want to pass to the `server` function. You can see what arguments every `server` function takes in over at [this link](https://github.com/Cuh4/StormworksAddonLuaDocumentation).

## What About Functions That Return Something?

PythonToSW handles that too! If you call an in-game function that returns something, the in-game addon will relay it back to us. Take a look!

```
# ...

def on_start():
    """
    Called when the addon starts (connects with in-game addon).
    """

    # `addon.call` returns a tuple of the return values!
    # Therefore, the `,` is important for only returning the players
    # rather than a tuple with the first value being the players (tuple unpacking).
    players, = addon.call(CallEnum.GET_PLAYERS)
    
    for player in players.values():
        print(player["name"])
    
# ...
```

{% hint style="info" %}
The [community Stormworks Addon Lua documentation](https://github.com/Cuh4/StormworksAddonLuaDocumentation) also shows what `server` functions return.
{% endhint %}

## In-Game Callbacks

You probably noticed that we imported `CallbackEnum` in [your-first-addon.md](your-first-addon.md "mention"). This is where we use it.

PythonToSW also allows you to connect to in-game callbacks and trigger a function whenever an in-game callback is triggered. For example, if you want to listen for players joining, you'd do:

{% code title="main.py" %}
```python
# ...

def on_player_join(steam_id: int, name: str, peer_id: int, is_admin: bool, is_auth: bool):
    pass

addon.connect(CallbackEnum.ON_PLAYER_JOIN, on_player_join)

# ...
```
{% endcode %}

You can connect to callbacks whenever, whether it's before your addon starts or even during runtime. **Ideally you should** connect to them straight away before your addon starts however.

{% hint style="info" %}
Most in-game callbacks come with arguments! You can see them in the [documentation](https://github.com/Cuh4/StormworksAddonLuaDocumentation).
{% endhint %}

`onTick` cannot be connected to and is not apart of `CallbackEnum`. This is because it is called faster than HTTP can keep up with. However, as mentioned in [your-first-addon.md](your-first-addon.md "mention"), the `Addon` class comes with a custom `on_tick` event we can connect to as an alternative, like so:

{% code title="main.py" %}
```python
# ...

def on_tick():
    """
    Called every tick, 32 ticks/s.
    """

    pass
    
addon.on_tick += on_tick

# ...
```
{% endcode %}

## Injecting Custom Lua Code

Sometimes HTTP can be too slow, or you just want to write some Lua code, PythonToSW supports this and makes it easy for you to do so!

There are two methods you can use:

* `addon.attach_lua_file(path)`: Reads the Lua file at `path` and injects the code within into the addon.
* `addon.attach_lua_code(code):` Injects the provided code into the addon.

For example, if you had a file called `helper.lua`:

{% code title="helper.lua" %}
```lua
foo = {
    bar = {}
}

function foo.bar.myFunction()
    print("I was called!")
    return 1
end
```
{% endcode %}

You can inject it into your addon like so:

{% code title="main.py" %}
```python
addon.attach_lua_file("helper.lua")
```
{% endcode %}

This will append the code to the end of your addon. Your code can also interact with `SWToPython`, the core part of the in-game addon that bridges your Python addon with the game. Additionally, there's also Noir you can interact with, a framework that provides many utilities.

{% hint style="danger" %}
This MUST be done before `addon.start()` is called!
{% endhint %}

{% hint style="info" %}
SWToPython's code can be found [here](https://github.com/Cuh4/PythonToSW/tree/main/src/SWToPython).

As for Noir, the code can be found [here](https://github.com/cuhHub/Noir).
{% endhint %}

## Calling Custom Functions

In the previous section, we created a function in `foo.bar` called `myFunction`, but that would be pointless if we couldn't call it. Luckily, we can.

To call a custom function, we can use `addon.call_function` instead of `addon.call`. We then provide a path to the function instead of a `CallEnum.`

{% code title="main.py" %}
```python
addon.call_function("foo.bar.myFunction", "arguments", "to", "pass")
```
{% endcode %}

Of course, we can also access anything the function returns. In the Lua code, the function returns `1`, let's use that.

<pre class="language-python" data-title="main.py"><code class="lang-python"><strong># Note the `,`again. This is to unpack the tuple returned by `call_function`
</strong><strong># to get the singular value
</strong><strong>value, = addon.call_function("foo.bar.myFunction", "arguments", "to", "pass")
</strong><strong>print(value) # 1
</strong></code></pre>

Easy!
