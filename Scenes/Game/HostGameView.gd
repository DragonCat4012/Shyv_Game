extends Node2D


func _ready():
	var START_POSITIONS_GENERATOR = RessourceManager.START_POSITIONS_GENERATOR.new(GamManager.land_tiles, GamManager.connected_peer_ids)
	var generatedstartPositions = START_POSITIONS_GENERATOR.generate_positions()
	print("Start Positions = ", generatedstartPositions)
	
	for position in generatedstartPositions.values(): # (perid: cords)
		var tile = RessourceManager.BUILDING_TILES.new()
		tile.coords = position
		MapManager.send_tile_update(tile)
