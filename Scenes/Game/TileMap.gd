extends TileMap
class_name GameMap

var source_id = 1

var water_atlas = Vector2i(0,0)
var water_atlas2 = Vector2i(2,0)
var water_atlas_light = Vector2i(1,0)

var land_atlas = Vector2i(0,1)
var land_atlas2 = Vector2i(1,1)
var land_atlas3 = Vector2i(2,1)

var dessert_atlas = Vector2i(0,2)

var high_land_atlas = Vector2i(0,3)
var high_land_atlas2 = Vector2i(1,3)
var high_land_atlas3 = Vector2i(2,3)

var waterVariations = [water_atlas, water_atlas2]
var landVariations = [land_atlas, land_atlas2, land_atlas3]
var highLandVariations = [high_land_atlas, high_land_atlas2, high_land_atlas3]

var select_atlas = Vector2i(5,0)
var building_atlas = Vector2i(3,0)
var level_atlas = Vector2i(4,0)

# Layers
const layerTerrain = 0
const layerLevel = 1
const layerIcon = 2 
const layerSelect = 3

var noise: FastNoiseLite

var width := 50
var height := 50

# caching
var oldSeelctedTile = null#Vector2i(-999,-999)
var oldTileBuildings = []

func update_tile_buildings():
	clear_layer(layerIcon)

	for tile in GamManager.building_tiles:
		var nation = GamManager.get_nation_to_tile(tile.coords)
		var newAtlas = Vector2i(building_atlas.x, nation.building_tile_row)
		var levelAtlas = Vector2i(level_atlas.x, tile.building.currentLevel)
		
		set_cell(layerIcon, tile.coords, source_id, newAtlas)
		set_cell(layerLevel, tile.coords, source_id, levelAtlas)
		
		# Add nation colors to tiles
		var modulatedIcon = get_cell_tile_data(layerIcon, tile.coords)
		if modulatedIcon:
			modulatedIcon.modulate = nation.color
		
		var modulatedLevel = get_cell_tile_data(layerLevel, tile.coords)
		if modulatedLevel:
			modulatedLevel.modulate = nation.color
		
# SELECTION
func select_tile(tilePos: Vector2):
	set_cell(layerSelect, tilePos, source_id, select_atlas)

func get_building_atlas_coordinates(tilePos: Vector2):
	return get_cell_atlas_coords(layerTerrain, tilePos)
	
# INIT
func init_data(seed, noise_height_texture):
	noise = noise_height_texture.noise
	noise.seed = seed

func generate_world():
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue := noise.get_noise_2d(2*x, 2*y)
			
			if noiseValue >= 0.0: # land
				set_cell(layerTerrain, Vector2(x,y), source_id, landVariations.pick_random())
				GamManager.land_tiles.append(Vector2(x,y))
				
			if noiseValue >= 0.4: # high land
				set_cell(layerTerrain, Vector2(x,y), source_id, highLandVariations.pick_random())
				GamManager.land_tiles.append(Vector2(x,y))
				
			elif noiseValue < 0.0: # water
				set_cell(layerTerrain, Vector2(x,y), source_id, waterVariations.pick_random())
				var touchesLand = false
				var neighbors = [Vector2(2*x+1, 2*y), Vector2(2*x, 2*y+1), Vector2(2*x-1, 2*y),Vector2(2*x, 2*y-1),
				Vector2(2*x-1, 2*y-1),Vector2(2*x+1, 2*y-1),Vector2(2*x+1, 2*y+1),Vector2(2*x-1, 2*y+1)]
				for n in neighbors:
					if noise.get_noise_2d(n.x, n.y) >= 0:
						touchesLand = true
				if touchesLand:
					set_cell(layerTerrain, Vector2(x,y), source_id, water_atlas_light)
