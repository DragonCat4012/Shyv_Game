extends Control

@onready var panel = $TileInfoPanel

@onready var coordinate_tracker = $TileInfoPanel/CoordinateTracker
@onready var tile_owner = $TileInfoPanel/TileOwner
@onready var tile_level = $TileInfoPanel/TileLevel

@onready var tile_stat = $TileInfoPanel/TileStat
@onready var tile_stat_modifier = $TileInfoPanel/TileStatModifier

# Owner Stuff
@onready var owner_actions = $TileInfoPanel/OwnerActions
var y_position_no_action: int = 442
var y_position_action: int = 343
@onready var upgrade_button = $TileInfoPanel/OwnerActions/UpgradeButton

var selected_tile_position = null
var selected_tile = null 

func updateOwner(owner: String):
	tile_owner.text = owner

func _style_selected_tile_info(pos: Vector2):
	selected_tile_position = pos
	selected_tile = null
	owner_actions.visible = false
	
	var nation = GamManager.get_nation_to_tile(pos)
	var building = GamManager.get_buildTile_from_pos(pos)
	coordinate_tracker.text = str(pos)

	if not nation:
		panel.position.y = y_position_no_action
		tile_owner.text = "?"
		tile_owner.add_theme_color_override("font_color", Color.BLACK)
		return
	
	if GamManager.ownNation: # host doesnt have nation
		if nation.assignedID == GamManager.ownNation.assignedID: # own tile
			selected_tile = GamManager.get_buildTile_from_pos(selected_tile_position)
			if selected_tile: # Owner Actions
				if GamManager.currentPhase == 2:
					if selected_tile.building.currentLevel == 5:
						upgrade_button.disabled = true
					else: 
						upgrade_button.disabled = false
				else:
					upgrade_button.disabled = false
			panel.position.y = y_position_action
			owner_actions.visible = true
		else:
			panel.position.y = y_position_no_action
		
	tile_owner.add_theme_color_override("font_color", nation.color)	
	
	tile_owner.text = nation.name + "[" + str(nation.assignedID) + "]"
	tile_level.text = str(building.building.currentLevel)
	tile_stat.text = str(snapped(building.building.randomBaseStat,0.01))
	tile_stat_modifier.text = str(snapped(building.building.randomBaseStatModifier,0.01))

func _on_upgrade_button_pressed():
	selected_tile.building.currentLevel += 1
	tile_level.text = str(selected_tile.building.currentLevel) # ikikik not good xd
	MapManager._send_tile_update(selected_tile)
