---
description: >-
  So far, this has gone without mention, but the `Addon` class takes in a
  `constants` argument. This page will go over that.
icon: screwdriver-wrench
---

# Modifying Addon Constants

## What is `AddonConstants`?

As said, `Addon` takes in a `constants` argument. We can pass a custom `AddonConstants` instance to override the default constants.

The constants dictate how long a token takes to expire, the tick rate for the `on_tick` event, how long since the last request from `SWToPython` to declare that the addon has stopped, etc.

## Using Custom Constants

Simply pass in a custom `AddonConstants` instance to the `constants` argument of `Addon`.

{% code title="" %}
```python
# ...

constants = AddonConstants(
    TICK_INTERVAL = 4, # tps = 64 / TICK_INTERVAL, so this would make the TPS 16
    CALL_TIMEOUT_SECONDS = 5 # calls will error after 5 seconds if they don't get a response
)

addon = Addon(
    "My Addon",
    path = ".",
    port = 2500,
    
    constants = constants
)

# ...
```
{% endcode %}

{% hint style="danger" %}
`TICK_INTERVAL` should **always** be `2` or above. Setting to `1` would mean `on_tick` would be fired 64 times a second, which is 2x more than HTTP can keep up with. Therefore, if you was to use `addon.call` (or other similar methods) every tick, the queue would keep growing and growing until it gets too much.
{% endhint %}
