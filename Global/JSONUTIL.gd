extends Node

var BuildingTiles = preload("res://Models/BuildingTiles.gd")

func BuildingTile_to_JSON(tile: BuildingTiles) -> String: # TODO: stringify Building
	var dict = {"ownedByNationID": tile.ownedByNationID, "coords": { "x": tile.coords.x, "y": tile.coords.y}, "building": ""}
	return JSON.stringify(dict)

func BuildingTiles_from_JSON(str: String) -> BuildingTiles:
	var tile = BuildingTiles.new()
	var dict = JSON.parse_string(str)
	tile.ownedByNationID = dict["ownedByNationID"]
	tile.coords = Vector2(dict["coords"]["x"], dict["coords"]["y"])
	return tile
