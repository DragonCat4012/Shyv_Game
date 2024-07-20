extends Node2D
@onready var button = $Button
@onready var next_phase_button = $NextPhaseButton

func _ready():
	next_phase_button.visible = GamManager.isHost
	next_phase_button.disabled = true
	
	button.disabled = GamManager.isHost
	button.visible = !GamManager.isHost

func _process(delta):
	if GamManager.isHost:
		if GamManager.endedTurnNations.size() != 0:
			#print("Update end turn button",GamManager.endedTurnNations.size(),GamManager.allNations.size())
			next_phase_button.disabled = GamManager.endedTurnNations.size() != GamManager.allNations.size()
		return
	button.disabled = GamManager.hasEndedTurn
	button.visible = !GamManager.hasEndedTurn
	
func _on_button_pressed():
	PhaseManager.end_turn()

func _on_next_phase_button_pressed():
	PhaseManager.update_phase()
