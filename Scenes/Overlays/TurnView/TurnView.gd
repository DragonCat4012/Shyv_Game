extends Control
@onready var button = $Button
@onready var next_phase_button = $NextPhaseButton

var forceDisabeld = false

func _ready():
	next_phase_button.visible = GamManager.isHost
	next_phase_button.disabled = true
	
	button.disabled = GamManager.isHost
	button.visible = !GamManager.isHost
	
	EventSystem.DISABLE_ACTIONS.connect(_toggle_disabeld.bind(true))
	EventSystem.ENABLE_ACTIONS.connect(_toggle_disabeld.bind(false))

func _process(_delta):
	if GamManager.isHost:
		if GamManager.endedTurnNations.size() != 0:
			next_phase_button.disabled = GamManager.endedTurnNations.size() != GamManager.allNations.size()
		else:
			next_phase_button.disabled = true
		return
	
	if not forceDisabeld:
		button.disabled = GamManager.hasEndedTurn
		button.visible = !GamManager.hasEndedTurn
	else:
		button.disabled = true
		next_phase_button.disabled = true
	
func _on_button_pressed():
	next_phase_button.focus_mode = FOCUS_NONE
	PhaseManager._end_turn()

func _on_next_phase_button_pressed():
	next_phase_button.focus_mode = FOCUS_NONE
	PhaseManager._update_phase()

func _toggle_disabeld(status):
	forceDisabeld = status
