extends Node2D

@onready var peer_id = $Camera2D/Control/NameBox/PeerID
@onready var name_box = $Camera2D/Control/NameBox
@onready var phase_count = $Camera2D/Control/NameBox/PhaseCount

# Tile Info
@onready var tile_info_panel = $Camera2D/Control/TileInfo

@onready var camera_2d = $Camera2D
@onready var tile_map: TileMap = $TileMap

# Overlays
@onready var game_phases_scene = $Camera2D/Control/GamePhasesScene
@onready var player_list_scene = $Camera2D/Control/PlayerListScene
@onready var event_options_scene = $Camera2D/Control/EventOptions
@onready var player_list_button = $Camera2D/Control/PlayerListButton
@onready var turn_view = $Camera2D/Control/TurnView
@onready var event_dialogue_scene = $Camera2D/Control/EventDialogueScene

@export var noise_height_texture: NoiseTexture2D
var noise: FastNoiseLite

func _ready():
	tile_map.init_data(GamManager.mapSeed, noise_height_texture)
	tile_map.generate_world()
	%Minimap.generate_world()
	
	peer_id.text = str(GamManager.ownID)
	
	if GamManager.ownNation:
		peer_id.text = GamManager.ownNation.name
		peer_id.add_theme_color_override("font_color", GamManager.ownNation.color)
	if GamManager.isHost:
		peer_id.visible = false
		
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
	
	EventSystem.DISABLE_ACTIONS.connect(_toggle_views_for_event_selection.bind(true))
	EventSystem.ENABLE_ACTIONS.connect(_toggle_views_for_event_selection.bind(false))

func _process(_delta):
	if tile_map.oldTileBuildings == GamManager.building_tiles:
		return
	tile_map.update_tile_buildings()
	%Minimap.update_tile_buildings()
	tile_map.oldTileBuildings = GamManager.building_tiles
	
func _on_control_gui_input(_event):
	if Input.is_action_just_released("left_click"):
		tile_map.local_to_map(to_local(get_global_mouse_position()))
		_select_tile(get_global_mouse_position())
	if Input.is_action_just_released("right_click"): # undo selection if there is one
		if tile_map.oldSeelctedTile:
			_select_tile_local(tile_map.oldSeelctedTile)
				
func _select_tile(global: Vector2):
	var tilePos = tile_map.local_to_map(to_local(global))
	_select_tile_local(tilePos)
	
func _select_tile_local(tilePos: Vector2):
	tile_map.clear_layer(tile_map.layerSelect) # clear previous selection

	if tilePos == tile_map.oldSeelctedTile:
		tile_map.oldSeelctedTile = null
		_toggle_tile_info_visibillity(false)
		return
	
	var buildingAtlasCoordinates = tile_map.get_building_atlas_coordinates(tilePos)
	_toggle_tile_info_visibillity(true, buildingAtlasCoordinates)
	
	tile_map.select_tile(tilePos)
	tile_map.oldSeelctedTile = tilePos
	tile_info_panel._style_selected_tile_info(tilePos)
	
func _toggle_tile_info_visibillity(on, _atlasOwner = Vector2i(-1, -1)):
	tile_info_panel.visible = on

func _on_update_game_phase(phase: int):
	game_phases_scene.update_to_phase(phase)
	phase_count.text = str(GamManager.phaseCount)
	
	if phase == 1: # Handle event selection
		turn_view._toggle_disabeld(true)
		EventSystem.DISABLE_ACTIONS.emit()
		
		if GamManager.isHost and GamManager.phaseCount != 0:
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
		tile_info_panel.visible = !isEventVisible
		player_list_scene.visible = !isEventVisible
				
	player_list_button.disabled = isEventVisible
	
func _on_event_occured(_eventName):
	event_dialogue_scene.visible = true
	_toggle_views_for_event_selection(true)
	turn_view._toggle_disabeld(true)

func _on_event_accepted():
	event_dialogue_scene.visible = false
	_toggle_views_for_event_selection(false)
	turn_view._toggle_disabeld(false)
