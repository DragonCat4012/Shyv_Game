extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
const Port = 9999
var Adress = ""

# Lobby managment
var connected_peer_ids: Array[int] = []
var ready_peer_ids: Array[int] = []
var messages = {} # Lobby messages

# Map
var mapSeed = 0
var land_tiles: Array[Vector2] = [] # tiles where player can start
var building_tiles: Array[BuildingTiles] = []

# Peer managment
var connected = false # Lobby/Game
var connectedToServer = false # Server
var ownID: int = -1
var isHost = false
var lobbyCode: int = -1

# Game Maagment:
var nationMapping = {} # string_peerId: NationModel # TODO: implement
var allNations: Array[NationModel] = []
var currentNationIDCount = 1 # only changed by server/host!

var ownNation = null

# Game Phases
var currentPhase: int = 0
var phaseCount: int = 0
const phaseNames = { # NOTE: change tooltip text in GamePhaseScene if scenes change
	0: "Nothingness :0",
	1: "Event",
	2: "Building",
	3: "Movement",
	4: "Endphase"
}
var endedTurnNations: Array[String] = [] # host only, nationIDs which have finished their turn in the current game phase
var hasEndedTurn = false # Client only to hide ent turn option and disable actions

func _ready():
	multiplayer.connected_to_server.connect(self._on_join_succeed)
	multiplayer.connection_failed.connect(self._on_join_failure)
	
func _connect_to_server():
	if connectedToServer:
		return
	connected = false
	connectedToServer = false # disable menu buttons if false
	multiplayer_peer.create_client(Adress, Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
func _on_host_pressed():
	if not connectedToServer:
		print("Not connected to Server")
		return
	isHost = true
	print_signed("created host id: ", multiplayer.get_unique_id())
	rpc_id(1, "on_lobby_create")
	EventSystem.START_CONNECTING.emit()

func _on_join_lobby_pressed(newLobbyCode):
	rpc_id(1, "on_lobby_joined", newLobbyCode)
	print("Trying to join selected lobby")
	EventSystem.START_CONNECTING.emit()
	
func _on_join_pressed():
	rpc_id(1, "on_random_lobby_joined")
	EventSystem.START_CONNECTING.emit()
	#print("Trying to join random lobby")
	
func _on_join_succeed():
	multiplayer.multiplayer_peer = multiplayer_peer
	get_tree().set_multiplayer(multiplayer)

	ownID = multiplayer.get_unique_id()
	print_signed("connected to server as: ", multiplayer.get_unique_id())
	
	connectedToServer = true

func _on_join_failure():
	connectedToServer = false
	connected = false
	print("Failed to connect to Server")
	
func close_lobby():
	rpc_id(1, "on_lobby_close")
	
func _request_lobbies():
	rpc_id(1, "request_lobbys")
	
func _leave_lobby():
	rpc_id(1, "leave_lobby", lobbyCode)
	lobbyCode = -1
	
func _leave_watchlist():
	rpc_id(1, "leave_watchlist")
# Server RPCS
@rpc("any_peer", "reliable")
func leave_watchlist():
	pass
@rpc("any_peer", "reliable")
func leave_lobby(_lobby):
	pass
@rpc("any_peer", "reliable")
func on_lobby_close():
	pass
@rpc("any_peer", "reliable")
func on_lobby_create():
	pass
@rpc("any_peer", "reliable")
func on_lobby_joined(_lobby):
	pass
@rpc("any_peer", "reliable")
func on_random_lobby_joined(_lobby):
	pass
@rpc("any_peer", "reliable")
func request_lobbys():
	pass
	
# From Server	
@rpc("authority", "reliable")
func lobby_found(lobbyID):
	if lobbyID == null:
		EventSystem.STOP_CONNECTING.emit()
		return

	GamManager.connected = true
	lobbyCode = lobbyID
	EventSystem.LOBBY_JOINED.emit()
	EventSystem.STOP_CONNECTING.emit()
	
@rpc("authority", "reliable")
func lobby_closed_by_host():
	GamManager.connected = false
	lobbyCode = -1
	print("lobby closed :c")
	EventSystem.LOBBY_CLOSED.emit()
	
# Sync RPCs
@rpc("authority", "reliable")
func sync_players_in_lobby(players):
	print("Synced Players: ", players)
	for beforePlayer in ready_peer_ids:
		if not beforePlayer in players:
			ready_peer_ids.erase(beforePlayer)
	connected_peer_ids.assign(players)

@rpc("authority", "reliable")
func open_lobbys(lobbys):
	EventSystem.FOUND_OPEN_LOBBYS.emit(lobbys)
	print("found lobbys: ", lobbys)


# Manga Lobby Nations 
func _remove_player_nation_in_lobby(peerID):
	allNations.erase(nationMapping[str(peerID)])
	nationMapping.erase(str(peerID))

func _add_player_nation_in_lobby(peerID, nation: NationModel):
	nation.assignedID = currentNationIDCount
	nationMapping[str(peerID)] = nation
	allNations.append(nation)
	
	currentNationIDCount += 1
	
# Util
func print_signed(arg, arg2 = "", arg3 = "", arg4 = ""):
	print("[", multiplayer.get_unique_id(), "]: ", arg, arg2, arg3, arg4)

func reset_after_disconnect():
	multiplayer.multiplayer_peer = null
	connected_peer_ids = []
	messages = {}
	ready_peer_ids = []

func get_nation_id_to_tile(tilePosition: Vector2) -> int:
	var nationID = -1
	for tile in building_tiles:
		if tile.coords == tilePosition:
			nationID = tile.ownedByNationID
	return nationID

func get_nation_to_tile(tilePosition: Vector2) -> NationModel:
	var id = get_nation_id_to_tile(tilePosition)
	if id < 0:
		return null
		
	for nat in allNations:
		if nat.assignedID == id:
			return nat
	return null

func get_buildTile_from_pos(tilePosition: Vector2) -> BuildingTiles:
	for tile in building_tiles:
		if tile.coords == tilePosition:
			return tile
	return null
