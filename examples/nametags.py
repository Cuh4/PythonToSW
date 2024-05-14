# ----------------------------------------
# [PythonToSW] Example - Nametags
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
addon = PTS.Addon(addonName = "Nametags", port = 12751)

# Create a nametag class that renders a nametag for a player
class Nametag():
    def __init__(self, playerName: str, peer_id: int):
        self.playerName = playerName
        self.peer_id = peer_id
        self.UI_ID = self.peer_id
        
    def getCharacterID(self) -> int:
        return addon.execute(
            PTS.GetPlayerCharacter(self.peer_id)
        )[0]
        
    def generate(self):
        # Remove existing nametag if any
        self.remove()
        
        # Create new nametag
        addon.execute(
            PTS.SetPopup(
                peer_id = -1, 
                ui_id = self.UI_ID,
                visible = True,
                text = self.playerName,
                pos = PTS.matrix.new(0, 2, 0),
                renderDistance = 10,
                vehicleParentID = 0,
                objectParentID = self.getCharacterID()
            )
        )
        
    def remove(self):
        addon.execute(
            PTS.RemovePopup(-1, self.UI_ID)
        )

# Store nametags
nametags: dict[int, Nametag] = {}

# Main code
def main():
    # Listen for players joining
    def onPlayerJoin(steam_id: int, name: str, peer_id: int, is_admin: bool, is_auth: bool):
        # Create nametag
        nametag = Nametag(
            playerName = name,
            peer_id = peer_id
        )
        
        # Generate it
        nametag.generate()
        
        # Store it
        nametags[peer_id] = nametag
        
    addon.listen("onPlayerJoin", onPlayerJoin)
    
    # Listen for players leaving
    def onPlayerLeave(_, __, peer_id: int):
        # Get nametag
        nametag = nametags.get(peer_id)
        
        if nametag is None:
            return
        
        # Remove it
        nametag.remove()
        nametags.pop(peer_id)
        
    addon.listen("onPlayerLeave", onPlayerLeave)
    
    # Listen for players respawning
    def onPlayerRespawn(peer_id):
        # Get nametag
        nametag = nametags.get(peer_id)
        
        if nametag is None:
            return
        
        # Re-generate it since the player has a new character now
        nametag.generate()
        
    addon.listen("onPlayerRespawn", onPlayerRespawn)

# Start addon
addon.start(main)