extends Node2D

@onready var phaseTexture = $StatusPhase
@onready var label = $Label

func _ready():
	label.text = GamManager.phaseNames[GamManager.currentPhase]
	update_to_phase(1)
	
func update_to_phase(phase: int):
	if phase < 1 or phase > 4:
		print("Error invalid phase: ", phase)
		return
	if phase == 2:
		phaseTexture.modulate = Color("#e0932d")
		phaseTexture.rotation_degrees = 90
	elif phase == 3:
		phaseTexture.modulate = Color("#c94080")
		phaseTexture.rotation_degrees = 180
	elif phase == 4:
		phaseTexture.rotation_degrees = 270
		phaseTexture.modulate = Color("#60c467")
	else:
		phaseTexture.modulate = Color("#4D8CFF")
		phaseTexture.rotation_degrees = 0

	label.text = GamManager.phaseNames[phase]
