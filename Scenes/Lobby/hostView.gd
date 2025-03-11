extends Node2D

@onready var start_button = $StartButton
@onready var player_rect = $Panel/VBoxContainer/Label
@onready var v_box_container = $Panel/VBoxContainer
@onready var id_label = $IDLabel
@onready var animation_player = $AnimationPlayer

var lastArr = ""

func _process(_delta):
	start_button.disabled = GamManager.connected_peer_ids.size() != GamManager.ready_peer_ids.size() or GamManager.connected_peer_ids.size() == 0
	if not start_button.disabled:
		animation_player.play("start_animate")
	else: 
		animation_player.play("RESET")
		
	#if str(GamManager.connected_peer_ids) != lastArr:
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)

	for id in GamManager.connected_peer_ids:
		var e = player_rect.duplicate()
		e.text = str(id)
		e.add_theme_color_override("font_color", Color.WHITE)
		
		if id in GamManager.ready_peer_ids:
			var player_nation: NationModel = GamManager.nationMapping[str(id)]
			
			e.add_theme_color_override("font_color", player_nation.color)
			e.text = player_nation.name + " [" + str(id) +"]"
			if not player_nation.leaderName.is_empty():
				e.text = player_nation.name + " [" + player_nation.leaderName +"]"
			
			
		v_box_container.add_child(e)
	
	lastArr = str(GamManager.connected_peer_ids)
	id_label.text = "Lobby/ID: " + str(GamManager.ownID)

func _on_start_button_pressed():
	var mapSeed = randi_range(0,9)
	LobbyManager._start_game(mapSeed)

func _on_exit_button_pressed():
	GamManager.close_lobby()
	get_tree().change_scene_to_file(SceneManager.MENUSCENE)
