# ----------------------------------------
# [PythonToSW] Example - Welcome Message
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

# Import PythonToSW
import PythonToSW as PTS

# Create addon
addon = PTS.Addon(addonName = "Welcome Players", port = 12750)

# Main code
def main():
    # Listen for players joining
    def onPlayerJoin(steam_id: int, name: str, peer_id: int, is_admin: bool, is_auth: bool):
        # Send a welcome message only to the player
        addon.execute(
            PTS.Announce("Server", f"Welcome to the server, {name}!\nYou are {"authed" if is_auth else "unauthed"}.", peer_id)
        )
        
        # Send a new player message to everyone
        addon.execute(
            PTS.Announce("Server", f"{name} joined the server!")
        )
        
    addon.listen("onPlayerJoin", onPlayerJoin)

# Start addon
addon.start(main)