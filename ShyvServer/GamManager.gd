extends Node

var network = ENetMultiplayerPeer.new()
var port = 9999

var lobbies = {} # hostID: [connectedIDS]
var peer_to_game_map = {} # peer_id: lobbyId
var waiting_Peers = [] # peers who watch open loobies

func _ready():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	start_server()
	
func start_server():
	network.create_server(port, 100)
	multiplayer.multiplayer_peer = network
	get_tree().set_multiplayer(multiplayer)
	print("Server started at ", IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1))

func _peer_connected(player_id):
	print("> ", player_id, " Connected")
	
func _peer_disconnected(player_id):
	print("> ", player_id, " Disconnected")
	
	if player_id in lobbies.keys():
		print("Host disconnected")
		_close_lobby(player_id)
		
	if player_id in peer_to_game_map.keys(): # TODO: whyyy
		print("Client disconnected")
		_leave_lobby(peer_to_game_map[player_id], player_id)

'''
Server → Client: @rpc("authority", "call_remote", "reliable")
Server → Every peer: @rpc("authority", "call_local", "reliable")
Client → Server: @rpc("any_peer", "call_remote", "reliable")
Authority Client → Server: @rpc("authority", "call_remote", "reliable")
'''

# Lobbies
@rpc("any_peer", "reliable")
func leave_lobby(lobby):
	var peer_id = multiplayer.get_remote_sender_id()
	print(lobby, " lobby leaved by: ", peer_id)
	_leave_lobby(lobby, peer_id)
	
@rpc("any_peer", "reliable")
func on_lobby_close():
	var peer_id = multiplayer.get_remote_sender_id()
	print("lobby closed: ", peer_id)
	_close_lobby(peer_id)

func _leave_lobby(lobbyID, peerID):
	if not lobbyID in lobbies.keys():
		return
	var withOutArr = lobbies[lobbyID]
	withOutArr.erase(peerID)
	lobbies[lobbyID] = withOutArr
	peer_to_game_map.erase(peerID)
	_update_player_list(lobbyID)
	
func _close_lobby(lobbyID):
	print("closed lobby: ", lobbyID)
	# remove host TODO: notify clients
	for peer in lobbies[lobbyID]:
		rpc_id(peer, "lobby_closed_by_host")
	
	lobbies.erase(lobbyID) 
	
	for waitingPeer in waiting_Peers:
		rpc_id(waitingPeer, "open_lobbys", lobbies.keys())
	
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
	if peer_id in waiting_Peers:
		waiting_Peers.erase(peer_id) # remove if joined per code
	
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
		peer_to_game_map[user] = lobbyID
	
@rpc("any_peer", "reliable")
func request_lobbys():
	var peer_id = multiplayer.get_remote_sender_id()
	print("requestd lobbys by: ", peer_id)
	rpc_id(peer_id, "open_lobbys", lobbies.keys())
	waiting_Peers.append(peer_id)
	
@rpc("any_peer", "reliable")
func leave_watchlist():
	var peer_id = multiplayer.get_remote_sender_id()
	waiting_Peers.erase(peer_id)
	
# CLient RPCs
@rpc("authority", "reliable")
func lobby_found(_lobbyID):
	pass
@rpc("authority", "reliable")
func open_lobbys(_l):
	pass
@rpc("authority", "reliable")
func sync_players_in_lobby(_players):
	pass
@rpc("authority", "reliable")
func lobby_closed_by_host():
	pass
	
