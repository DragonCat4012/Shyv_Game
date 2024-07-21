extends Panel

@onready var list = $list

func updateList():
	for child in list.get_children():
		list.remove_child(child)
		
	for id in GamManager.nationMapping:
		var newLabel = Label.new()
		var player_nation: NationModel = GamManager.nationMapping[str(id)]
		newLabel.add_theme_color_override("font_color", player_nation.color)
		newLabel.text = player_nation.name #+ " [" + str(id) +"]"
			
		list.add_child(newLabel)
