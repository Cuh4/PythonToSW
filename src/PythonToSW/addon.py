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
from __future__ import annotations

import os
import json
from fastapi import FastAPI
import uvicorn
from typing import Any, Callable
from logging import WARNING
from concurrent.futures import Future

from . import (
    ADDON_SCRIPT_CONTENT,
    ADDON_PLAYLIST_CONTENT
)

from . import io
from . import exceptions
from . import xml
from . import http
from . import Event
from . import logger

from .models import (
    Call
)

# // Main
class Addon():
    """
    A class representing a Stormworks addon.
    """
    
    def __init__(
        self,
        name: str,
        *,
        port: int,
        path: str|None = r"%appdata%/Stormworks/data/missions"
    ):
        r"""
        Initializes a new instance of the `Addon` class.
        
        Args:
            name (str): The name of the addon. This should be unique and not conflict with other addons.
            port (int): The port to run the addon on.
            path (str | None, optional): The path to the addon data. Defaults to "\%appdata\%/Stormworks/data/missions".
        """
        
        self.name = name
        self.port = port
        self.path = os.path.join(os.path.expandvars(path), self.name)
        
        self.token = http.generate_uuid()
        
        self.files = {
            "script.lua" : ADDON_SCRIPT_CONTENT,
            "playlist.xml" : ADDON_PLAYLIST_CONTENT
        }
        
        self.calls: dict[str, Call] = {}
        self.callbacks: dict[str, Event] = {}

        self.app = FastAPI()
        
        self.on_start = Event()
        
    def _debug(self, message: str):
        """
        Logs a debug message.
        
        Args:
            message (str): The message to log.
        """
        
        logger.debug(f"[Addon: {self.name}] {message}")
        
    def _info(self, message: str):
        """
        Logs an informational message.
        
        Args:
            message (str): The message to log.
        """
        
        logger.info(f"[Addon: {self.name}] {message}")
        
    def _warn(self, message: str):
        """
        Logs a warning message.
        
        Args:
            message (str): The message to log.
        """
        
        logger.warning(f"[Addon: {self.name}] {message}")
        
    def _error(self, message: str):
        """
        Logs an error message.
        
        Args:
            message (str): The message to log.
        """
        
        logger.error(f"[Addon: {self.name}] {message}")
    
    def _format_name(self) -> str:
        """
        Formats the addon name for display to the user.

        Returns:
            str: The formatted name of this addon.
        """
        
        return f"(PTS) {self.name}"
    
    def _replace_content(self, content: str) -> str:
        """
        Replaces placeholders in the content with the addon name.
        
        Args:
            content (str): The content to replace placeholders in.
        
        Returns:
            str: The content with placeholders replaced.
        """
        
        return content.replace("$FORMATTED_ADDON_NAME", self._format_name()).replace("$ADDON_NAME", self.name).replace("$REQUEST_TOKEN", self.token)
    
    def _create_addon(self):
        """
        Creates the addon directory structure.
        """
        
        if not os.path.exists(self.path):
            os.makedirs(self.path, exist_ok = True)
        
        for file, content in self.files.items():
            self._info(f"Creating/updating file: {file}")
            
            path = os.path.join(self.path, file)
            io.quick_write(path, self._replace_content(content), mode = "w")
            
        self._info(f"Addon created/updated successfully at: {self.path}")
    
    def _create_endpoints(self):
        """
        Creates the FastAPI endpoints for the addon.
        """
        
        @self.app.get("/calls")
        def calls():
            """
            Returns a list of all calls made to the addon.
            """

            return [call.model_dump_json(indent = 4) for call in self.calls.values()]
        
        @self.app.get("/calls/{call_id}/return")
        def call_return(call_id: str, return_values: str):
            """
            Handles the return values from a call to the addon.
            
            Args:
                call_id (str): The ID of the call.
                return_values (str): The return values from the call, serialized as a JSON string.
            """
            
            if call_id not in self.calls:
                self._error(f"Call with ID {call_id} not found.")
                return ""
            
            try:
                return_values = json.loads(return_values)
            except json.JSONDecodeError as exception:
                self._error(f"Failed to decode return values: {exception}")
                return ""
            
            call = self.calls[call_id]
            self._handle_call(call, return_values)

            return ""
            
        @self.app.get("/callback/{name}")
        def callback(name: str, arguments: str):
            """
            Handles a callback from the Stormworks game.
            
            Args:
                name (str): The name of the callback.
                arguments (str): The arguments passed to the callback, serialized as a JSON string.
            """
            
            if name not in self.callbacks: # that's fine
                return ""
            
            try:
                arguments = json.loads(arguments)
            except json.JSONDecodeError as exception:
                self._error(f"Failed to decode callback arguments: {exception}")
                return ""
            
            callback = self.callbacks[name]
            callback(arguments)
            
            return ""
    
    def _on_start(self):
        """
        Internal handler for the FastAPI app startup event.
        """
        
        self._info("Started!")
        self.on_start.fire()
        
    def start(self):
        """
        Starts the addon.
        """
        
        self._info(f"Starting on port {self.port}...")     
        
        self._create_addon()
        
        self.app.add_event_handler("startup", self._on_start)
        
        uvicorn.run(
            self.app,
            host = "127.0.0.1",
            port = self.port,
            log_level = WARNING
        )
        
    def connect(self, name: str, callback: Callable):
        """
        Connects a callback to a specific event in the addon.
        
        Args:
            name (str): The name of the event to connect to, e.g "onTick".
            callback (Callable): The callback function to call when the event is fired.
        """
        
        if name not in self.callbacks:
            self.callbacks[name] = Event()
        
        self.callbacks[name] += callback
        self._info(f"Connected callback to event: {name}")
        
    def _handle_call(self, call: Call, return_values: list[Any]):
        """
        Handles the finalization of a call to a `server.` function in the addon.
        
        Args:
            call (Call): The call to handle.
            return_values (list[Any]): The return values from the call.
        """
        
        call.future.set_result(tuple(return_values))
        del self.calls[call.id]
        
    def call(self, function: str, *args) -> tuple[Any, ...]:
        """
        Calls a `server.` function in the addon.
        
        Args:
            function (str): The name of the function to call.
            *args: The arguments to pass to the function.
        
        Returns:
            tuple[Any, ...]: Whatever the function returns.
        """
        
        call_id = http.generate_uuid()

        call = Call(
            id = call_id,
            name = function,
            arguments = list(args),
            future = Future()
        )

        self.calls[call_id] = call

        return call.future.result()