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
import threading
import uvicorn
import time
from typing import Any, Callable
from logging import WARNING
from dataclasses import dataclass
from concurrent.futures import TimeoutError
import re

from fastapi import (
    FastAPI,
    Query,
    Depends,
    APIRouter
)

from .exceptions import (
    PTSCallbackException,
    PTSHTTPException,
    PTSLifecycleException,
    PTSCallException,
    PTSConfigException
)

from . import io
from . import http
from . import xml
from . import logger
from . import Event
from . import Persistence

from . import (
    CallEnum,
    CallbackEnum
)

from . import (
    Call,
    Token
)

from . import PACKAGE_PATH

# // Main
__all__ = [
    "ADDON_SCRIPT_CONTENT",
    "ADDON_PLAYLIST_CONTENT",
    "AddonConstants",
    "Addon",
    "DedicatedServerAddon"
]

ADDON_SCRIPT_CONTENT: str = io.quick_read(os.path.join(PACKAGE_PATH, "addon", "script.lua"), "r")
ADDON_PLAYLIST_CONTENT: str = io.quick_read(os.path.join(PACKAGE_PATH, "addon", "playlist.xml"), "r")

@dataclass(frozen = True)
class AddonConstants():
    """
    Constants used by PythonToSW addons.
    """
    
    TOKEN_EXPIRY_SECONDS: float = 12 * 60 * 60
    MAX_TPS: int = 64
    TICK_INTERVAL: int = 2
    OK_TIME_THRESHOLD_SECONDS: float = 0.5
    CALL_TIMEOUT_SECONDS: int = 20

