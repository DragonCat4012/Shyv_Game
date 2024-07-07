extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
const Port = 9999
const Adress = "127.0.0.1"
var connected_peer_ids = []

func _on_host_pressed():
	multiplayer_peer.create_server(Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("created host id: ", multiplayer.get_unique_id())
	
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_character", connected_peer_ids)
			addPlayer(new_peer_id)
	)
	
func _on_join_pressed():
	multiplayer_peer.create_client(Adress, Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("join with: ", multiplayer.get_unique_id())
	print("remote id: ", multiplayer.get_peers())
	
func _on_message_input_text_submitted(new_text):
	pass

func addPlayer(peer_id):
	connected_peer_ids.append(peer_id)
	
@rpc
func add_newly_connected_player_character(new_per_id):
	print("added newly: ", new_per_id)
	addPlayer(new_per_id)

@rpc 
func add_previously_connected_player_character(peer_ids):
	print("added a few: ", peer_ids)
	for peer_id in peer_ids:
		addPlayer(peer_id)

