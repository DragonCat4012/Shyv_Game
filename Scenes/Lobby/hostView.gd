extends Node2D

@onready var start_button = $StartButton
@onready var player_rect = $VBoxContainer/Label
@onready var v_box_container = $VBoxContainer

var lastArr = ""

func _process(delta):
	start_button.disabled = GamManager.connected_peer_ids.size() != GamManager.ready_peer_ids.size() or GamManager.connected_peer_ids.size() == 0
		
	#if str(GamManager.connected_peer_ids) != lastArr:
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)

	for id in GamManager.connected_peer_ids:
		var e = player_rect.duplicate()
		e.text = str(id)
		
		if id in GamManager.ready_peer_ids:
			var player_nation: NationModel = GamManager.nationMapping[str(id)]
			
			e.add_theme_color_override("font_color", player_nation.color)
			e.text = player_nation.name + " [" + str(id) +"]"
			
		v_box_container.add_child(e)
	
	lastArr = str(GamManager.connected_peer_ids)

func _on_start_button_pressed():
	var mapSeed = randi_range(0,9)
	LobbyManager.start_game(mapSeed)

func _on_exit_button_pressed():
	GamManager._diconnect_all_peers_from_host()
	get_tree().change_scene_to_file(SceneManager.MENUSCENE)
