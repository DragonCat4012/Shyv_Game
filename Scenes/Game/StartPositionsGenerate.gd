class_name  StartPositionsGenerate extends Node

var tileMap: Array[Vector2]
var players: Array[int]

func _init(tiles, peers):
	tileMap = tiles
	players = peers
	
func generate_positions() -> Dictionary: # TODO: just first impl not final qwq
	var dict = {} # peerID: Position
	for player in players:
		dict[player] = tileMap.pick_random()
	return dict
