class_name BuildingModel extends Resource

@export var nationAtlasLevelPosition: Vector2 = Vector2(0,0)
@export var randomBaseStat: int = 0

func _init():
	randomBaseStat = randi_range(1,8)
