extends Node2D

@onready var player_rect = $VBoxContainer/Label
@onready var v_box_container = $VBoxContainer
var lastArr = ""

func _process(delta):
	#if str(GamManager.connected_peer_ids) != lastArr:
	for child in v_box_container.get_children():
		v_box_container.remove_child(child)

	for id in GamManager.connected_peer_ids:
		var e = player_rect.duplicate()
		e.text = str(id) + ": " + GamManager.messages[id]
		v_box_container.add_child(e)
	
	lastArr = str(GamManager.connected_peer_ids)
