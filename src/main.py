# // imports
import PythonToSW as PTS

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

# // variables
players: dict[str, Player] = {}
ticks: int = 0

# // main
# function that is called when the addon is started
def main():
    # create players
    players: dict[str, Player] = {}

    # listen for players joining
    def onPlayerJoin(steam_id: int, name: str, peer_id: int, *_):
        # create player
        players[peer_id] = Player(name, peer_id, steam_id)
        
        # get object id
        characterID = players[peer_id].getCharacter()
        
        # create custom nametag
        addon.execute(
            PTS.SetPopup(-1, characterID, True, name, PTS.matrix.new(0, 2, 0), 10, None, characterID)
        )
        
        # say hi
        players[peer_id].whisper("Welcome!")
        
    addon.listen("onPlayerJoin", onPlayerJoin)
        
    # listen for players leaving
    def onPlayerLeave(_, __, peer_id: int, *___):
        # remove player
        players.pop(peer_id)
        
    addon.listen("onPlayerLeave", onPlayerLeave)
    
    # listen for messages
    def onChatMessage(peer_id, name, message):
        # get player
        player = players[peer_id]
        
        # show ticks
        player.whisper(f"Ticks: {ticks}")
        
    addon.listen("onChatMessage", onChatMessage)

# create addon
addon = PTS.Addon(addonName = "Testing", port = 12705, code = main)

# start it
addon.start()