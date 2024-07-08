extends Node2D

@onready var start_button = $StartButton
@onready var player_rect = $VBoxContainer/Label
@onready var v_box_container = $VBoxContainer

@export var readyColor: Color = Color.LIGHT_GREEN
@export var unreadyColor: Color = Color.INDIAN_RED

var lastArr = ""

func _process(delta):
	start_button.disabled = GamManager.connected_peer_ids.size() != GamManager.ready_peer_ids.size() or GamManager.connected_peer_ids.size() == 0
		
	#if str(GamManager.connected_peer_ids) != lastArr:
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)

	for id in GamManager.connected_peer_ids:
		var e = player_rect.duplicate()
		e.add_theme_color_override("font_color", unreadyColor)
		e.text = str(id) + ": " + GamManager.messages[id]
		if id in GamManager.ready_peer_ids:
			e.add_theme_color_override("font_color", readyColor)
			
		v_box_container.add_child(e)
	
	lastArr = str(GamManager.connected_peer_ids)

func _on_start_button_pressed():
	GamManager.start_game()
