extends Node2D

@onready var coordinate_tracker = $Camera2D/Control/CoordinateTracker
@onready var peer_id = $Camera2D/Control/PeerID

@onready var camera_2d = $Camera2D
@onready var tile_map = $TileMap
var source_id = 1
var idk_atlas = Vector2i(0,2)
var water_atlas = Vector2i(0,0)
var land_atlas = Vector2i(0,1)
var high_land_atlas = Vector2i(0,3)

@export var noise_height_texture: NoiseTexture2D
var noise: FastNoiseLite

var width := 50
var height := 50

# caching
var oldSeelctedTile = Vector2i(-999,-999)
var oldTileBuildings = []

func _ready():
	noise = noise_height_texture.noise
	noise.seed = GamManager.seed
	_generate_world()
	peer_id.text = str(GamManager.ownID)

func _process(delta):
	if oldTileBuildings == GamManager.building_tiles:
		return
	_update_tile_buildings()
	oldTileBuildings = GamManager.building_tiles

func _input(event):
	if(Input.is_action_just_released("left_click")):
		tile_map.local_to_map(to_local(get_global_mouse_position()))
		_seelct_tile(get_global_mouse_position())
				
func _seelct_tile(global: Vector2):
	var tilePos = tile_map.local_to_map(to_local(global))
	if tilePos == oldSeelctedTile:
		return
	else:
		var beforeAtlas = tile_map.get_cell_atlas_coords(0, oldSeelctedTile) - Vector2i(1, 0)
		tile_map.set_cell(0, oldSeelctedTile, source_id, beforeAtlas)
		oldSeelctedTile = tilePos

	var afterAtlas = tile_map.get_cell_atlas_coords(0, tilePos) + Vector2i(1, 0)
	tile_map.set_cell(0, tilePos, source_id, afterAtlas)
	coordinate_tracker.text = str(tilePos)

func _generate_world():
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue := noise.get_noise_2d(2*x, 2*y)
			if noiseValue >= 0.0: # land
				tile_map.set_cell(0, Vector2(x,y), source_id, land_atlas)
				GamManager.land_tiles.append(Vector2(x,y))
			if noiseValue >= 0.2: # high land
				tile_map.set_cell(0, Vector2(x,y), source_id, high_land_atlas)
				GamManager.land_tiles.append(Vector2(x,y))
			elif noiseValue < 0.0: # water
				tile_map.set_cell(0, Vector2(x,y), source_id, water_atlas)

func _update_tile_buildings():
	print(">>> update tiles")
	for tile in GamManager.building_tiles:
		tile_map.set_cell(0, tile.coords, source_id, idk_atlas)
