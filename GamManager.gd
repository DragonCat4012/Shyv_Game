extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()
const Port = 9999
const Adress = "127.0.0.1"

func _on_host_pressed():
	print("host")
	multiplayer_peer.create_server(Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("a: ", multiplayer.get_unique_id())

func _on_join_pressed():
	print("join")
	multiplayer_peer.create_client(Adress, Port)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("b: ", multiplayer.get_unique_id())
	
func _on_message_input_text_submitted(new_text):
	pass