class Addon():
    """
    A class representing a Stormworks addon.
    """
    
    def __init__(
        self,
        name: str,
        path: str,
        *,
        port: int,
        copy_from: str = None,
        addons_path: str = r"%appdata%/Stormworks/data/missions",
        uvicorn_log_level: int = WARNING,
        force_new_token: bool = False,
        constants: AddonConstants = None
    ):
        r"""
        Initializes a new instance of the `Addon` class.
        
        Args:
            name (str): The name of the addon. This should be unique and not conflict with other addons.
            path (str): The path to store data for this addon in.
            port (int): The port to run the addon on.
            copy_from (str, optional): The name of the addon to copy files from (playlist.xml, vehicles, NOT script). Can alternatively be a path to an addon directory. Defaults to None.
            addons_path (str, optional): The path to plop addons in for Stormworks to recognise. Defaults to "\%appdata\%/Stormworks/data/missions".
            uvicorn_log_level (int, optional): The log level for Uvicorn. Defaults to `logging.WARNING`.
            force_new_token (bool, optional): Whether or not to force a new token every time the addon starts. Defaults to False.
            constants (AddonConstants, optional): Constants to be used by the addon.
        """
        
        self.name = name
        self.path = path
        self.port = port
        self.addons_path: str = os.path.expandvars(addons_path)
        self.addon_path: str = os.path.join(self.addons_path, self.name)
        
        if not os.path.exists(self.addons_path):
            raise PTSConfigException(f"Addons path at {self.addons_path} does not exist.")
        
        self.copy_from = self._get_addon_copy_path(copy_from)
        self.started = False
        self.connected = False
        self.last_ok = 0
        self.constants = constants or AddonConstants()
        
        self.persistence = Persistence(os.path.join(self.path, self.name) + ".json")
        
        self.force_new_token = force_new_token
        self.token = self._get_token()
        
        self.calls: list[Call] = []
        self.callbacks: dict[CallbackEnum, Event] = {}
        self.injected_lua_code: list[str] = []

        self.app = FastAPI(title = self.name, docs_url = None, redoc_url = None, openapi_url = None)
    
        self.router = APIRouter(dependencies = [
            Depends(self._token_dependency),
            Depends(self._update_ok_dependency)
        ])
    
        self.uvicorn_log_level = uvicorn_log_level
        
        self.on_start = Event()
        self.on_stop = Event()
        self.on_tick = Event()
        
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
        
        if self.force_new_token:
            return self._generate_token()
        
        token = Token.model_validate(token)
        
        if time.time() > token.set_at + self.constants.TOKEN_EXPIRY_SECONDS:
            self._warn("Request token expired, creating a new one.")
            self._warn("If you are having issues, please run `?reload_scripts` in-game so the addon can get the updated token.")
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
    
    def _calculate_tick_dt(self) -> float:
        """
        Calculates the TPS delta time.

        Returns:
            float: The TPS.
        """

        return self.constants.TICK_INTERVAL / self.constants.MAX_TPS
    
    def _calculate_tps(self) -> float:
        """
        Calculates the TPS.

        Returns:
            float: The TPS.
        """

        return self.constants.MAX_TPS / self.constants.TICK_INTERVAL
    
    def _replace_content(self, content: str) -> str:
        """
        Replaces placeholders in the content with the addon name.
        
        Args:
            content (str): The content to replace placeholders in.
        
        Returns:
            str: The content with placeholders replaced.
        """
        
        return (
            content.replace("__REQUEST_TOKEN", self.token)
            .replace("__PORT", str(self.port))
            .replace("__TICK_INTERVAL", str(self.constants.TICK_INTERVAL))
        )
        
    def _get_addon_copy_path(self, name_or_path: str = None) -> str|None:
        """
        Gets the path to copy files from, if any.
        
        Args:
            name_or_path (str, optional): The name or path of the addon to copy files from. Defaults to None.
            
        Raises:
            PTSConfigException: If the path is invalid.
        
        Returns:
            str|None: The found path, or None if not copying from anything.
        """
        
        if name_or_path is None:
            return None
        
        if os.path.exists(name_or_path):
            if os.path.isdir(name_or_path):
                return name_or_path
            else:
                raise PTSConfigException(f"`copy_from` path exists but is not a directory.")
        
        potential_path = os.path.join(self.addons_path, name_or_path)
        
        if os.path.exists(potential_path):
            return potential_path
        else:
            raise PTSConfigException(f"Could not find `copy_from` addon. Ensure the path is correct, or provide the name of the addon instead if it is within the game's addons directory.")
        
    def _carry_over_vehicles(self):
        """
        Carries over vehicles from the copy_from addon.
        """
        
        if self.copy_from is None:
            return
        
        for vehicle_filename in os.listdir(self.copy_from):
            if os.path.splitext(vehicle_filename)[1].lower() != ".xml":
                continue
            
            if not vehicle_filename.startswith("vehicle_"):
                continue
            
            source_path = os.path.join(self.copy_from, vehicle_filename)
            dest_path = os.path.join(self.addon_path, vehicle_filename)
            
            io.quick_write(dest_path, io.quick_read(source_path, "r"), mode = "w")
            self._info(f"Carried over vehicle: {vehicle_filename}")
            
    def _get_template_playlist_content(self) -> str:
        """
        Gets the template playlist content.
        
        Raises:
            PTSConfigException: If the `copy_from` addon does not have a playlist.xml file.
        
        Returns:
            str: The template playlist content.
        """
        
        if self.copy_from is not None:
            playlist_path = os.path.join(self.copy_from, "playlist.xml")
            
            if not os.path.exists(playlist_path):
                raise PTSConfigException(f"`copy_from` addon does not have a playlist.xml file.")
            
            return io.quick_read(playlist_path, "r")
            
        return ADDON_PLAYLIST_CONTENT
        
    def _make_playlist_file(self):
        """
        Creates the playlist file for the addon.
        """
        
        content = self._get_template_playlist_content()
        content = re.sub(r"name=\"[^\"]*\"", f"name=\"{self._format_name()}\"", content, count = 1)
        content = re.sub(r"folder_path=\"[^\"]*\"", f"folder_path=\"data/missions/{self.name}\"", content, count = 1)

        playlist_path = os.path.join(self.addon_path, "playlist.xml")
        io.quick_write(playlist_path, content, mode = "w")
        
        self._info(f"Playlist created/updated successfully at: {playlist_path}")
        
    def _make_script_file(self):
        """
        Creates the script file for the addon.
        """
        
        content = self._replace_content(ADDON_SCRIPT_CONTENT)
        content += "\n\n-- User-Injected Code\n" + "\n\n".join(self.injected_lua_code)
        
        script_path = os.path.join(self.addon_path, "script.lua")
        io.quick_write(script_path, content, mode = "w")
        
        self._info(f"Script created/updated successfully at: {script_path}")
    
    def _create_addon(self):
        """
        Creates the addon directory structure.
        """
        
        if not os.path.exists(self.addon_path):
            os.makedirs(self.addon_path, exist_ok = True)

        self._carry_over_vehicles()
        self._make_playlist_file()
        self._make_script_file()
            
        self._info(f"Addon created/updated successfully at: {self.addon_path}")
        
    def _update_last_ok(self):
        """
        Updates the `last_ok` attribute.
        """
        
        self.last_ok = time.time()
    
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
            raise PTSHTTPException(401, "no_auth", "Invalid token provided.")
        
        return token
    
    def _update_ok_dependency(self):
        """
        A FastAPI dependency for updating the `last_ok` attribute whenever
        we receive a request.
        """
        
        self._update_last_ok()
    
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
            Performs nothing. Used by in-game addon to check if we're alive.
            """
            
            return "ok"
        
        @self.router.get(
            "/update",
            response_model = list[Call]
        )
        def update(handled_calls: str, triggered_callbacks: str) -> list[Call]:
            """
            Receives an update from the addon, and returns
            a list of all unprocessed calls for the addon.
            """
            
            try:
                handled_calls: list[dict] = json.loads(handled_calls)
                triggered_callbacks: list[dict] = json.loads(triggered_callbacks)
            except json.JSONDecodeError as exception:
                self._error(f"Failed to decode update data: {exception}")
                raise PTSHTTPException(400, "json_error", "Failed to decode update data.")

            for handled_call in handled_calls:
                call_id =  handled_call["ID"]
                return_values = handled_call["ReturnValues"]
                
                call = self.get_call(call_id)
                
                if call is None:
                    continue
                
                self._handle_call(call, return_values)
            
            for triggered_callback in triggered_callbacks:
                name = triggered_callback["Name"]
                arguments = triggered_callback["Arguments"]

                self._handle_callback(name, arguments)

            return self.calls

        @self.router.get(
            "/error",
            response_model = str
        )
        def error(message: str):
            """
            Propagates errors from the in-game addon to here.
            """
            
            self._error(f"{message} (from in-game)")
            return "ok"
        
        self.app.include_router(self.router)
    
    def _on_tick(self):
        """
        Fires the `on_tick` event on a separate thread.
        """
        
        self._info(f"Starting `on_tick` with TPS of {self._calculate_tps()} ({self._calculate_tick_dt():.2f}s/tick).")
        
        while True:
            self._update_connected()
            
            if self.connected:
                self.on_tick.fire_threaded()
            
            time.sleep(self._calculate_tick_dt())
            
    def _start_on_tick(self):
        """
        Starts the `on_tick` thread.
        """
        
        thread = threading.Thread(target = self._on_tick, daemon = True)
        thread.start()
    
    def _on_start(self):
        """
        Called when the addon starts.
        """
        
        self._info(f"{self.name} has connected.")
        self.on_start.fire_threaded()
        
    def _on_stop(self):
        """
        Called when the addon stops.
        """
        
        self._warn(f"{self.name} has disconnected.")
        self.on_stop.fire_threaded()
        
    def _update_connected(self):
        """
        Checks if we're connected.
        """
        
        connected = time.time() - self.last_ok < self.constants.OK_TIME_THRESHOLD_SECONDS
        
        if not self.connected and connected:
            self._on_start()
        elif self.connected and not connected:
            self._on_stop()
            
        self.connected = connected
    
    def attach_lua_code(self, code: str):
        """
        Attaches Lua code to be injected into the end of the addon script.
        
        Args:
            code (str): The Lua code to inject.
        """
        
        self.injected_lua_code.append(code)
        
    def attach_lua_file(self, path: str):
        """
        Attaches a Lua file to be injected into the end of the addon script.
        
        Args:
            path (str): The path to the Lua file to inject.
            
        Raises:
            PTSConfigException: If the file does not exist.
        """
        
        if not os.path.exists(path):
            raise PTSConfigException(f"Lua file at path {path} does not exist.")
        
        if not os.path.isfile(path):
            raise PTSConfigException(f"Lua file at path {path} is not a file.")
        
        if os.path.splitext(path)[1].lower() != ".lua":
            raise PTSConfigException(f"Lua file at path {path} is not a .lua file.")
    
        self.attach_lua_code(io.quick_read(path, "r"))
        
    def _handle_callback(self, name: str, arguments: list[Any]):
        """
        Handles a callback from the in-game addon and fires the corresponding event (if any)
        
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
        
    def connect(self, name: str|CallbackEnum, callback: Callable):
        """
        Connects the passed callable argument to a specific callback.<br>
        Consider using `CallbackEnum` for in-game callbacks.<br>
        You can fire custom callbacks via Lua code injection, which you can then
        connect to here.
        
        Args:
            name (str | CallbackEnum): The callback to connect to (in-game or custom)
            callback (Callable): The callback function to call when the event is fired.
        """
        
        if isinstance(name, CallbackEnum):
            name = name.value
        
        if name not in self.callbacks:
            self.callbacks[name] = Event()
        
        self.callbacks[name] += callback
        self._info(f"Connected function to callback: {name}")
        
    def _handle_call(self, call: Call, return_values: list[Any]):
        """
        Handles the finalization of a call to a function in the addon.
        
        Args:
            call (Call): The call to handle.
            return_values (list[Any]): The return values from the call.
        """
        
        call.future.set_result(tuple(return_values))
        self.calls.remove(call)
        
    def get_call(self, call_id: str) -> Call|None:
        """
        Gets a call by its ID.
        
        Args:
            call_id (str): The ID of the call to get.
        
        Returns:
            Call|None: The call if it exists, otherwise None.
        """
        
        for call in self.calls:
            if call.id == call_id:
                return call
            
        return None
        
    def does_call_exist(self, call_id: str) -> bool:
        """
        Checks if a call with the given ID exists.
        
        Args:
            call_id (str): The ID of the call to check for.
        
        Returns:
            bool: True if the call exists, False otherwise.
        """
        
        return self.get_call(call_id) is not None
        
    def call(self, function: CallEnum, *args) -> tuple[Any, ...]:
        """
        Calls a `server.` function in the addon.
        
        Args:
            function (CallEnum): The name of the function to call.
            *args: The arguments to pass to the function.
            
        Raises:
            PTSCallException: If the call times out.
        
        Returns:
            tuple[Any, ...]: Whatever the function returns.
        """
        
        return self.call_function(f"server.{function.value}", *args)
        
    def call_function(self, path: str, *args) -> tuple[Any, ...]:
        """
        Calls a custom function in the addon.<br>
        You can inject custom functions into the addon script using `attach_lua_code` or `attach_lua_file`.
        
        Args:
            path (str): The path of the function to call.
            *args: The arguments to pass to the function.
            
        Raises:
            PTSCallException: If the call times out.
        
        Returns:
            tuple[Any, ...]: Whatever the function returns.
        """
        
        call_id = http.generate_uuid()

        call = Call(
            id = call_id,
            path = path,
            arguments = list(args)
        )

        self.calls.append(call)
        
        while not self.connected:
            time.sleep(0.01)

        try:
            return call.future.result(self.constants.CALL_TIMEOUT_SECONDS)
        except TimeoutError as exception:
            raise PTSCallException(f"Call with ID {call_id} timed out.") from exception
        
    def start(self, on_start: Callable = None, on_stop: Callable = None):
        """
        Starts the addon.
        
        Args:
            on_start (Callable, optional): A function to call when the addon starts (connection is established). Defaults to None.
            on_stop (Callable, optional): A function to call when the addon stops (connection is lost). Defaults to None.
        
        Raises:
            PTSLifecycleException: If the addon has already started.
        """
        
        if self.started:
            raise PTSLifecycleException("Addon has already started. Cannot start it more than once.")
        
        self._info(f"Starting on port {self.port}...")     
        
        self.started = True
        self._create_addon()
        self._create_endpoints()
        self._start_on_tick()

        if on_start is not None:
            self.on_start += on_start
            
        if on_stop is not None:
            self.on_stop += on_stop

        uvicorn.run(
            self.app,
            host = "localhost",
            port = self.port,
            log_level = self.uvicorn_log_level
        )

