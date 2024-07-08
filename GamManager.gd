extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
const Port = 9999
const Adress = "127.0.0.1"

# Lobby managment
var connected_peer_ids: Array[int] = []
var ready_peer_ids: Array[int] = []
var messages = {}

# Map
var seed = 0

func _on_host_pressed():
	multiplayer_peer.create_server(Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print_signed("created host id: ", multiplayer.get_unique_id())
	
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			rpc("_on_player_connected", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_character", connected_peer_ids)
			rpc_id(new_peer_id, "add_previously_send_messages", messages)
			addPlayer(new_peer_id)
	)
	multiplayer_peer.peer_disconnected.connect(
		func(old_peer_id):
			rpc("_on_player_diconnected", old_peer_id)
			removePlayer(old_peer_id)
	)
	
func _on_join_pressed():
	multiplayer_peer.create_client(Adress, Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print_signed("join with: ", multiplayer.get_unique_id())
	print_signed("already joined players: ", multiplayer.get_peers())
	connected_peer_ids.assign(multiplayer.get_peers())

func addPlayer(peer_id):
	connected_peer_ids.append(peer_id)
	messages[peer_id] = ""
	
func removePlayer(peer_id):
	connected_peer_ids.erase(peer_id)
	messages.erase(peer_id)

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
		
# Testing idk
@rpc("any_peer")# Any peer can call it,
func my_func_any_peer():
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == get_multiplayer_authority():
		# The authority is not allowed to call this function.
		return
	print_signed("Fucntion called by a remote peer: ", multiplayer.get_remote_sender_id())
