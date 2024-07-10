extends Node2D

@onready var host_name = $HostName
@onready var peer_list = $ColorRect/PeerList

@onready var ready_button = $ReadyButton
@onready var name_field := $nameField
var isReady = false

# Create Nation
var nation = preload("res://Models/NationModel.gd").new()
@onready var nation_name = $CreateNation/nationName
@onready var color_picker = $CreateNation/colorPicker
@onready var tile_index_label = $CreateNation/tileIndexLabel

func _ready():
	color_picker.color = nation.color
	nation_name.text = nation.name
	tile_index_label.text = str(nation.building_tile_row)

func _process(delta):
	if !GamManager.connected:
		_exitScene()
	peer_list.text = show_messages()
	host_name.text = "Joined as: " + str(GamManager.multiplayer.get_unique_id())
	isReady = GamManager.ready_peer_ids.has(GamManager.multiplayer.get_unique_id())
	
	ready_button.text = "Wait!" if isReady else "Ready"
	color_picker.disabled = isReady
	nation_name.editable = !isReady
	
func display_message(message):
	LobbyManager.send_lobby_message(message)

func _on_line_edit_text_submitted(new_text):
	display_message(new_text)
	name_field.release_focus()
	name_field.text = ""

func show_messages() -> String:
	var str = ""
	for peer in GamManager.connected_peer_ids:
		var str2 = str(peer)
		if peer in GamManager.messages.keys():
			str2 += ": " + GamManager.messages[peer]
		str += str2 + "\n"
	return str

func _on_ready_button_pressed():
	if isReady:
		LobbyManager.send_un_ready()
		ready_button.theme = null
	else: 
		LobbyManager.send_ready(nation)
		ready_button.theme = RessourceManager.button_delete_theme

func _on_exit_button_pressed():
	GamManager._diconnect()
	_exitScene()

func _exitScene():
	get_tree().change_scene_to_file(SceneManager.MENUSCENE)

# Nation Creation
func _on_nation_name_text_submitted(new_text):
	name_field.release_focus()

func _on_nation_name_text_changed(new_text):
	nation.name = new_text
	
func _on_color_picker_color_changed(color):
	nation.color = color_picker.color