class DedicatedServerAddon(Addon):
    """
    A class representing an addon specifically for Stormworks dedicated servers.

    Note that the `Addon` class can also be used for dedicated servers, but this class
    makes it easier by automatically setting the addons path to the correct location
    and modifying the server_config.xml file to include the addon.
    """
    
    def __init__(
        self,
        name: str,
        path: str,
        dedicated_server_path: str,
        server_config_path: str,
        *,
        port: int,
        copy_from: str = None,
        uvicorn_log_level: int = WARNING,
        force_new_token: bool = False,
        constants: AddonConstants = None
    ):
        """
        Initializes a new instance of the `DedicatedServerAddon` class.
        
        Args:
            name (str): The name of the addon. This should be unique and not conflict with other addons.
            path (str): The path to store data for this addon in.
            dedicated_server_path (str): The path to the dedicated server installation.
            server_config_path (str): The path to the server_config.xml file. For Windows, this is usually in `%appdata%/Stormworks` unless overridden via command line arguments to the server executable.
            port (int): The port to run the addon on.
            copy_from (str, optional): The name of the addon to copy files from (playlist.xml, vehicles, NOT script). Can alternatively be a path to an addon directory. Defaults to None.
            uvicorn_log_level (int, optional): The log level for Uvicorn. Defaults to `logging.WARNING`.
            force_new_token (bool, optional): Whether or not to force a new token every time the addon starts. Defaults to False.
            constants (AddonConstants, optional): Constants to be used by the addon.
        """
        
        super().__init__(
            name = name,
            path = path,
            port = port,
            copy_from = copy_from,
            addons_path = os.path.join(dedicated_server_path, "rom/data/missions"),
            uvicorn_log_level = uvicorn_log_level,
            force_new_token = force_new_token,
            constants = constants
        )
        
        self.server_config_path = server_config_path
        
        if not os.path.exists(self.server_config_path):
            raise PTSConfigException(f"Server config path at {self.server_config_path} does not exist.")
        
        if not os.path.isfile(self.server_config_path):
            raise PTSConfigException(f"Server config path at {self.server_config_path} is not a file.")
        
        if os.path.splitext(self.server_config_path)[1].lower() != ".xml":
            raise PTSConfigException(f"Server config path at {self.server_config_path} is not an XML file.")
        
    def _get_server_config(self) -> dict:
        """
        Returns the XML decoded server_config.xml file.
        
        Returns:
            dict: The server config as a dictionary.
        """
        
        return xml.decode(io.quick_read(self.server_config_path, "r"))
    
    def _get_addon_path_for_server_config(self) -> str:
        """
        Returns the path to this addon for use in the server_config.xml file.
        
        Returns:
            str: The path to this addon for use in the server_config.xml file.
        """
        
        return f"rom/data/missions/{self.name}"
    
    def _is_in_server_config(self, config: dict) -> bool:
        """
        Checks if the addon is in the server_config.xml file.
        
        Args:
            config (dict): The server config as a dictionary.
        
        Returns:
            bool: True if the addon is in the server_config.xml file, False otherwise.
        """
        
        for playlist in config["server_data"]["playlists"]["path"]:
            if playlist["@path"] == self._get_addon_path_for_server_config():
                return True
            
        return False
    
    def _save_new_server_config(self, config: dict):
        """
        Saves a new server_config.xml file.
        
        Args:
            config (dict): The server config as a dictionary.
        """
        
        io.quick_write(self.server_config_path, xml.encode(config), mode = "w")
        
    def _setup_server_config(self):
        """
        Sets up the server_config.xml file to include this addon.
        """
        
        config = self._get_server_config()
        
        if self._is_in_server_config(config):
            self._info(f"Addon already in `server_config.xml`, skipping.")
            return
        
        config["server_data"]["playlists"]["path"].append({
            "@path": self._get_addon_path_for_server_config()
        })
        
        self._save_new_server_config(config)
        
        self._info(f"Added addon to `server_config.xml` at: {self.server_config_path}")
        
    def _create_addon(self):
        """
        Creates the addon directory structure.
        """
        
        super()._create_addon()
        self._setup_server_config()