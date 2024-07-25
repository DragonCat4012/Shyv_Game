extends Node2D

@onready var h_box_container = $VBoxContainer/HBoxContainer
@onready var button = $VBoxContainer/HBoxContainer/Button
@onready var label = $VBoxContainer/HBoxContainer/Label

@onready var v_box_container = $VBoxContainer

var lobbys = []

func _ready():
	EventSystem.LOBBY_JOINED.connect(_navigate_to_lobby)
	EventSystem.FOUND_OPEN_LOBBYS.connect(_updated_lobbys)
	_updated_lobbys(lobbys)
	
func _updated_lobbys(newLobbies):
	lobbys = newLobbies
	for x in v_box_container.get_children():
		v_box_container.remove_child(x)
	
	for i in lobbys:
		var box = h_box_container.duplicate()
		box.visible = true
		for ch in box.get_children():
			if ch.name == "Button":
				ch.pressed.connect(self._on_join_pressed.bind(i))
			elif ch.name == "Label":
				ch.text = str(i)
		v_box_container.add_child(box)
		
func _on_join_pressed(lobby):
	GamManager._on_join_lobby_pressed(lobby)

func _navigate_to_lobby():
	get_tree().change_scene_to_file(SceneManager.PEERSCENE)

func _on_exit_button_pressed():
	GamManager._leave_watchlist()
	get_tree().change_scene_to_file(SceneManager.MENUSCENE)
