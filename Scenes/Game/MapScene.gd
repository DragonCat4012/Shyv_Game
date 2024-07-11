extends Node2D

@onready var coordinate_tracker = $Camera2D/Control/TileInfoPanel/CoordinateTracker
@onready var peer_id = $Camera2D/Control/PeerID
@onready var tile_info_panel = $Camera2D/Control/TileInfoPanel
@onready var tile_owner = $Camera2D/Control/TileInfoPanel/TileOwner
@onready var tile_level = $Camera2D/Control/TileInfoPanel/TileLevel
@onready var tile_stat = $Camera2D/Control/TileInfoPanel/TileStat
@onready var tile_stat_modifier = $Camera2D/Control/TileInfoPanel/TileStatModifier

@onready var camera_2d = $Camera2D
@onready var tile_map : TileMap = $TileMap
var source_id = 1

var water_atlas = Vector2i(0,0)
var land_atlas = Vector2i(0,1)
var dessert_atlas = Vector2i(0,2)
var high_land_atlas = Vector2i(0,3)

var select_atlas = Vector2i(1,0)
var building_atlas = Vector2i(2,0)
var level_atlas = Vector2i(3,0)

@export var noise_height_texture: NoiseTexture2D
var noise: FastNoiseLite

var width := 50
var height := 50

# caching
var oldSeelctedTile = null#Vector2i(-999,-999)
var oldTileBuildings = []

# Layers
const layerTerrain = 0
const layerLevel = 1
const layerIcon = 2 
const layerSelect = 3

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
		_select_tile(get_global_mouse_position())
				
func _select_tile(global: Vector2):
	var tilePos = tile_map.local_to_map(to_local(global))
	tile_map.clear_layer(layerSelect) # clear previous seelction

	if tilePos == oldSeelctedTile:
		oldSeelctedTile = null
		_toggle_tile_info_viibillity(false)
		return
		
	oldSeelctedTile = tilePos
	var buildingAtlasCoordinates = tile_map.get_cell_atlas_coords(layerTerrain, tilePos)
	_toggle_tile_info_viibillity(true, buildingAtlasCoordinates)
	
	tile_map.set_cell(layerSelect, tilePos, source_id, select_atlas)
	coordinate_tracker.text = str(tilePos)
	_style_selected_tile_info(tilePos)
	
func _generate_world():
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue := noise.get_noise_2d(2*x, 2*y)
			if noiseValue >= 0.0: # land
				tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, land_atlas)
				GamManager.land_tiles.append(Vector2(x,y))
			if noiseValue >= 0.2: # high land
				tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, high_land_atlas)
				GamManager.land_tiles.append(Vector2(x,y))
			elif noiseValue < 0.0: # water
				tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, water_atlas)

func _update_tile_buildings():
	tile_map.clear_layer(layerIcon)

	for tile in GamManager.building_tiles:
		var nation = GamManager.get_nation_to_tile(tile.coords)
		var atlasPositionBefore = tile_map.get_cell_atlas_coords(layerTerrain, tile.coords)
		var newAtlas = Vector2i(building_atlas.x, nation.building_tile_row)
		var levelAtlas = Vector2i(level_atlas.x, tile.building.currentLevel)
		
		tile_map.set_cell(layerIcon, tile.coords, source_id, newAtlas)
		tile_map.set_cell(layerLevel, tile.coords, source_id, levelAtlas)
		
		# Add nation colors to tiles
		var modulatedIcon = tile_map.get_cell_tile_data(layerIcon, tile.coords)
		if modulatedIcon:
			modulatedIcon.modulate = nation.color
		
		var modulatedLevel = tile_map.get_cell_tile_data(layerLevel, tile.coords)
		if modulatedLevel:
			modulatedLevel.modulate = nation.color
		
func _toggle_tile_info_viibillity(on, atlasOwner=Vector2i(-1,-1)):
	var ownerStr = "-"
	if atlasOwner != Vector2i(-1,-1): # tile on this layer
		ownerStr = str(atlasOwner.y)
	
	tile_info_panel.visible = on
	tile_owner.text = ownerStr
	
func _style_selected_tile_info(pos: Vector2):
	var nation = GamManager.get_nation_to_tile(pos)
	var building = GamManager.get_buildTile_from_pos(pos)
	
	if not nation:
		tile_owner.text = "?"
		tile_owner.add_theme_color_override("font_color", Color.BLACK)
		return
	tile_owner.add_theme_color_override("font_color", nation.color)	
	
	tile_owner.text = nation.name + "[" + str(nation.assignedID) + "]"
	tile_level.text = str(building.building.currentLevel)
	tile_stat.text = str(snapped(building.building.randomBaseStat,0.01))
	tile_stat_modifier.text = str(snapped(building.building.randomBaseStatModifier,0.01))
