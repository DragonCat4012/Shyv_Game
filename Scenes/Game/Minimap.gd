extends GameMap

@onready var map_node = $"../../../../../TileMap"

@onready var focus = $"../Focus"
@onready var sub_viewport = $".."


var land_atlas_plain = Vector2i(0,1)
var water_atlas_plain = Vector2i(0,0)
var high_land_atlas_plain = Vector2i(0,3)
var building_atlas_plain = Vector2i(1,0)

func _ready():
	var frame  = sub_viewport.get_visible_rect()
	position = frame.position +  Vector2(frame.size.x/2, frame.size.y/2)

func update_minimap_focus(cameraPosition): # max x = 2500, min x = -2500
	# Translate camera to map, then scale?
	focus.position = (cameraPosition + Vector2(1860, 1400))  /28
		
func generate_world(): # TODO: move pls
	var width = map_node.width
	var height = map_node.height
	
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue = map_node.noise.get_noise_2d(2*x, 2*y)
			if noiseValue >= 0.0: # land
				set_cell(map_node.layerTerrain, Vector2(x,y), map_node.source_id, land_atlas_plain)
				GamManager.land_tiles.append(Vector2(x,y))
			if noiseValue >= 0.4: # high land
				set_cell(map_node.layerTerrain, Vector2(x,y), map_node.source_id, high_land_atlas_plain)
				GamManager.land_tiles.append(Vector2(x,y))
			elif noiseValue < 0.0: # water
				set_cell(map_node.layerTerrain, Vector2(x,y), map_node.source_id, water_atlas_plain)
