class_name NationModel extends Resource

@export var name: String = "Nameless Nation"
@export var description: String = "Nameless Description"

@export var leaderName: = "Random Leader"
@export var leaderBackStory = "Unknown History"

var color: Color = Color.REBECCA_PURPLE
var building_tile_row: int = 0
var assignedID: int = -1 # gets assigned foreach game

# Ressources
@export var resources: Array[int] = [0, 0, 0]

func _init():
	color =Color(randf(), randf(), randf())
	building_tile_row = randi_range(0, 5)
	assignedID = -1 # important! 

func _to_string():
		return "Nationmodel [ name: " + name + ", id: " + str(assignedID) + ", color: " + str(color) + ", leader: " + leaderName + ", row: " + str(building_tile_row) + "]"
