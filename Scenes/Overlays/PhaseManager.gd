extends Node



@rpc("any_peer", "call_local") 
func on_phase_update(phase):
	GamManager.currentPhase = phase
	EventSystem.PHASE_UPDATED.emit(phase)
	
func update_phase(): # Should only be called by server
	var newPhase = GamManager.currentPhase + 1
	if GamManager.currentPhase >= 4: # last phase begin again
		newPhase = 1
	print("Update Game to new phase: ", newPhase)
	rpc("on_phase_update", newPhase)
	GamManager.currentPhase = newPhase
