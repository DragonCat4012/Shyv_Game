extends Node

var network = ENetMultiplayerPeer.new()
var port = 9999

var lobbies = {} # hostID: [connectedIDS]


func _ready():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	start_server()
	
func start_server():
	network.create_server(port, 100)
	multiplayer.multiplayer_peer = network
	get_tree().set_multiplayer(multiplayer)
	print("Server started")
	#print(IP.get_local_addresses())
	print(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1))

func _peer_connected(player_id):
	print("> ", player_id, " Connected")
	# TODO: advertise lobbies
	
func _peer_disconnected(player_id):
	print("> ", player_id, " Disconnected")

'''
Server → Client: @rpc("authority", "call_remote", "reliable")
Server → Every peer: @rpc("authority", "call_local", "reliable")
Client → Server: @rpc("any_peer", "call_remote", "reliable")
Authority Client → Server: @rpc("authority", "call_remote", "reliable")
'''

# Lobbies
@rpc("any_peer", "reliable")
func on_lobby_create():
	var peer_id = multiplayer.get_remote_sender_id()
	print("New lobby created: ", peer_id)
	lobbies[peer_id] = []
	
@rpc("any_peer",  "reliable")
func on_lobby_joined(lobbyID):
	var peer_id = multiplayer.get_remote_sender_id()
	print(peer_id," joined lobby ", lobbyID)
	
	var oldPlayers = lobbies[lobbyID]
	oldPlayers.append(peer_id)
	lobbies[lobbyID] = oldPlayers

func _send_joined_players():
	pass # TODO: publsih othger joined players

# MARK idk

#@rpc
func _on_peer_disconnect(peerID):
	pass

#@rpc
func _on_player_connected(new_per_id):
	pass
	
#@rpc
func _on_player_diconnected(new_per_id):
	pass

#@rpc # only server can call it
func add_previously_connected_player_character(peer_ids):
	pass
	
#@rpc
func add_previously_send_messages(msgs):
	pass
	
