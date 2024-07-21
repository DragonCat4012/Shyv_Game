extends Node

# Manage Turns
@rpc("any_peer", "call_local") 
func on_player_has_end_turn(nationID):
	print(nationID, " has ended their turn")
	if not str(nationID) in GamManager.endedTurnNations:
		GamManager.endedTurnNations.append(str(nationID))
	
func end_turn(): # Should only be called by peer
	if !GamManager.connected:
		print("Player not connected")
		return
	GamManager.hasEndedTurn = true
	rpc("on_player_has_end_turn", GamManager.ownNation.assignedID)
	
# Update Phase
@rpc("any_peer", "call_local") 
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
@rpc("any_peer", "call_local") 
func on_event_occured(eventName):
	print(eventName, " has occured")
	EventSystem.EVENT_OCCURED.emit(eventName)
	
func send_event(eventName): # Should only be called by server
	if !GamManager.isHost:
		print("Player not host")
		return
	rpc("on_event_occured", eventName)
	
