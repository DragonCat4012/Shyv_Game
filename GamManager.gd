extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
const Port = 9999
const Adress = "127.0.0.1"

# Lobby managment
var connected_peer_ids: Array[int] = []
var ready_peer_ids: Array[int] = []
var messages = {} # Lobby messages
var nationMappping = {} # created by hot, then published on game start

# Map
var seed = 0
var land_tiles: Array[Vector2] = [] # tiles where player can start
var building_tiles: Array[BuildingTiles] = []

# Peer managment
var connected = false
var ownID: int = -1

# Game Maagment:
var nationMapping = {} # nationId: peerId # TODO: implement


func _on_host_pressed():
	multiplayer_peer.create_server(Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print_signed("created host id: ", multiplayer.get_unique_id())
	ownID = multiplayer.get_unique_id()
	
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
	ownID = multiplayer.get_unique_id()
	
	print_signed("join with: ", multiplayer.get_unique_id())
	print_signed("already joined players: ", multiplayer.get_peers())
	connected_peer_ids.assign(multiplayer.get_peers())
	connected = true # TODO move into connect callback
	multiplayer_peer.peer_disconnected.connect (
		func():
			ownID = -1
			connected = false
			print("welp disconnect")
	)

@rpc
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

@rpc
func _on_player_connected(new_per_id):
	'''Called on every peer'''
	print_signed("Added player: ", new_per_id)
	addPlayer(new_per_id)
	
@rpc
func _on_player_diconnected(new_per_id):
	'''Called on every peer'''
	print_signed("remove player: ", new_per_id)
	removePlayer(new_per_id)

@rpc # only server can call it
func add_previously_connected_player_character(peer_ids):
	print_signed("added a few: ", peer_ids)
	for peer_id in peer_ids:
		addPlayer(peer_id)
@rpc
func add_previously_send_messages(msgs):
	messages = msgs
	
# Util
func print_signed(arg, arg2 = "", arg3 = "", arg4 = ""):
	print("[",multiplayer.get_unique_id(), "]: ", arg, arg2, arg3, arg4)

func reset_after_disconnect():
	connected_peer_ids = []
	messages = {}
	ready_peer_ids = []
