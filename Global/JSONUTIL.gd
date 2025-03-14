extends Node

# BUILDINGTILES
func BuildingTile_to_JSON(tile: BuildingTiles) -> String:
	var dict = {"ownedByNationID": tile.ownedByNationID, "coords": {"x": tile.coords.x, "y": tile.coords.y}, "building": BUILDINGMODEL_to_JSON(tile.building)}
	return JSON.stringify(dict)

func BuildingTiles_from_JSON(jsonString: String) -> BuildingTiles:
	var tile = BuildingTiles.new()
	var dict = JSON.parse_string(jsonString)
	if not dict:
		print(">>> Failed to parse Tile <<<")
		return null
	tile.ownedByNationID = dict["ownedByNationID"]
	tile.coords = Vector2(dict["coords"]["x"], dict["coords"]["y"])
	tile.building = BUILDINGMODEL_from_JSON(dict["building"])
	return tile
	
	
# NATIONS
func NationModel_to_JSON(nation: NationModel) -> String:
	var dict = {"name": nation.name, "assignedID": nation.assignedID, 
	"description": nation.description, "color": var_to_str(nation.color),
	"leaderName": nation.leaderName, "leaderBackStory": nation.leaderBackStory,
	"resources": nation.resources,
	 "building_tile_row": nation.building_tile_row}
	return JSON.stringify(dict)
	
func NationModel_from_JSON(jsonString: String) -> NationModel:
	var nation = NationModel.new()
	var dict = JSON.parse_string(jsonString)
	if not dict:
		print(">>> Failed to parse Nation <<<")
		return null
	print(dict)
	nation.name = dict["name"]
	nation.description = dict["description"]
	nation.color = str_to_var(dict["color"])
	nation.building_tile_row = dict["building_tile_row"]
	nation.assignedID = dict["assignedID"]
	nation.resources.assign(dict["resources"] as Array[int])
	
	
	nation.leaderName = dict["leaderName"]
	nation.leaderBackStory = dict["leaderBackStory"]
	return nation


const ARRAY_DIVIDER_IN_JSON_DONT_ASK = "xoxoILoveYouxoxo" # TODO: chekc that its not in nation name or description, in genral chekc for escaping cnhars
# Sync Nations
func nationMapping_from_JSON(jsonString: String) -> Dictionary:
	var dict = {}
	var stringifiedDict = JSON.parse_string(jsonString)
	for key in stringifiedDict:
		dict[key] = NationModel_from_JSON(stringifiedDict[key])
	return dict
	
func nationMapping_to_JSON(dict: Dictionary) -> String:
	var stringifiedDict = {}
	for key in dict:
		stringifiedDict[key] = NationModel_to_JSON(dict[key])
	return JSON.stringify(stringifiedDict)
		
func nations_from_JSON(jsonString: String) -> Array[NationModel]:
	var finalArr: Array[NationModel] = []
	var mappedArray: Array[String] = []
	mappedArray.assign(jsonString.split(ARRAY_DIVIDER_IN_JSON_DONT_ASK))
	
	for i in mappedArray:
		finalArr.append(NationModel_from_JSON(i))

	return finalArr
	
func nations_to_JSON(nations: Array[NationModel]) -> String:
	var mappedArray = nations.map(func(nat): return NationModel_to_JSON(nat))
	return ARRAY_DIVIDER_IN_JSON_DONT_ASK.join(mappedArray)


func BUILDINGMODEL_from_JSON(jsonString) -> BuildingModel:
	if jsonString == "":
		return null
	var building = BuildingModel.new()
	var dict = JSON.parse_string(jsonString)
	if not dict:
		print(">>> Failed to parse Building <<<")
		return null
	building.currentLevel = dict["currentLevel"]
	building.randomBaseStat = dict["randomBaseStat"]
	building.randomBaseStatModifier = dict["randomBaseStatModifier"]
	return building
	
func BUILDINGMODEL_to_JSON(building: BuildingModel) -> String:
	if not building:
		return ""
	var dict = {"currentLevel": building.currentLevel, "randomBaseStat": building.randomBaseStat, "randomBaseStatModifier": building.randomBaseStatModifier}
	return JSON.stringify(dict)
