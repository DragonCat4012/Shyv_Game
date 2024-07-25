extends Node

@rpc("any_peer", "reliable")
func send_tile_update(tileJSON):
	var peer_id = multiplayer.get_remote_sender_id()
	var lobby = peer_id # sent by host
	if not peer_id in GamManager.lobbies.keys(): # sent by client
		lobby = GamManager.peer_to_game_map[peer_id]
		
	print("send tileupdate for lobby: ", lobby)
	for player in GamManager.lobbies[lobby]:
		rpc_id(player, "tile_updated", tileJSON)

@rpc("authority", "reliable")
func tile_updated(tileJSON): # gets called by server
	pass
