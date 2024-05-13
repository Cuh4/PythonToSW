# ----------------------------------------
# [PythonToSW] Addon
# ----------------------------------------

# A Python package that allows you to execute server functions in a Stormworks: Build and Rescue addon.
# Repo: https://github.com/Cuh4/PythonToSW • Creator: Cuh4 • License: Apache 2.0

# ---- // Imports
import os
import flask
import flask.cli
import json
import threading
import logging
import werkzeug
import werkzeug.utils

from . import helpers
from . import exceptions
from . import executions
from . import Event

# ---- // Main
class Addon():
    def __init__(self, addonName: str, port: int, code: "function"):
        self.addonName = addonName
        self.port = port
        self.app = flask.Flask(__name__)
        self.codeFunc = code
        self.running = False
        self.addonPath = os.path.join(os.path.dirname(__file__), "addon")
        self.destinationAddonPath = os.path.join(os.getenv("APPDATA"), "Stormworks", "data", "missions")
        
        if not os.path.exists(self.addonPath):
            raise exceptions.InternalError(f"Addon path does not exist: {os.path.abspath(self.addonPath)}")
        
        if not os.path.exists(self.destinationAddonPath):
            raise exceptions.InternalError(f"Addon destination path does not exist: {os.path.abspath(self.destinationAddonPath)}. Please install and run Stormworks: Build and Rescue.")
        
        self.pendingExecutions: dict[str, executions.BaseExecution] = {}
        self.callbacks: dict[str, Event] = {}
        
    # Start the addon
    def start(self):
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
        
        # start server
        threading.Thread(target = self.codeFunc).start()
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
        
        # wait for execution to complete
        returnValues = execution._wait()
        
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
        
    # Listen for a game callback
    def listen(self, name: str, callback: callable):
        self.__createCallbackIfNotExists(name)
        return self.getCallback(name).connect(callback)
        
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
        
    # Setup addon
    def __setupAddon(self):
        # set destination path
        secureAddonName = werkzeug.utils.secure_filename(self.addonName)
        destinationPath = os.path.join(self.destinationAddonPath, secureAddonName)
        
        # parse playlist.xml
        playlistFile = os.path.join(self.addonPath, "playlist.xml")
        
        if not os.path.exists(playlistFile):
            raise exceptions.InternalError(f"Playlist file does not exist: {playlistFile}")
        
        rawPlaylist: str = helpers.quickRead(playlistFile)
        decodedPlaylist = helpers.XMLDecode(rawPlaylist)
        
        # set addon name and path
        decodedPlaylist["playlist"]["@name"] = f"[P2SW] {self.addonName}"
        decodedPlaylist["playlist"]["@folder_path"] = f"data/missions/{secureAddonName}"
        
        # parse script.lua
        scriptFile = os.path.join(self.addonPath, "script.lua")
        
        if not os.path.exists(scriptFile):
            raise exceptions.InternalError(f"Script file does not exist: {scriptFile}")
        
        rawScript: str = helpers.quickRead(scriptFile)
        rawScript = rawScript.replace("__PORT__", str(self.port))
        
        # write files to destination
        helpers.quickWrite(os.path.join(destinationPath, "playlist.xml"), helpers.XMLEncode(decodedPlaylist))
        helpers.quickWrite(os.path.join(destinationPath, "script.lua"), rawScript)