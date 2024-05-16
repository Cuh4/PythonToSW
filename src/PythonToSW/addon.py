# ----------------------------------------
# [PythonToSW] Addon
# ----------------------------------------

# A Python package that allows you to make Stormworks addons with Python.
# Repo: https://github.com/Cuh4/PythonToSW

"""
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
    def __init__(self, addonName: str, port: int, *, allowLogging: bool = True, destinationAddonPath: str = None):
        # main attributes
        self.addonName = addonName
        self.port = port
        self.app = flask.Flask(__name__)
        self.running = False
        self.allowLogging = allowLogging
        self.addonPath = os.path.join(os.path.dirname(__file__), "addon")
        self.destinationAddonPath = destinationAddonPath or os.path.join(os.getenv("APPDATA"), "Stormworks", "data", "missions")
        self.pendingExecutions: dict[str, executions.BaseExecution] = {}
        self.callbacks: dict[str, Event] = {}
        
        self.playlistEncoded = self.__parsePlaylist()
        self.script = self.__parseScript()
        self.vehicles: list[str] = []
        
        # check if paths exist
        if not os.path.exists(self.addonPath):
            raise exceptions.InternalError(f"Addon path does not exist: {os.path.abspath(self.addonPath)}")
        
        if not os.path.exists(self.destinationAddonPath):
            raise exceptions.InternalError(f"Addon destination path does not exist: {os.path.abspath(self.destinationAddonPath)}. Please install and run Stormworks: Build and Rescue.\nIf you are on a non-Windows OS, please provide the destinationAddonPath argument and set it to the location of Stormworks' Stormworks/data/missions folder.")
        
        # edit playlist
        self.playlistEncoded["playlist"]["@name"] = f"[P2SW] {self.addonName}"
        self.playlistEncoded["playlist"]["@folder_path"] = f"data/missions/{self.addonName}"
        
        # edit script
        self.script = self.script.replace("__PORT__", str(self.port))
        
    # Send a log (print message)
    def log(self, message: str):
        if not self.allowLogging:
            return
        
        print(f"{colorama.Fore.BLUE}{colorama.Style.BRIGHT}[PythonToSW - {datetime.now()}]{colorama.Style.RESET_ALL}{colorama.Fore.RESET} {message}")
        
    # Start the addon
    def start(self, target: "function"):
        if self.running:
            raise exceptions.FailedStartAttempt("Addon is already running")
        
        # set running
        self.running = True
        
        # setup addon
        self.__setupAddon()
        
        # setup routes
        self.__setupRoutes()
        
        # hide flask output
        self.__hideFlaskOutput()
        
        # send startup message
        self.log(f"{self.addonName} (addon) has started, listening on port {self.port}. Create a save with your addon enabled in Stormworks and keep this running.")
        
        # start server
        threading.Thread(target = target).start()
        self.app.run(host = "127.0.0.1", port = self.port, threaded = True)
        
    # Execute a server function in the addon
    def execute(self, execution: executions.BaseExecution):
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
    
    # Get a pending execution by its ID
    def getPendingExecution(self, executionID: str) -> executions.BaseExecution|None:
        return self.getPendingExecutions().get(executionID)
        
    # Get all pending executions
    def getPendingExecutions(self) -> dict[str, executions.BaseExecution]:
        return self.pendingExecutions.copy()
    
    # Remove a pending execution
    def removePendingExecution(self, executionID: str):
        # check if addon is running
        if not self.running:
            raise exceptions.FailedExecutionAttempt("Attempted to remove pending execution when addon is not running")
        
        # get the execution
        execution = self.getPendingExecution(executionID)
        
        if not execution:
            raise exceptions.InvalidExecutionID(f"Invalid execution ID: {executionID}")
        
        # halt execution
        execution._halt()
        
        # remove it
        self.pendingExecutions.pop(executionID)
    
    # Register a vehicle. The path must be the path to the vehicle .xml file
    def registerVehicle(self, path: str, vehicleID: int, isStatic: bool = False, isEditable: bool = False, isInvulnerable: bool = False, isShowOnMap: bool = False, isTransponderActive: bool = False):
        # check if path exists
        if not os.path.exists(path):
            raise exceptions.InvalidVehiclePath(f"Invalid vehicle path: {path}")
        
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
        
    # Listen for a game callback
    def listen(self, name: str, callback: "function") -> Event:
        # send log
        self.log(f"{callback.__name__} is listening for callback: {name}")
        
        # create if not exists
        self.__createCallbackIfNotExists(name)
        event = self.getCallback(name)

        # connect
        event.connect(callback)
        return event
        
    # Get a callback by its name
    def getCallback(self, name: str) -> Event|None:
        return self.getCallbacks().get(name)
    
    # Get all callbacks
    def getCallbacks(self) -> dict[str, Event]:
        return self.callbacks.copy()
    
    # Create an event for a game callback if it doesn't exist
    def __createCallbackIfNotExists(self, name: str):
        if not self.getCallback(name):
            self.callbacks[name] = Event()
        
    # Setup API routes
    def __setupRoutes(self):
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
        
    # Hide flask output
    def __hideFlaskOutput(self):
        logging.getLogger("werkzeug").disabled = True
        self.app.logger.disabled = True
        flask.cli.show_server_banner = lambda *_, **__: None
        
    # Return parsed playlist.xml
    def __parsePlaylist(self):
        playlistFile = os.path.join(self.addonPath, "playlist.xml")
        
        if not os.path.exists(playlistFile):
            raise exceptions.InternalError(f"Playlist file does not exist: {playlistFile}")
        
        return helpers.XMLDecode(helpers.quickRead(playlistFile))
    
    # Return script.lua
    def __parseScript(self):
        scriptFile = os.path.join(self.addonPath, "script.lua")
        
        if not os.path.exists(scriptFile):
            raise exceptions.InternalError(f"Script file does not exist: {scriptFile}")
        
        return helpers.quickRead(scriptFile)
        
    # Setup addon
    def __setupAddon(self):
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