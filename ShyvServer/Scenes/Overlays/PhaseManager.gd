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
func on_phase_update(phase):
	GamManager.currentPhase = phase
	#EventSystem.PHASE_UPDATED.emit(phase)
	GamManager.hasEndedTurn = false
	GamManager.endedTurnNations = []
	
# NOTE: Events
@rpc("any_peer", "reliable") 
func on_event_occured(eventName):
	print(eventName, " has occured")
	#EventSystem.EVENT_OCCURED.emit(eventName)
	
