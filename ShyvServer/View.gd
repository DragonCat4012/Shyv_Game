extends Node
@onready var v_box_container = $ScrollContainer/VBoxContainer

func _ready():
	GamManager.PRINTLINE.connect(_add_line)
	
func _add_line(content: String):
	var child = Label.new()
	child.text = content
	v_box_container.add_child(child)
