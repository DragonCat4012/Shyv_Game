extends Node2D

var BuildingTileBLueprint = preload("res://Models/BuildingTiles.gd")

func _ready():
	var generator = preload("res://Scenes/Game/StartPositionsGenerate.gd").new(GamManager.land_tiles, GamManager.connected_peer_ids)
	var generatedstartPositions = generator.generate_positions()
	print("Start Positions = ", generatedstartPositions)
	
	for position in generatedstartPositions.values(): # (perid: cords)
		var tile = BuildingTileBLueprint.new()
		tile.coords = position
		MapManager.send_tile_update(tile)
