extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
const Port = 9999
const Adress = '192.168.1.144'

# Lobby managment
var connected_peer_ids: Array[int] = []
var ready_peer_ids: Array[int] = []
var messages = {} # Lobby messages

# Map
var seed = 0
var land_tiles: Array[Vector2] = [] # tiles where player can start
var building_tiles: Array[BuildingTiles] = []

# Peer managment
var connected = false
var ownID: int = -1
var isHost = false

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
	
func _on_host_pressed():
	isHost = true
	
	multiplayer_peer.create_client(Adress, Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	print_signed("created host id: ", multiplayer.get_unique_id())
	
	return # TODO: let server ahndle that? not sure
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			rpc("_on_player_connected", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_character", connected_peer_ids)
			rpc_id(new_peer_id, "add_previously_send_messages", messages)
			addPlayer(new_peer_id)
			connected = true
	)
	multiplayer_peer.peer_disconnected.connect(
		func(old_peer_id):
			rpc("_on_player_diconnected", old_peer_id)
			removePlayer(old_peer_id)
	)
	
	
func _on_join_pressed():
	multiplayer_peer.create_client(Adress, Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	
func _on_join_succeed():
	multiplayer.multiplayer_peer = multiplayer_peer
	get_tree().set_multiplayer(multiplayer)
	ownID = multiplayer.get_unique_id()

	print_signed("joined with: ", multiplayer.get_unique_id())
	print_signed("already joined players: ", multiplayer.get_peers())
	connected_peer_ids.assign(multiplayer.get_peers()) # TODO: filter out 1
	connected = true
	EventSystem.CONNECTED_SUCCESSFULL.emit()
	
	if isHost:
		rpc_id(1,"on_lobby_create")

func _on_join_failure():
	print("Failed to connect to Server")
	
	
@rpc("any_peer", "reliable")
func on_lobby_create():
	pass
@rpc("any_peer", "reliable")
func on_lobby_joined(lobby):
	pass	


# MARK: RPc
#@rpc
func _on_peer_disconnect(peerID):
	print_signed("peer disconnected: ", peerID)
	if peerID == multiplayer.get_unique_id(): # when disconnected from host
		print("Server closed connection")
		connected = false
		multiplayer_peer.close()
	removePlayer(peerID)

func _diconnect():
	connected = false
	var id = multiplayer.get_unique_id()
	multiplayer_peer.close()
	reset_after_disconnect()
	rpc("_on_peer_disconnect", id)

func _diconnect_all_peers_from_host():
	for peer in connected_peer_ids:
		rpc("_on_peer_disconnect", peer)
		#OS.delay_msec(1000)
		#multiplayer_peer.disconnect_peer(peer, false)
		
	connected = false
	multiplayer_peer.close()
	reset_after_disconnect()

func addPlayer(peer_id):
	connected_peer_ids.append(peer_id)
	messages[peer_id] = ""
	
func removePlayer(peer_id):
	connected_peer_ids.erase(peer_id)
	messages.erase(peer_id)
	ready_peer_ids.erase(peer_id)

#@rpc
func _on_player_connected(new_per_id):
	'''Called on every peer'''
	print_signed("Added player: ", new_per_id)
	addPlayer(new_per_id)
	
#@rpc
func _on_player_diconnected(new_per_id):
	'''Called on every peer'''
	print_signed("remove player: ", new_per_id)
	removePlayer(new_per_id)

#@rpc # only server can call it
func add_previously_connected_player_character(peer_ids):
	print_signed("added a few: ", peer_ids)
	for peer_id in peer_ids:
		addPlayer(peer_id)
#@rpc
func add_previously_send_messages(msgs):
	messages = msgs
	
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
	print("[",multiplayer.get_unique_id(), "]: ", arg, arg2, arg3, arg4)

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
