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

from fastapi import (
    FastAPI,
    Query,
    Depends,
    APIRouter
)

import uvicorn
import time
from typing import Any, Callable
from logging import WARNING
from concurrent.futures import Future

from . import (
    ADDON_SCRIPT_CONTENT,
    ADDON_PLAYLIST_CONTENT,
    PACKAGE_PATH
)

from .exceptions import (
    PTSCallbackException,
    PTSHTTPException
)

from . import io
from . import http
from . import logger
from . import Event
from . import Persistence
from . import CallEnum

from . import (
    Call,
    Token
)

# // Main
__all__ = [
    "Addon",
    "TOKEN_EXPIRY_SECONDS"
]

TOKEN_EXPIRY_SECONDS = 12 * 60 * 60 # how long addon request tokens take to expire

class Addon():
    """
    A class representing a Stormworks addon.
    """
    
    def __init__(
        self,
        name: str,
        *,
        port: int,
        path: str|None = r"%appdata%/Stormworks/data/missions",
        uvicorn_log_level: int = WARNING
    ):
        r"""
        Initializes a new instance of the `Addon` class.
        
        Args:
            name (str): The name of the addon. This should be unique and not conflict with other addons.
            port (int): The port to run the addon on.
            path (str | None, optional): The path to Stormworks addon storage. Defaults to "\%appdata\%/Stormworks/data/missions".
            uvicorn_log_level (int, optional): The log level for Uvicorn. Defaults to `logging.WARNING`.
        """
        
        self.name = name
        self.port = port
        self.path = os.path.join(os.path.expandvars(path), self.name)
        
        self.persistence = Persistence(os.path.join(PACKAGE_PATH, "addon-persistence", self.name) + ".json")
        
        self.token = self._get_token()
        
        self.files = {
            "script.lua" : ADDON_SCRIPT_CONTENT,
            "playlist.xml" : ADDON_PLAYLIST_CONTENT
        }
        
        self.calls: dict[str, Call] = {}
        self.callbacks: dict[str, Event] = {}

        self.app = FastAPI(title = self._format_name(), docs_url = None, redoc_url = None, openapi_url = None)
        self.router = APIRouter(dependencies = [Depends(self._token_dependency)])
        self.uvicorn_log_level = uvicorn_log_level
        
        self.on_start = Event()
        
    def _generate_token(self) -> str:
        """
        Generates a new token for this addon.
        This overwrites persistence data. Call this carefully.
        
        Returns:
            str: The generated token.
        """
        
        token = Token(
            token = http.generate_uuid(),
            set_at = time.time()
        )

        self.persistence.set("token", token.model_dump())
        return token.token
        
    def _get_token(self) -> str:
        """
        Returns the request token for this addon.

        Tokens are saved and reused temporarily per-addon.
        This is to prevent the addon user having to reload
        the in-game addon every time the addon is started
        as the token would be regenerated.
        
        Returns:
            str: The generated token.
        """
        
        token = self.persistence.get("token")
        
        if token is None:
            return self._generate_token()
        
        token = Token.model_validate(token)
        
        if time.time() > token.set_at + TOKEN_EXPIRY_SECONDS:
            self._warn("Request token expired, creating a new one.")
            return self._generate_token()
        else:
            return token.token
    
    def _validate_name(self, name: str):
        """
        Validates the name of the addon.
        
        Args:
            name (str): The name of the addon.
        """
        
        return name.replace("/", "").replace("\r", "").replace("\n", "").replace("\\", "")
        
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
        
        return content.replace("__FORMATTED_ADDON_NAME", f"{self._format_name()}").replace("__ADDON_NAME", self.name).replace("__REQUEST_TOKEN", f"\"{self.token}\"").replace("__PORT", str(self.port))
    
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
    
    def _token_dependency(self, token: str = Query()):
        """
        A FastAPI dependency for checking the request token.
        
        Args:
            token (str): The token to check for in the query parameters.
            
        Raises:
            PTSHTTPException: If the token does not match the expected token.
        
        Returns:
            str: The token if it exists, otherwise raises an PTSHTTPException.
        """
        
        if token != self.token:
            raise PTSHTTPException(401, "no_auth: Invalid token provided.")
        
        return token
    
    def _create_endpoints(self):
        """
        Creates the FastAPI endpoints for the addon.
        """
        
        @self.router.get(
            "/ok",
            response_model = str
        )
        def alive() -> str:
            """
            Performs nothing. This is for the in-game addon to find out if we're alive.
            """
            
            return "ok"
        
        @self.router.get(
            "/calls",
            response_model = list[Call]
        )
        def calls() -> list[Call]:
            """
            Returns a list of all unprocessed calls for the in-game addon.
            """

            return [*self.calls.values()]
        
        @self.router.get(
            "/calls/{call_id}/return",
            response_model = str
        )
        def call_return(call_id: str, return_values: str) -> str:
            """
            Completes a call.
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
            
        @self.router.get(
            "/callbacks/{name}",
            response_model = str
        )
        def callback(name: str, arguments: str):
            """
            Handles a callback from the in-game addon.
            """
            
            if name not in self.callbacks: # that's fine
                return ""
            
            try:
                arguments = json.loads(arguments)
            except json.JSONDecodeError as exception:
                self._error(f"Failed to decode callback arguments: {exception}")
                return ""
            
            self._handle_callback(name, arguments)
            
            return ""
        
        @self.router.get(
            "/error",
            response_model = str
        )
        def error(message: str):
            """
            Propagates errors from the in-game addon to here.
            """
            
            self._error(f"{message} (from in-game)")
            return ""
        
        self.app.include_router(self.router)
    
    def _on_start(self):
        """
        Internal handler for the FastAPI app startup event.
        """
        
        self._info("Started!")
        self.on_start.fire_threaded()
        
    def start(self):
        """
        Starts the addon.
        """
        
        self._info(f"Starting on port {self.port}...")     
        
        self._create_addon()
        self._create_endpoints()
        
        self.app.add_event_handler("startup", self._on_start)
        
        uvicorn.run(
            self.app,
            host = "localhost",
            port = self.port,
            log_level = self.uvicorn_log_level
        )
        
    def _handle_callback(self, name: str, arguments: list[Any]):
        """
        Handles a callback from Stormworks and fires the corresponding event (if any)
        
        Args:
            name (str): The name of the callback.
            arguments (list[Any]): The arguments passed to the callback.
            
        Raises:
            PTSCallbackException: If the event does not exist.
        """
        
        if name not in self.callbacks:
            return
        
        try:
            self.callbacks[name].fire_threaded(*arguments)
        except Exception as exception:
            raise PTSCallbackException(f"Something went wrong with the `{name}` event. Are your callbacks expecting the right amount of arguments?") from exception
        
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
        
    def call(self, function: CallEnum, *args) -> tuple[Any, ...]:
        """
        Calls a `server.` function in the addon.
        
        Args:
            function (CallEnum): The name of the function to call.
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