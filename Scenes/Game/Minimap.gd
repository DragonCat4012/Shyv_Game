extends TileMap
@onready var map_node = $"../../../../../TileMap"

@onready var focus = $"../Focus"
@onready var sub_viewport = $".."

func _ready():
	var frame  = sub_viewport.get_visible_rect()
	position = frame.position +  Vector2(frame.size.x/2, frame.size.y/2)

func update_minimap_focus(cameraPosition): # max x = 2500, min x = -2500
	# Translate camera to map, then scale?
	focus.position = (cameraPosition + Vector2(1860, 1400))  /28
		
func _generate_world(): # TODO: move pls
	var width = map_node.width
	var height = map_node.height
	
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue = map_node.noise.get_noise_2d(2*x, 2*y)
			if noiseValue >= 0.0: # land
				set_cell(map_node.layerTerrain, Vector2(x,y), map_node.source_id, map_node.land_atlas)
				GamManager.land_tiles.append(Vector2(x,y))
			if noiseValue >= 0.4: # high land
				set_cell(map_node.layerTerrain, Vector2(x,y), map_node.source_id, map_node.high_land_atlas)
				GamManager.land_tiles.append(Vector2(x,y))
			elif noiseValue < 0.0: # water
				set_cell(map_node.layerTerrain, Vector2(x,y), map_node.source_id, map_node.water_atlas)
