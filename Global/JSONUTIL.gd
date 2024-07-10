extends Node

const BuildingTiles = preload("res://Models/BuildingTiles.gd")

func BuildingTile_to_JSON(tile: BuildingTiles) -> String: # TODO: stringify Building
	var dict = {"ownedByNationID": tile.ownedByNationID, "coords": { "x": tile.coords.x, "y": tile.coords.y}, "building": ""}
	return JSON.stringify(dict)

func BuildingTiles_from_JSON(str: String) -> BuildingTiles:
	var tile = BuildingTiles.new()
	var dict = JSON.parse_string(str)
	if not dict:
		print(">>> Failed to parse Tile <<<")
		return null
	tile.ownedByNationID = dict["ownedByNationID"]
	tile.coords = Vector2(dict["coords"]["x"], dict["coords"]["y"])
	return tile
	
	
	
const NationModel = preload("res://Models/NationModel.gd")

func NationModel_to_JSON(nation: NationModel) -> String:
	var dict = {"name": nation.name, "description": nation.description, "color": nation.color, "building_tile_row": nation.building_tile_row}
	return JSON.stringify(dict)
	
func NationModel_from_JSON(str: String) -> NationModel:
	var nation = NationModel.new()
	var dict = JSON.parse_string(str)
	if not dict:
		print(">>> Failed to parse Nation <<<")
		return null
	nation.name = dict["name"]
	nation.description = dict["description"]
	nation.color = dict["color"]
	nation.building_tile_row = dict["building_tile_row"]
	return nation
