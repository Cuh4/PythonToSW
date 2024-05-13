# // imports
import PythonToSW as PTS

# // setup
# create addon
addon = PTS.Addon(addonName = "Testing", port = 12705)
addon.start()

# // main
# create player class
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

# create players
players: dict[str, Player] = {}

# listen for players joining
def onPlayerJoin(steam_id, name, peer_id):
    players[peer_id] = Player(name, peer_id, steam_id)
    
    # say hi!
    players[peer_id].whisper("Hello!")
    
addon.listen("onPlayerJoin", onPlayerJoin)
    
# listen for players leaving
def onPlayerLeave(_, __, peer_id):
    players.pop(peer_id)
    
addon.listen("onPlayerLeave", onPlayerLeave)