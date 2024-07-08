extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
const Port = 9999
const Adress = "127.0.0.1"

# Lobby managment
var connected_peer_ids: Array[int] = []
var ready_peer_ids: Array[int] = []
var messages = {}

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
	
# Lobby Stuff
@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_lobby_message(msg):
	var peer_id = multiplayer.get_remote_sender_id()
	print_signed("Fucntion called by peer: ", peer_id," msg: ", msg)
	messages[peer_id] = msg

func send_lobby_message(newMessage):
	rpc("_on_lobby_message", newMessage)
	#messages[multiplayer.get_unique_id()] = newMessage
	
@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_ready():
	var peer_id = multiplayer.get_remote_sender_id()
	print_signed("Ready peer: ", peer_id)
	ready_peer_ids.append(peer_id)
	
func send_ready():
	rpc("_on_ready")
	ready_peer_ids.append(multiplayer.get_unique_id())

@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_un_ready():
	var peer_id = multiplayer.get_remote_sender_id()
	print_signed("UN-Ready peer: ", peer_id)
	ready_peer_ids.erase(peer_id)
	
func send_un_ready():
	rpc("_on_un_ready")
	ready_peer_ids.erase(multiplayer.get_unique_id())
	
@rpc("any_peer", "call_local") 
func _on_start_game():
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
func start_game():
	rpc("_on_start_game")
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
		
# Testing idk
@rpc("any_peer")# Any peer can call it,
func my_func_any_peer():
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == get_multiplayer_authority():
		# The authority is not allowed to call this function.
		return
	print_signed("Fucntion called by a remote peer: ", multiplayer.get_remote_sender_id())
