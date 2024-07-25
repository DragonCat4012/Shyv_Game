extends Node

# Manage Turns
@rpc("any_peer", "reliable") 
func send_end_turn(nationID):
	var peer_id = multiplayer.get_remote_sender_id()
	var lobby = GamManager.peer_to_game_map[peer_id]
	
	rpc_id(lobby, "on_player_has_end_turn", nationID)
	
@rpc("authority", "reliable") 
func on_player_has_end_turn(_nationID): # should only be sent by clients
	pass
	

# Update Phase
@rpc("any_peer", "reliable") 
func update_phase(phase): # called by host
	var peer_id = multiplayer.get_remote_sender_id()
	
	rpc_id(peer_id, "on_phase_update", phase)
	for player in GamManager.lobbies[peer_id]:
		rpc_id(player, "on_phase_update", phase)
		
@rpc("authority", "reliable") 
func on_phase_update(_phase):
	pass
	
# NOTE: Events
@rpc("authority", "reliable") 
func on_event_occured(_eventName):
	pass
	
@rpc("any_peer", "reliable") 
func send_event(eventName):
	var peer_id = multiplayer.get_remote_sender_id()
	
	rpc_id(peer_id, "on_event_occured", eventName)
	for player in GamManager.lobbies[peer_id]:
		rpc_id(player, "on_event_occured", eventName)
