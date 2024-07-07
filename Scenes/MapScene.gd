extends Node2D

@onready var tile_map = $TileMap
var source_id = 1
var water_atlas = Vector2i(0,1)
var land_atlas = Vector2i(0,0)

@export var noise_height_texture: NoiseTexture2D
var noise: Noise

var width := 100
var height := 100

func _ready():
	noise = noise_height_texture.noise
	_generate_world()

func _generate_world():
	for x in range(-width/2 , width/2):
		for y in range(-height/2, height/2):
			var noiseValue := noise.get_noise_2d(x, y)
			if noiseValue >= 0.0: # land
				tile_map.set_cell(0, Vector2(x,y), source_id, land_atlas)
			elif noiseValue < 0.0: # water
				tile_map.set_cell(0, Vector2(x,y), source_id, water_atlas)
