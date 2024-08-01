extends Node2D

@onready var peer_id =$Camera2D/Control/NameBox/PeerID

@onready var name_box = $Camera2D/Control/NameBox

# Tile Info
@onready var tile_info_panel = $Camera2D/Control/TileInfoPanel
@onready var coordinate_tracker = $Camera2D/Control/TileInfoPanel/CoordinateTracker
@onready var tile_owner = $Camera2D/Control/TileInfoPanel/TileOwner
@onready var tile_level = $Camera2D/Control/TileInfoPanel/TileLevel
@onready var tile_stat = $Camera2D/Control/TileInfoPanel/TileStat
@onready var tile_stat_modifier = $Camera2D/Control/TileInfoPanel/TileStatModifier

@onready var camera_2d = $Camera2D
@onready var tile_map : TileMap = $TileMap

# Overlays
@onready var game_phases_scene = $Camera2D/Control/GamePhasesScene
@onready var player_list_scene = $Camera2D/Control/PlayerListScene
@onready var event_options_scene = $Camera2D/Control/EventOptions
@onready var player_list_button = $Camera2D/Control/PlayerListButton
@onready var turn_view = $Camera2D/Control/TurnView
@onready var event_dialogue_scene = $Camera2D/Control/EventDialogueScene

var source_id = 1

var water_atlas = Vector2i(0,0)
var water_atlas2 = Vector2i(0,4)
var land_atlas = Vector2i(0,1)
var land_atlas2 = Vector2i(1,1)
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
	noise.seed = GamManager.mapSeed
	_generate_world()
	peer_id.text = str(GamManager.ownID)
	
	if GamManager.ownNation:
		peer_id.text = GamManager.ownNation.name
		peer_id.add_theme_color_override("font_color", GamManager.ownNation.color)	
	if GamManager.isHost:
		name_box.visible = false
		
	# Default hide
	event_options_scene.visible = false
	player_list_scene.visible = false
	tile_info_panel.visible = false
	event_dialogue_scene.visible = false
	
	# Connect to Signals
	EventSystem.PHASE_UPDATED.connect(_on_update_game_phase)
	EventSystem.EVENT_SELECTED.connect(_on_event_selected)
	EventSystem.EVENT_OCCURED.connect(_on_event_occured)
	EventSystem.EVENT_ACCEPTED.connect(_on_event_accepted)

func _process(_delta):
	if oldTileBuildings == GamManager.building_tiles:
		return
	_update_tile_buildings()
	oldTileBuildings = GamManager.building_tiles
	
func _on_control_gui_input(_event):
	if Input.is_action_just_released("left_click"):
		tile_map.local_to_map(to_local(get_global_mouse_position()))
		#%Minimap.updateRect(to_local(get_global_mouse_position())) # TODO: highlight selected?
		_select_tile(get_global_mouse_position())
				
func _select_tile(global: Vector2):
	var tilePos = tile_map.local_to_map(to_local(global))
	tile_map.clear_layer(layerSelect) # clear previous seelction

	if tilePos == oldSeelctedTile:
		oldSeelctedTile = null
		_toggle_tile_info_visibillity(false)
		return
		
	oldSeelctedTile = tilePos
	var buildingAtlasCoordinates = tile_map.get_cell_atlas_coords(layerTerrain, tilePos)
	_toggle_tile_info_visibillity(true, buildingAtlasCoordinates)
	
	tile_map.set_cell(layerSelect, tilePos, source_id, select_atlas)
	coordinate_tracker.text = str(tilePos)
	_style_selected_tile_info(tilePos)
	
func _generate_world():
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue := noise.get_noise_2d(2*x, 2*y)
			if noiseValue >= 0.0: # land
				tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, land_atlas)
				if randi() % 2:
					tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, land_atlas2)
				GamManager.land_tiles.append(Vector2(x,y))
			if noiseValue >= 0.4: # high land
				tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, high_land_atlas)
				GamManager.land_tiles.append(Vector2(x,y))
			elif noiseValue < 0.0: # water
				tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, water_atlas)
				var touchesLand = false
				var neighbors = [Vector2(2*x+1, 2*y), Vector2(2*x, 2*y+1), Vector2(2*x-1, 2*y),Vector2(2*x, 2*y-1),
				Vector2(2*x-1, 2*y-1),Vector2(2*x+1, 2*y-1),Vector2(2*x+1, 2*y+1),Vector2(2*x-1, 2*y+1)]
				for n in neighbors:
					if noise.get_noise_2d(n.x, n.y) >= 0:
						touchesLand = true
				if touchesLand:
					tile_map.set_cell(layerTerrain, Vector2(x,y), source_id, water_atlas2)
	%Minimap._generate_world()

func _update_tile_buildings():
	tile_map.clear_layer(layerIcon)

	for tile in GamManager.building_tiles:
		var nation = GamManager.get_nation_to_tile(tile.coords)
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
		
func _toggle_tile_info_visibillity(on, atlasOwner=Vector2i(-1,-1)):
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

func _on_update_game_phase(phase: int):
	print("Updated to new phase: ", phase)
	game_phases_scene.update_to_phase(phase)
	
	if GamManager.isHost and GamManager.currentPhase == 1 and GamManager.phaseCount != 0:
		_toggle_views_for_event_selection(true)
		event_options_scene.visible = true
		
func _on_player_list_button_pressed():
	player_list_scene.visible = !player_list_scene.visible
	player_list_scene.updateList() # amybe change to not be caleld every time

# Hanlde Event Selection
func _on_event_selected(eventName):
	_toggle_views_for_event_selection(false)
	event_options_scene.visible = false
	PhaseManager._send_event(eventName)
	PhaseManager._update_phase()
	
func _toggle_views_for_event_selection(isEventVisible: bool):
	if isEventVisible == true:
		EventSystem.DISABLE_ACTIONS.emit()
		tile_info_panel.visible = !isEventVisible
		player_list_scene.visible = !isEventVisible
	else:
		EventSystem.ENABLE_ACTIONS.emit()
	player_list_button.disabled = isEventVisible
	
func _on_event_occured(_eventName):
	event_dialogue_scene.visible = true
	_toggle_views_for_event_selection(true)

func _on_event_accepted():
	event_dialogue_scene.visible = false
	_toggle_views_for_event_selection(false)
