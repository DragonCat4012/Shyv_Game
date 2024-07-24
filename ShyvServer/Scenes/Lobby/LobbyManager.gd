extends Node


@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_ready(nationSTR):
	var peer_id = multiplayer.get_remote_sender_id()
	var lobby = GamManager.peer_to_game_map[peer_id]
	for peer in GamManager.lobbies[lobby]:
		rpc(peer, "update_to_ready", peer_id)
	# TODO: send ready to lobby
	
@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_un_ready():
	var peer_id = multiplayer.get_remote_sender_id()
	# TODO: send unready to lobby
	
@rpc("authority", "reliable")
func update_to_ready(peer):
	pass
		
@rpc("any_peer", "call_local") 
func _on_start_game(seed):
	pass
	# send start game to lobby
	
# Sync Nations with Peers
@rpc("any_peer", "call_local") 
func _on_sync_nations_with_peers(nationsJSON, nationsMappingJSON):
	# send nations game to lobby
	
