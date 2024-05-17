# ----------------------------------------
# [PythonToSW] Addon
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
The main module in this package.

Copyright (C) 2024 Cuh4

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

# ---- // Imports
import os
import flask
import flask.cli
import json
import threading
import logging
import werkzeug
import werkzeug.utils
import colorama
from datetime import datetime

from . import helpers
from . import exceptions
from . import executions
from . import Event

# ---- // Main
colorama.init()

class Addon():
    """
    A class that represents a Stormworks addon.
    
    >>> import PythonToSW as PTS
    >>> addon = PTS.Addon("MyAddon", port = 3000)
    >>>
    >>> def main():
    >>>     addon.execute(PTS.Announce("Server", "Hello World", -1))
    >>>
    >>> addon.start(target = main)
    
    Args:
        addonName: (str) The name of the addon.
        port: (int) The port to listen for requests from the in-game addon on.
        allowLogging: (bool = True: Whether to allow logging.
        destinationAddonPath: (str = None) The destination path for the addon. You will need to provide this if you are on a non-Windows OS. Defaults to %APPDATA%\Stormworks\data\missions.
        
    Raises:
        exceptions.InternalError: Raised if the PythonToSW base addon doesn't exist.
        exceptions.PathNotFound: Raised if the destination addon path does not exist. If this is raised, you likely haven't installed and ran Stormworks. If you have, you will need to manually set the destinationAddonPath argument.
    """

    def __init__(self, addonName: str, port: int, *, allowLogging: bool = True, destinationAddonPath: str = os.path.join(os.getenv("APPDATA"), "Stormworks", "data", "missions")):
        # main attributes
        self.addonName = addonName
        self.port = port
        self.app = flask.Flask(__name__)
        self.running = False
        self.allowLogging = allowLogging
        self.addonPath = os.path.join(os.path.dirname(__file__), "addon")
        self.destinationAddonPath = destinationAddonPath
        self.pendingExecutions: dict[str, executions.BaseExecution] = {}
        self.callbacks: dict[str, Event] = {}
        
        self.playlistEncoded = self._parsePlaylist()
        self.script = self._parseScript()
        self.vehicles: list[str] = []
        
        # check if paths exist
        if not os.path.exists(self.addonPath):
            raise exceptions.InternalError(f"Addon path does not exist: {os.path.abspath(self.addonPath)}")
        
        if not os.path.exists(self.destinationAddonPath):
            raise exceptions.PathNotFound(f"Addon destination path does not exist: {os.path.abspath(self.destinationAddonPath)}. Please install and run Stormworks: Build and Rescue.\nIf you are on a non-Windows OS, please provide the destinationAddonPath argument and set it to the location of Stormworks' Stormworks/data/missions folder.")
        
        # edit playlist
        self.playlistEncoded["playlist"]["@name"] = f"[P2SW] {self.addonName}"
        self.playlistEncoded["playlist"]["@folder_path"] = f"data/missions/{self.addonName}"
        
        # edit script
        self.script = self.script.replace("__PORT__", str(self.port))
        
    def log(self, message: str):
        """
        Sends a message to the terminal. It's just a fancy print()
        
        Args:
            message: (str) The message to send.
        """

        if not self.allowLogging:
            return
        
        print(f"{colorama.Fore.BLUE}{colorama.Style.BRIGHT}[PythonToSW - {datetime.now()}]{colorama.Style.RESET_ALL}{colorama.Fore.RESET} {message}")
        
    def start(self, target: "function"):
        """
        Starts the addon, automatically creating needed files, as well as hosting a HTTP server locally.
        
        >>> import PythonToSW as PTS
        >>> addon = PTS.Addon("MyAddon", port = 3000)
        >>>
        >>> def main():
        >>>     addon.execute(PTS.Announce("Server", "Hello World", -1))
        >>>
        >>> addon.start(target = main) # Start the addon. This automatically creates an addon and places it in your Stormworks' addon directory, so you can easily use the addon in a save.
        
        Args:
            target: (function) The function to start the addon with.
            
        Raises:
            exceptions.FailedStartAttempt: Raised if the addon is already running.
        """

        if self.running:
            raise exceptions.FailedStartAttempt("Addon is already running")
        
        # set running
        self.running = True
        
        # setup addon
        self._setupAddon()
        
        # setup routes
        self._setupRoutes()
        
        # hide flask output
        self._hideFlaskOutput()
        
        # send startup message
        self.log(f"{self.addonName} (addon) has started, listening on port {self.port}. Create a save with your addon enabled in Stormworks and keep this running.")
        
        # start server
        threading.Thread(target = target).start()
        self.app.run(host = "127.0.0.1", port = self.port, threaded = True)
        
    def execute(self, execution: executions.BaseExecution):
        """
        Sends an execution to the in-game addon.
        
        >>> import PythonToSW as PTS
        >>> addon = PTS.Addon("MyAddon", port = 3000)
        >>>
        >>> def main():
        >>>     addon.execute(PTS.Announce("Server", "Hello World", -1)) # Sends a message to everyone
        >>>
        >>> addon.start(target = main)
        
        Args:
            execution: (executions.BaseExecution) The execution to send.
            
        Raises:
            exceptions.FailedExecutionAttempt: Raised if the addon is not running, or if an execution with the same ID already exists.
        """

        # check if addon is running
        if not self.running:
            raise exceptions.FailedExecutionAttempt("Attempted to execute server function when addon is not running")
        
        # check if execution already exists
        if self.getPendingExecution(execution.ID):
            raise exceptions.FailedExecutionAttempt(f"Attempted to execute server function with duplicate ID: {execution.ID}")
        
        # add execution
        self.pendingExecutions[execution.ID] = execution
        self.log(f"{execution} has been queued.")
        
        # wait for execution to complete
        returnValues = execution._wait()
        self.log(f"{execution} has complete. Returned: {returnValues}")
        
        if execution._obsolete():
            return
        
        # remove execution now that its complete
        self.removePendingExecution(execution.ID)
        
        # return
        return returnValues
    
    def getPendingExecution(self, executionID: str) -> executions.BaseExecution|None:
        """
        Returns the pending execution with the given ID.
        
        Args:
            executionID: (str) The ID of the execution to return.
            
        Returns:
            (executions.BaseExecution|None) The pending execution with the given ID, or None if it doesn't exist.
        """

        return self.getPendingExecutions().get(executionID)
        
    def getPendingExecutions(self) -> dict[str, executions.BaseExecution]:
        """
        Returns the pending executions.
        
        Returns:
            (dict[str, executions.BaseExecution]) The pending executions, with the keys being the execution IDs.
        """

        return self.pendingExecutions.copy()
    
    def removePendingExecution(self, executionID: str):
        """
        Removes the pending execution with the given ID.
        
        Args:
            executionID: (str) The ID of the execution to remove.
            
        Raises:
            exceptions.FailedExecutionAttempt: Raised if the execution with the given ID doesn't exist.
            exceptions.ExecutionNotFound: Raised if no execution with the given ID exists.
        """

        # check if addon is running
        if not self.running:
            raise exceptions.FailedExecutionAttempt("Attempted to remove pending execution when addon is not running")
        
        # get the execution
        execution = self.getPendingExecution(executionID)
        
        if not execution:
            raise exceptions.ExecutionNotFound(f"Invalid execution ID: {executionID}")
        
        # halt execution
        execution._halt()
        
        # remove it
        self.pendingExecutions.pop(executionID)
    
    def registerVehicle(self, path: str, vehicleID: int, isStatic: bool = False, isEditable: bool = False, isInvulnerable: bool = False, isShowOnMap: bool = False, isTransponderActive: bool = False):
        """
        Registers a vehicle with the addon.
        
        Args:
            path: (str) The path to the vehicle file.
            vehicleID: (int) The ID of the vehicle.
            isStatic: (bool = False) Whether the vehicle is static.
            isEditable: (bool = False) Whether the vehicle is editable.
            isInvulnerable: (bool = False) Whether the vehicle is invulnerable.
            isShowOnMap: (bool = False) Whether the vehicle is shown on the map.
            isTransponderActive: (bool = False) Whether the vehicle's transponder is active.
            
        Raises:
            exceptions.InvalidVehiclePath: Raised if the path to the vehicle file is invalid (doesn't exist, isn't a file, or isn't an XML file).
        """

        # check if path exists and is valid
        if not os.path.exists(path):
            raise exceptions.InvalidVehiclePath(f"Invalid vehicle path: {path}")
        
        if not os.path.isfile(path):
            raise exceptions.InvalidVehiclePath(f"Invalid vehicle path: {path} is not a file")
        
        if not os.path.splitext(path)[1] == ".xml":
            raise exceptions.InvalidVehiclePath(f"Invalid vehicle path: {path} is not an XML file")
        
        # validate playlist structure (this is awful)
        root = self.playlistEncoded["playlist"]["locations"]["locations"]["l"]
        
        if root["components"].get("components", None) is None and root["components"].get("c", None) is None:
            root["components"] = {"c" : []}
        
        # register vehicle
        self.vehicles.append({"path" : path, "vehicleID" : vehicleID})
        
        # add vehicle to playlist
        vehicle = {
            "@component_type": "3",
            "@id": f"{vehicleID}",
            "@name": "Vehicle",
            "@dynamic_object_type": "2",
            "@vehicle_file_name": f"data/missions_working/vehicle_{vehicleID}.xml",
            "@vehicle_file_store": "4",
            
            "spawn_transform" : {
                "@30" : "0",
                "@31" : "0",
                "@32" : "0"
            },

            "spawn_bounds": {
                "min": {
                    "@x": "0",
                    "@y": "0",
                    "@z": "0"
                },
                "max": {
                    "@x": "0",
                    "@y": "0",
                    "@z": "0"
                }
            },

            "spawn_local_offset": {
                "@y": "0",
            },

            "graph_links": None
        }
        
        if isStatic:
            vehicle["@vehicle_is_static"] = "true"
            
        if isEditable:
            vehicle["@vehicle_is_editable"] = "true"
            
        if isInvulnerable:
            vehicle["@vehicle_is_invulnerable"] = "true"
            
        if isShowOnMap:
            vehicle["@vehicle_is_show_on_map"] = "true"
            
        if isTransponderActive:
            vehicle["@vehicle_is_transponder_active"] = "true"

        root["components"]["c"].append(vehicle)
        
        # send log
        self.log(f"Registered vehicle #{vehicleID}.")
        
    def listen(self, name: str, callback: "function") -> Event:
        """
        Listens for a game callback.
        
        >>> import PythonToSW as PTS
        >>> addon = PTS.Addon("MyAddon", port = 3000)
        >>>
        >>> def main():
        >>>     def onTick(game_ticks):
        >>>         PTS.Announce("Server", "Tick", -1)
        >>>
        >>>     addon.listen("onTick", onTick)
        >>>
        >>> addon.start(target = main)
        
        Args:
            name: (str) The name of the callback.
            callback: (function) The callback to listen for.
            
        Returns:
            (Event) The event that was created.
        """

        # send log
        self.log(f"{callback.__name__} is listening for callback: {name}")
        
        # create if not exists
        self._createCallbackIfNotExists(name)
        event = self.getCallback(name)

        # connect
        event.connect(callback)
        return event
        
    def getCallback(self, name: str) -> Event|None:
        """
        Get a callback by its name.
        
        Args:
            name: (str) The name of the callback.
            
        Returns:
            (Event|None) The event representing the callback, or None if it doesn't exist.
        """

        return self.getCallbacks().get(name)
    
    def getCallbacks(self) -> dict[str, Event]:
        """
        Get all callbacks.
        
        Returns:
            (dict[str, Event]) A dictionary of events representing callbacks.
        """

        return self.callbacks.copy()
    
    def _createCallbackIfNotExists(self, name: str):
        """
        Create a callback if it doesn't exist.
        
        Args:
            name: (str) The name of the callback.
        """

        if not self.getCallback(name):
            self.callbacks[name] = Event()
        
    def _setupRoutes(self):
        """
        Sets up API routes for this addon's HTTP server.
        
        Raises:
            (exceptions.InternalError) Raised if the addon is not running.
        """

        # check if addon is running
        if not self.running:
            raise exceptions.InternalError("Attempted to setup routes when addon is not running")
        
        # route - raise error from addon
        @self.app.get("/error")
        def error():
            @flask.ctx.after_this_request
            def raiseException(_):
                raise exceptions.AddonException(f"[{errorType}]: {errorMessage}")
            
            # get error type and message
            errorType, errorMessage = flask.request.args.get("errorType"), flask.request.args.get("errorMessage")
            
            if errorType is None or errorMessage is None:
                raise exceptions.InternalError("Missing errorType and/or errorMessage for /error endpoint")
            
            errorType, errorMessage = helpers.URLDecode(errorType), helpers.URLDecode(errorMessage)
            
            # return
            return "Ok", 200
        
        # route - return values for an execution
        @self.app.get("/return")
        def returnVal():
            # get id and return values
            executionID = flask.request.args.get("id")
            returnValues = flask.request.args.get("returnValues")
            
            if executionID is None or returnValues is None:
                raise exceptions.InternalError("Missing id and/or returnValues for /return endpoint")
            
            executionID = helpers.URLDecode(executionID)
            returnValues = helpers.URLDecode(returnValues)
            
            # get execution
            execution = self.getPendingExecution(executionID)
            
            if not execution:
                return "Invalid execution ID", 400
            
            # call execution._return() with the decoded return values
            decodedReturnValues: dict = json.loads(returnValues)
            decodedReturnValues = [*decodedReturnValues.values()]

            execution._return(decodedReturnValues)
            
            # return
            return "Ok", 200
        
        # route - fetch pending executions
        @self.app.get("/get-pending-executions")
        def getPendingExecutions():
            encoded = {execution.ID: execution._toDict() for execution in self.getPendingExecutions().values()}
            return json.dumps(encoded, indent = 5), 200
        
        # route - trigger callback
        @self.app.get("/trigger-callback")
        def triggerCallback():
            # get name
            name = flask.request.args.get("name")
            
            if name is None:
                raise exceptions.InternalError("Missing name for /trigger-callback endpoint")
            
            name = helpers.URLDecode(name)
            
            # get callback
            callback = self.getCallback(name)
            
            if not callback:
                return "Invalid callback name", 400 # its ok! addon just isnt listening for this callback
            
            # get arguments
            args = flask.request.args.get("args")
            
            if args is None:
                raise exceptions.InternalError("Missing args for /trigger-callback endpoint")
            
            args = helpers.URLDecode(args)
            args = json.loads(args)
            
            # trigger
            callback.fire(*args)
            
            # return
            return "Ok", 200
        
    def _hideFlaskOutput(self):
        """
        Hides Werkzeug and Flask logging. This is used to hide the Flask server banner and request logs.
        """

        logging.getLogger("werkzeug").disabled = True
        self.app.logger.disabled = True
        flask.cli.show_server_banner = lambda *_, **__: None
        
    def _parsePlaylist(self):
        """
        Parses (XML decodes) the addon's playlist.xml file.
        
        Returns:
            (dict) The XML decoded playlist.
            
        Raises:
            (exceptions.PathNotFound) Raised if the playlist file does not exist.
        """

        playlistFile = os.path.join(self.addonPath, "playlist.xml")
        
        if not os.path.exists(playlistFile):
            raise exceptions.PathNotFound(f"Playlist file does not exist: {playlistFile}")
        
        return helpers.XMLDecode(helpers.quickRead(playlistFile))
    
    def _parseScript(self):
        """
        Parses the addon's script.lua file.
        
        Returns:
            (str) The script contents.
            
        Raises:
            (exceptions.PathNotFound) Raised if the script file does not exist.
        """

        scriptFile = os.path.join(self.addonPath, "script.lua")
        
        if not os.path.exists(scriptFile):
            raise exceptions.PathNotFound(f"Script file does not exist: {scriptFile}")
        
        return helpers.quickRead(scriptFile)
        
    def _setupAddon(self):
        """
        Sets up the addon by writing the playlist and script files to the destination path, as well as setting up vehicles, etc.
        """

        # set destination path
        secureAddonName = werkzeug.utils.secure_filename(self.addonName)
        destinationPath = os.path.join(self.destinationAddonPath, secureAddonName)
        
        # write files to destination
        helpers.quickWrite(os.path.join(destinationPath, "playlist.xml"), helpers.XMLEncode(self.playlistEncoded))
        helpers.quickWrite(os.path.join(destinationPath, "script.lua"), self.script)
        
        # add vehicles to addon directory
        for vehicle in self.vehicles:
            vehicleID = vehicle["vehicleID"]
            content = helpers.quickRead(vehicle["path"])
            
            helpers.quickWrite(os.path.join(destinationPath, f"vehicle_{vehicleID}"), content)