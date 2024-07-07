extends Node2D
@onready var label = $Label
@onready var player_list = $PlayerList


func _ready():
	label.text = str(GamManager.multiplayer.get_unique_id())


func _process(delta):
	player_list.text = str(GamManager.connected_peer_ids)
