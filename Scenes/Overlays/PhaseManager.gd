extends Node

# Manage Turns
func _end_turn(): # Should only be called by peer
	GamManager.hasEndedTurn = true
	rpc_id(1, "send_end_turn", GamManager.ownNation.assignedID)
	
@rpc("any_peer", "reliable") 
func send_end_turn(nationID): # received by server
	pass
	
@rpc("authority", "reliable") 
func on_player_has_end_turn(nationID): # should only be received by host
	print(nationID, " has ended their turn")
	if not str(nationID) in GamManager.endedTurnNations:
		GamManager.endedTurnNations.append(str(nationID))

	
# Update Phase
@rpc("any_peer", "reliable") 
func on_phase_update(phase):
	GamManager.currentPhase = phase
	EventSystem.PHASE_UPDATED.emit(phase)
	GamManager.hasEndedTurn = false
	GamManager.endedTurnNations = []
	
func update_phase(): # Should only be called by server
	var newPhase = GamManager.currentPhase + 1
	if GamManager.currentPhase >= 4: # last phase begin again
		GamManager.phaseCount += 1
		newPhase = 1
	print("Update Game to new phase: ", newPhase)
	rpc("on_phase_update", newPhase)
	GamManager.currentPhase = newPhase
	GamManager.endedTurnNations = []


# NOTE: Events
@rpc("any_peer", "reliable") 
func on_event_occured(eventName):
	print(eventName, " has occured")
	EventSystem.EVENT_OCCURED.emit(eventName)
	
func send_event(eventName): # Should only be called by server
	if !GamManager.isHost:
		print("Player not host")
		return
	rpc("on_event_occured", eventName)
	
