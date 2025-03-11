extends Control
@onready var end_turn_button = $EndTurnButton
@onready var next_phase_button = $NextPhaseButton

var forceDisabeld = false

func _ready():
	next_phase_button.visible = GamManager.isHost
	next_phase_button.disabled = true
	
	end_turn_button.disabled = GamManager.isHost
	end_turn_button.visible = !GamManager.isHost

func _process(_delta):
	if GamManager.isHost:
		if GamManager.endedTurnNations.size() != 0:
			next_phase_button.disabled = GamManager.endedTurnNations.size() != GamManager.allNations.size()
		else:
			next_phase_button.disabled = true
		return
	
	if not forceDisabeld:
		end_turn_button.disabled = GamManager.hasEndedTurn
		end_turn_button.visible = !GamManager.hasEndedTurn
	else:
		end_turn_button.disabled = true
		next_phase_button.disabled = true
		
func _on_button_pressed():
	if RessourceManager.isTestMap:
		return
	next_phase_button.focus_mode = FOCUS_NONE
	PhaseManager._end_turn()

func _on_next_phase_button_pressed():
	if RessourceManager.isTestMap:
		return
	next_phase_button.focus_mode = FOCUS_NONE
	PhaseManager._update_phase()

func _toggle_disabeld(status):
	forceDisabeld = status
	end_turn_button.disabled = status
	next_phase_button.disabled = status
