extends Node2D

@onready var h_box_container = $VBoxContainer/HBoxContainer
@onready var button = $VBoxContainer/HBoxContainer/Button
@onready var label = $VBoxContainer/HBoxContainer/Label

@onready var v_box_container = $VBoxContainer

var lobbys = []

func _ready():
	EventSystem.FOUND_OPEN_LOBBYS.connect(_updated_lobbys)
	_updated_lobbys(lobbys)
	
func _updated_lobbys(newLobbies):
	lobbys = newLobbies
	
	for i in lobbys:
		var box = h_box_container.duplicate()
		box.visible = true
		var button = button.duplicate()
		button.connect("pressed", _on_join_pressed(i))
		var label = label.duplicate()
		label.text = i

func _on_join_pressed(lobby):
	print("wanna jaoin? ", lobby)
