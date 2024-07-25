extends Node

func _send_tile_update(tile: BuildingTiles):
	rpc_id(1, "send_tile_update", Jsonutil.BuildingTile_to_JSON(tile))
	GamManager.print_signed("sent tile update")
	
@rpc("any_peer", "reliable")
func send_tile_update(_tileJSON): # server rpc
	pass
	
@rpc("authority", "reliable")
func tile_updated(tileJSON):
	GamManager.print_signed("receive tile update")
	update_tiles(tileJSON)
	GamManager.print_signed("Tile updated: ", tileJSON)
	
# Called after rpc
func update_tiles(tileJSON: String):
	var tile = Jsonutil.BuildingTiles_from_JSON(tileJSON)
	var tiles = GamManager.building_tiles.map(func(thisThile): return thisThile.coords )
	if tile.coords in tiles:
		# remove old tile
		GamManager.building_tiles = GamManager.building_tiles.filter(func(e): e.coords !=  tile.coords)
	# Add new tile
	GamManager.building_tiles.append(tile)
	
