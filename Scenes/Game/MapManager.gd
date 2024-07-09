extends Node

@rpc("any_peer", "call_local")
func _on_tile_update(tileJSON: String):
	GamManager.print_signed("receive tile update")
	update_tiles(tileJSON)
	var peer_id = multiplayer.get_remote_sender_id()
	GamManager.print_signed("Tile updated by: ", peer_id," tile: ", tileJSON)

func send_tile_update(tile: BuildingTiles):
	GamManager.print_signed("sent tile update")
	rpc("_on_tile_update", Jsonutil.BuildingTile_to_JSON(tile))
	#dont call update_tiles(tile)!
	
# Called after rpc
func update_tiles(tileJSON: String):
	var tile = Jsonutil.BuildingTiles_from_JSON(tileJSON)
	var tiles = GamManager.building_tiles.map(func(tile): return tile.coords )
	if tile.coords in tiles:
		# remove old tile
		GamManager.building_tiles = GamManager.building_tiles.filter(func(e): e.coords !=  tile.coords)
	# Add new tile
	GamManager.building_tiles.append(tile)
	
