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
		_translate_global_to_tile(get_global_mouse_position())
		#var tile = local_to_map(get_global_mouse_position());
				#something here to get the clicked physics layer?
				
func _translate_global_to_tile(global: Vector2):
	var tilePos = round(global / 125 / 2)
	print(global, " -> ",tilePos)
	tile_map.set_cell(0, tilePos, source_id, select_atlas)
	pass

func _generate_world():
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue := noise.get_noise_2d(x, y)
			if noiseValue >= 0.0: # land
				tile_map.set_cell(0, Vector2(x,y), source_id, land_atlas)
			elif noiseValue < 0.0: # water
				tile_map.set_cell(0, Vector2(x,y), source_id, water_atlas)
