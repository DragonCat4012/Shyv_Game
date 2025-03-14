extends Control

@onready var label = $Label
@onready var label_2 = $Label2
@onready var label_3 = $Label3

func _ready():
	if GamManager.isHost:
		label.visible = false
		label_2.visible = false
		label_3.visible = false
		return 
		
	EventSystem.PHASE_UPDATED.connect(_update)
	_update()
	
func _update():
	if GamManager.isHost or GamManager.ownNation.resources == null:
		return
	
	var ressources = GamManager.ownNation.resources
	
	label.text = str(ressources[0]) +" ✯"
	label_2.text = str(ressources[1]) +" ✯"
	label_3.text = str(ressources[2]) +" ✯"
