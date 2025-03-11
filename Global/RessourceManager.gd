extends Node

var ALL_NATION_ICON_OPTIONS = [0,1,2,3,4,5]

var THEME_BUTTON_DELETE = preload("res://Graphics/Themes/deleteTheme.tres")
var BUILDING_TILES = preload("res://Models/BuildingTiles.gd")
var START_POSITIONS_GENERATOR = preload("res://Scenes/Game/StartPositionsGenerate.gd")
var LOADED_NATION_MODEL = preload("res://Models/NationModel.gd")

var isTestMap = false

# Resources
# Saved in array ordered
var res_1 = preload("res://Models/Materials/cheese.tres")
var res = [res_1]
