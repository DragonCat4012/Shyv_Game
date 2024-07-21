extends Control
@onready var button = $Button
@onready var next_phase_button = $NextPhaseButton

func _ready():
	next_phase_button.visible = GamManager.isHost
	next_phase_button.disabled = true
	
	button.disabled = GamManager.isHost
	button.visible = !GamManager.isHost

func _process(_delta):
	if GamManager.isHost:
		if GamManager.endedTurnNations.size() != 0:
			next_phase_button.disabled = GamManager.endedTurnNations.size() != GamManager.allNations.size()
		else:
			next_phase_button.disabled = true
		return
	button.disabled = GamManager.hasEndedTurn
	button.visible = !GamManager.hasEndedTurn
	
func _on_button_pressed():
	next_phase_button.focus_mode = FOCUS_NONE
	PhaseManager.end_turn()

func _on_next_phase_button_pressed():
	next_phase_button.focus_mode = FOCUS_NONE
	PhaseManager.update_phase()

func disable_interaction(option):
	next_phase_button.disabled = option
	button.disabled = option
