# // imports
import PythonToSW as PTS

# // variables
players: dict[str, "Player"] = {}

# // classes
class Player():
    def __init__(self, name: str, peer_id: int, steam_id: int):
        self.name = name
        self.peer_id = peer_id
        self.steam_id = steam_id
        
    def getPosition(self):
        data = addon.execute(
            PTS.GetPlayerPos(self.peer_id)
        )
        
        return data[0]
    
    def setPosition(self, x: float|int, y: float|int, z: float|int):
        addon.execute(
            PTS.SetPlayerPos(self.peer_id, PTS.matrix.new(x, y, z))
        )
        
    def whisper(self, message: str):
        addon.execute(
            PTS.Announce("Server", message, self.peer_id)
        )
        
    def getCharacter(self):
        data = addon.execute(
            PTS.GetPlayerCharacter(self.peer_id)
        )
        
        return data[0]
    
    def setupNametag(self):
        # get object id
        characterID = self.getCharacter()
        
        # create custom nametag
        addon.execute(
            PTS.SetPopup(-1, self.peer_id, True, self.name, PTS.matrix.new(0, 2, 0), 10, 0, characterID)
        )
        
    def removeNametag(self):
        addon.execute(
            PTS.RemovePopup(-1, self.peer_id)
        )

# // functions
def getPlayers():
    data = addon.execute(
        PTS.GetPlayers()
    )
    
    return data[0]

def setupPlayer(name: str, peer_id: int, steam_id: int):
    players[peer_id] = Player(name, peer_id, steam_id)
    
def getPlayer(peer_id: int):
    return players[peer_id]

# // main
# called when the addon is started
def main():
    # print start message
    print("Addon has started!")

    # create player object for current players
    for player in getPlayers():
        setupPlayer(player["name"], player["id"], player["steam_id"])

    # listen for players joining
    def onPlayerJoin(steam_id: int, name: str, peer_id: int, *_):
        # print message
        print(f"{name} has joined.")
        
        # setup player
        setupPlayer(name, peer_id, steam_id)
        
    addon.listen("onPlayerJoin", onPlayerJoin)
        
    # listen for players leaving
    def onPlayerLeave(_, __, peer_id: int, *___):
        # print message
        print(f"{getPlayer(peer_id).name} has left.")
        
        # remove player
        players.pop(peer_id)
        
    addon.listen("onPlayerLeave", onPlayerLeave)
    
    # listen for messages
    def onChatMessage(peer_id, name, message):
        # print message
        print(f"{name}: {message}")
        
    addon.listen("onChatMessage", onChatMessage)

# create addon
addon = PTS.Addon(addonName = "Testing", port = 12705, code = main)

# start it
addon.start()