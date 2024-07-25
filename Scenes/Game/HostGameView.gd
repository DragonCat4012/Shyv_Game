extends Node2D


func _ready():
	var nationIDs = GamManager.nationMapping.values().map(func(nation): return nation.assignedID)
	var START_POSITIONS_GENERATOR = RessourceManager.START_POSITIONS_GENERATOR.new(GamManager.land_tiles, nationIDs)
	var generatedstartPositions = START_POSITIONS_GENERATOR.generate_positions()
	print("Start Positions = ", generatedstartPositions)
	
	for nationID in generatedstartPositions.keys(): # (nationID: cords)
		var tile = RessourceManager.BUILDING_TILES.new()
		tile.coords = generatedstartPositions[nationID]
		tile.ownedByNationID = nationID
		tile.building = BuildingModel.new()
		MapManager._send_tile_update(tile)
