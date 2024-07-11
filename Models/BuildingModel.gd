class_name BuildingModel extends Resource

var currentLevel: int = 0 # 0-5

var randomBaseStat: float = 0.0
var randomBaseStatModifier: float = 0.0

func _init():
	randomBaseStat = randf_range(1.0,8.0)
	randomBaseStatModifier = randf_range(0.0,0.5)
	currentLevel = randi_range(0,5)
