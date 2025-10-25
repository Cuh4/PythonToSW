---
description: A quick introduction to PythonToSW.
icon: play
cover: .gitbook/assets/banner.png
coverY: 0
layout:
  width: default
  cover:
    visible: true
    size: hero
  title:
    visible: true
  description:
    visible: true
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
  metadata:
    visible: true
---

# Intro

## What is PythonToSW

PythonToSW is a Python package that allows you to code up addons for Stormworks: Build and Rescue in Python rather than using Lua. It uses HTTP under the hood to communicate with an in-game addon to carry out function calls.

Unfortunately, since HTTP is used, any PythonToSW addon will be 2x slower than a normal addon due to the request rate limit (one request every two ticks, or 32 requests/s).

## Installation

To install or update PythonToSW, simply run:

```batch
pip install PythonToSW --upgrade
```

## Learn More

{% hint style="warning" %}
Knowledge on Stormworks addons is recommended before proceeding. Consider reading the in-game addon documentation as this documentation assumes you know a decent amount about Stormworks addons.
{% endhint %}

Refer to [examples.md](examples.md "mention") to find examples.

Refer to [Broken link](broken-reference "mention") to learn PythonToSW one step at a time.

Refer to [behind-the-scenes.md](behind-the-scenes.md "mention") to learn what happens in the code for PythonToSW without actually reading the code.

## Links

[PythonToSW GitHub Repo](https://github.com/Cuh4/PythonToSW/tree/main)

[Report Bugs/Offer Suggestions](https://github.com/Cuh4/PythonToSW/issues)

[PyPi](https://pypi.org/project/PythonToSW/)
