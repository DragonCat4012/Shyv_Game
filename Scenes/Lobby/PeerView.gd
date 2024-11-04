extends Node2D

@onready var lobby_label = $LobbyLabel
@onready var host_name = $HostName
@onready var peer_list = $ColorRect/PeerList

@onready var ready_button = $ReadyButton
@onready var name_field := $nameField
@onready var nation_descript = $CreateNation/nationDescript
var isReady = false

# Create Nation
var nation = RessourceManager.LOADED_NATION_MODEL.new()
@onready var nation_name = $CreateNation/nationName
@onready var color_picker = $CreateNation/colorPicker
@onready var leader_name = $CreateNation/Leader/leaderName
@onready var leader_back = $CreateNation/Leader/leaderBack

func _ready():
	color_picker.color = nation.color
	nation_name.text = nation.name
	leader_name.text = nation.leaderName
	leader_back.text = nation.leaderBackStory
	EventSystem.PERK_SELECTED.connect(_handle_selected_perk)

func _process(_delta):
	if !GamManager.connected:
		_exitScene()
	peer_list.text = show_messages()
	host_name.text = "Joined as: " + str(GamManager.multiplayer.get_unique_id())
	#isReady = GamManager.ready_peer_ids.has(GamManager.multiplayer.get_unique_id())
	_update_ready_button(isReady)
	lobby_label.text = str(GamManager.lobbyCode)
	
func display_message(message):
	LobbyManager.send_lobby_message(message)

func _on_line_edit_text_submitted(new_text):
	display_message(new_text)
	name_field.release_focus()
	name_field.text = ""

func show_messages() -> String:
	var msg = ""
	for peer in GamManager.connected_peer_ids:
		var str2 = str(peer)
		if peer in GamManager.messages.keys():
			str2 += ": " + GamManager.messages[peer]
		msg += str2 + "\n"
	return msg

func _on_ready_button_pressed():
	if isReady:
		LobbyManager._publish_unready()
		ready_button.theme = null
		isReady = false
		EventSystem.UNREADY_SENT.emit()
	else: 
		isReady = true
		LobbyManager._publish_ready(nation)
		ready_button.theme = RessourceManager.THEME_BUTTON_DELETE
		EventSystem.READY_SENT.emit()

func _on_exit_button_pressed():
	_update_ready_button(false)
	GamManager._leave_lobby()
	_exitScene()

func _update_ready_button(toReady):
	isReady = toReady
	ready_button.text = "Wait!" if isReady else "Ready"
	color_picker.disabled = isReady
	nation_name.editable = !isReady
	nation_descript.editable = !isReady
	leader_name.editable = !isReady
	leader_back.editable = !isReady

func _exitScene():
	get_tree().change_scene_to_file(SceneManager.MENUSCENE)

# Nation Creation
func _on_nation_name_text_submitted(_new_text):
	name_field.release_focus()

func _on_nation_name_text_changed(new_text):
	nation.name = new_text
	
func _on_color_picker_color_changed(color):
	nation.color = color_picker.color

func _on_leader_name_text_submitted(_new_text):
	leader_name.release_focus()

func _on_leader_name_text_changed(new_text):
	nation.leaderName = new_text

func _on_text_input_changed(new_text, extra_arg_0):
	if extra_arg_0 == "leaderBack":
		leader_back = new_text

func _on_text_input_submitted(_new_text, extra_arg_0):
	if extra_arg_0 == "leaderBack":
		leader_back.release_focus()

func _handle_selected_perk(id):
	pass
	# TODO: save to nation
