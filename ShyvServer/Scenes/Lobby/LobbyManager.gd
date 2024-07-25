extends Node


@rpc("any_peer", "reliable") 
func publish_ready(nationSTR): # Client says its ready
  # send nation to host
	var peer_id = multiplayer.get_remote_sender_id()
	var lobbyID = GamManager.peer_to_game_map[peer_id]
	print(peer_id, " ready in lobby with ", nationSTR)
	rpc_id(lobbyID, "on_client_ready", nationSTR, peer_id)
  
@rpc("any_peer", "reliable") 
func publish_unready(): # Client says its not ready
	var peer_id = multiplayer.get_remote_sender_id()
	var lobbyID = GamManager.peer_to_game_map[peer_id]
	print(peer_id, " unready in lobby")
	rpc_id(lobbyID, "on_client_unready", peer_id)

# Client RPC
@rpc("authority", "reliable") 
func on_client_ready(_nationSTR, _peerId): # host updates his nations
	pass
@rpc("authority", "reliable") 
func on_client_unready(_peerId): # host updates his nations
	pass


# Start game rpcs
@rpc("any_peer", "reliable") 
func start_game(seed, nations, mapping): # host started game, send event to all players
	var lobby = multiplayer.get_remote_sender_id()
	print("send start for lobby: ", lobby)
	for player in GamManager.lobbies[lobby]:
		rpc_id(player, "_on_start_game", seed, nations, mapping)
	
@rpc("authority", "reliable") 
func _on_start_game(seed, nations, mapping):
	pass# send start game to lobby
