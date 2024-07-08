extends Node2D


func _ready():
	var generator = preload("res://Scenes/Game/StartPositionsGenerate.gd").new(GamManager.land_tiles, GamManager.connected_peer_ids)
	print("Start Positions = ", generator.generate_positions())
