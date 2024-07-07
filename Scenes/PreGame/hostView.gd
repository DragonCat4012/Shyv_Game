extends Node2D

@onready var player_list = $PlayerList

func _process(delta):
	player_list.text = str(GamManager.connected_peer_ids)
