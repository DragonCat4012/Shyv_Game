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
	var dict = {"name": nation.name, "assignedID": nation.assignedID, "description": nation.description, "color": var_to_str(nation.color), "building_tile_row": nation.building_tile_row}
	return JSON.stringify(dict)
	
func NationModel_from_JSON(str: String) -> NationModel:
	var nation = NationModel.new()
	var dict = JSON.parse_string(str)
	if not dict:
		print(">>> Failed to parse Nation <<<")
		return null
	nation.name = dict["name"]
	nation.description = dict["description"]
	nation.color = str_to_var(dict["color"])
	nation.building_tile_row = dict["building_tile_row"]
	nation.assignedID = dict["assignedID"]
	return nation



const ARRAY_DIVIDER_IN_JSON_DONT_ASK = "xoxoILoveYouxoxo" # TODO: chekc that its not in nation name or description, in genral chekc for escaping cnhars
# Sync Nations
func nationMapping_from_JSON(str: String) -> Dictionary:
	var dict = {}
	var stringifiedDict = JSON.parse_string(str)
	for key in stringifiedDict:
		dict[key] = NationModel_from_JSON(stringifiedDict[key])
	return dict
	
func nationMapping_to_JSON(dict: Dictionary) -> String:
	var stringifiedDict = {}
	for key in dict:
		stringifiedDict[key] = NationModel_to_JSON(dict[key])
	return JSON.stringify(stringifiedDict)
		
func nations_from_JSON(str: String) -> Array[NationModel]:
	var finalArr: Array[NationModel]
	var mappedArray: Array[String]
	mappedArray.assign(str.split(ARRAY_DIVIDER_IN_JSON_DONT_ASK))
	
	for i in mappedArray:
		finalArr.append(NationModel_from_JSON(i))

	return finalArr
	
func nations_to_JSON(nations: Array[NationModel]) -> String:
	var mappedArray = nations.map(func(nat): return NationModel_to_JSON(nat))
	return ARRAY_DIVIDER_IN_JSON_DONT_ASK.join(mappedArray)
