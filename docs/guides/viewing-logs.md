---
description: This guide will show you how to view logs sent by the in-game addon.
icon: message-lines
---

# Viewing Logs

## Logging

You likely won't need to view logs from the in-game addon, but if you ever inject Lua code and use `print` or something of the sorts, you won't be able to see the message unless you use specific software.

Additionally, if the in-game addon runs into an error, it will be helpful to look at the logs to figure out why it happened (be sure to fill out an issue too! See [..](../ "mention") for a link).

## Log Software

To view the logs, you'll need either:

* [DebugView++](https://github.com/CobaltFusion/DebugViewPP) (Recommended)
* [DebugView from Windows SysInternals](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview)

{% hint style="warning" %}
This is for Windows only (needs factchecking). If you're on Linux or Mac, you will unfortunately have to figure this out on your own.

Feel free to push a PR for this page if you figure it out!
{% endhint %}

After installing, simply open it up and start capturing logs. You should see logs coming from the in-game addon after doing so, especially when you finish loading into a save with your addon enabled.
