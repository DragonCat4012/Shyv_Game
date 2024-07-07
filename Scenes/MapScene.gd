extends Node2D
@onready var camera_2d = $Camera2D
@onready var tile_map = $TileMap
var source_id = 1
var select_atlas = Vector2i(0,2)
var water_atlas = Vector2i(0,1)
var land_atlas = Vector2i(0,0)

@export var noise_height_texture: NoiseTexture2D
var noise: Noise

var width := 50
var height := 50

func _ready():
	noise = noise_height_texture.noise
	_generate_world()

func _input(event):
	if(Input.is_action_just_released("left_click")):
		tile_map.local_to_map(to_local(get_global_mouse_position()))
		_translate_global_to_tile(get_global_mouse_position())
				
func _translate_global_to_tile(global: Vector2):
	var tilePos = tile_map.local_to_map(to_local(global))
	tile_map.set_cell(0, tilePos, source_id, select_atlas)

func _generate_world():
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue := noise.get_noise_2d(2*x, 2*y)
			if noiseValue >= 0.0: # land
				tile_map.set_cell(0, Vector2(x,y), source_id, land_atlas)
			elif noiseValue < 0.0: # water
				tile_map.set_cell(0, Vector2(x,y), source_id, water_atlas)
