extends Control
@onready var coordinate_tracker = $TileInfoPanel/CoordinateTracker
@onready var tile_owner = $TileInfoPanel/TileOwner
@onready var tile_level = $TileInfoPanel/TileLevel

@onready var tile_stat = $TileInfoPanel/TileStat
@onready var tile_stat_modifier = $TileInfoPanel/TileStatModifier

func showInfo():
	pass


func updateCoordinates(coords):
	coordinate_tracker.text = str(coords)


func updateOwner(owner: String):
	tile_owner.text = owner


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
