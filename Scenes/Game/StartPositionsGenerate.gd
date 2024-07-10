class_name  StartPositionsGenerate extends Node

var tileMap: Array[Vector2]
var nations: Array[int]

func _init(tiles, peers):
	tileMap = tiles
	nations.assign(peers)
	
func generate_positions() -> Dictionary: # TODO: just first impl not final qwq
	var dict = {} # peerID: Position
	for nationID in nations:
		dict[nationID] = tileMap.pick_random()
	return dict
