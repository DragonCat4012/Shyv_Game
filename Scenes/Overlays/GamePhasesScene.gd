extends Node2D
@onready var p_1 := $HBoxContainer/P1
@onready var p_2 := $HBoxContainer/P2
@onready var p_3 := $HBoxContainer/P3
@onready var p_4 := $HBoxContainer/P4
@onready var allPhases = [p_1,p_2,p_3, p_4]

func _ready():
	update_to_phase(1)

func update_to_phase(phase: int):
	if phase < 1 or phase > 4:
		print("Error invalid phase: ", phase)
		return
		
	for e in allPhases:
		e.texture = RessourceManager.GAMEPHASES
	
	allPhases[phase-1].texture = RessourceManager.GAMEPHASES_ACTIVE
