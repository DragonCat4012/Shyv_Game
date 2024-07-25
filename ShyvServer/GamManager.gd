extends Node

var network = ENetMultiplayerPeer.new()
var port = 9999

var lobbies = {} # hostID: [connectedIDS]
var peer_to_game_map = {} # peer_id: lobbyId

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
	if player_id in lobbies.keys():
		lobbies.erase(player_id)

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
	
	peer_to_game_map[peer_id] = peer_id
	rpc_id(peer_id, "lobby_found", peer_id)
	
@rpc("any_peer",  "reliable")
func on_lobby_joined(lobbyID): # TODO:!!!
	var peer_id = multiplayer.get_remote_sender_id()
	print(peer_id," joined lobby ", lobbyID)
	
	var oldPlayers = lobbies[lobbyID]
	oldPlayers.append(peer_id)
	lobbies[lobbyID] = oldPlayers
	
	_update_player_list(lobbyID)
	
	peer_to_game_map[peer_id] = lobbyID
	rpc_id(peer_id, "lobby_found", lobbyID)
	
@rpc("any_peer",  "reliable")
func on_random_lobby_joined():
	var lobbyID = lobbies.keys().pick_random()
	var peer_id = multiplayer.get_remote_sender_id()
	print(peer_id," joined lobby ", lobbyID)
	
	var oldPlayers = lobbies[lobbyID]
	oldPlayers.append(peer_id)
	lobbies[lobbyID] = oldPlayers
	
	_update_player_list(lobbyID)
	
	peer_to_game_map[peer_id] = lobbyID
	rpc_id(peer_id, "lobby_found", lobbyID)
	# TODO: on player disconnet message all peers they left

func _update_player_list(lobbyID):
	print("Resync lobby: ", lobbyID)
	rpc_id(lobbyID, "sync_players_in_lobby", lobbies[lobbyID])
	
	for user in lobbies[lobbyID]:
		rpc_id(user, "sync_players_in_lobby", lobbies[lobbyID])
	
@rpc("authority", "reliable")
func sync_players_in_lobby(players):
	pass # TODO: publsih othger joined players

@rpc("any_peer", "reliable")
func request_lobbys():
	print("e")
	var peer_id = multiplayer.get_remote_sender_id()
	print("requestd lobbys by: ", peer_id)
	rpc_id(peer_id, "open_lobbys", lobbies.keys())
	
# CLient RPCs
@rpc("authority", "reliable")
func lobby_found(_lobbyID):
	pass
@rpc("authority", "reliable")
func open_lobbys(_l):
	pass
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
	
