extends Node

@rpc("any_peer", "call_local")
func _on_tile_update(tile: BuildingTiles):
	GamManager.print_signed(">>>>>> receive tile update")
	update_tiles(tile)
	var peer_id = multiplayer.get_remote_sender_id()
	GamManager.print_signed("Tile updated by: ", peer_id," tile: ", tile)

func send_tile_update(tile: BuildingTiles):
	GamManager.print_signed("sent tile update")
	rpc("_on_tile_update", tile)
	#update_tiles(tile)

func update_tiles(tile: BuildingTiles):
	var tiles = GamManager.building_tiles.map(func(tile): return tile.coords )
	if tile.coords in tiles:
		# remove old tile
		GamManager.building_tiles = GamManager.building_tiles.filter(func(e): e.coords !=  tile.coords)
	# Add new tile
	GamManager.building_tiles.append(tile)
	
