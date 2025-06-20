"""
----------------------------------------------
PythonToSW: A Python package that allows you to make Stormworks addons with Python.
https://github.com/Cuh4/PythonToSW
----------------------------------------------

Copyright (C) 2025 Cuh4

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

# // Imports
import pytest

from PythonToSW import Event

# // Main
@pytest.fixture(scope = "function")
def event() -> Event:
    """
    Creates an Event instance
    
    Returns:
        Event: The Event instance
    """    
    
    return Event()

def test_subscribe(event: Event):
    """
    Tests if subscribing to an event works
    
    Args:
        event (Event): The Event instance
    """    
    
    callback_1 = lambda: None
    callback_2 = lambda: None
    
    event.subscribe(callback_1)
    event += callback_2
    
    assert callback_1 in event._callbacks, "Callback 1 should be in event callbacks after subscribe (error with `.subscribe()` method)"
    assert callback_2 in event._callbacks, "Callback 2 should be in event callbacks after subscribe (error with `+=` operator)"
    
def test_unsubscribe(event: Event):
    """
    Tests if unsubscribing from an event works
    
    Args:
        event (Event): The Event instance
    """    
    
    callback_1 = lambda: None
    callback_2 = lambda: None

    event.subscribe(callback_1)
    event += callback_2
    
    event.unsubscribe(callback_1)
    event -= callback_2
    
    assert callback_1 not in event._callbacks, "Callback 1 should not be in event callbacks after unsubscribe (error with `.unsubscribe()` method)"
    assert callback_2 not in event._callbacks, "Callback 2 should not be in event callbacks after unsubscribe (error with `-=` operator)"
    
def test_fire(event: Event):
    """
    Tests if firing an event works
    
    Args:
        event (Event): The Event instance
    """    
    
    count = 0
    
    def increment_count():
        nonlocal count
        count += 1
    
    event.subscribe(increment_count)
    event += increment_count

    event.fire()
    event()
    
    assert count == 4, "Event should have been fired twice (firing two callbacks), count is not 4"
    
@pytest.mark.asyncio
async def test_fire_async(event: Event):
    """
    Tests if firing an async event works
    
    Args:
        event (Event): The Event instance
    """    
    
    count = 0
    
    async def async_callback():
        nonlocal count
        count += 1
    
    event.subscribe(async_callback)

    await event.fire_async()
    
    assert count == 1, "Event should have been fired once, count is not 1"