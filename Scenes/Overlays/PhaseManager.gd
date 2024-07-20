extends Node

# Manage Turns
@rpc("any_peer", "call_local") 
func on_player_has_end_turn(nationID):
	print(nationID, " has ended their turn")
	GamManager.endedTurnNations.append(nationID)
	
func end_turn(): # Should only be called by peer
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
		newPhase = 1
	print("Update Game to new phase: ", newPhase)
	rpc("on_phase_update", newPhase)
	GamManager.currentPhase = newPhase
	GamManager.endedTurnNations = []
