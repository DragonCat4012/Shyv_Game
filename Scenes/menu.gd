extends Node2D
@onready var version_label = $VersionLabel
@onready var v_box_container = $VBoxContainer
var isLoading = false 

func _ready():
	# Load version Info
	var file = FileAccess.open("res://version.txt", FileAccess.READ)
	var version = file.get_as_text()
	file.close()
	version_label.text = version
	GamManager._connect_to_server()
	EventSystem.LOBBY_JOINED.connect(_change_to_peer_view)
	EventSystem.START_CONNECTING.connect(_update_loading_status.bind(true))
	EventSystem.STOP_CONNECTING.connect(_update_loading_status.bind(false))
	
var lastDisabled = false
func _process(_delta):
	var disabled = true
	if GamManager.connectedToServer and not isLoading:
		disabled = false
	
	if lastDisabled == disabled:
		return
	
	for child in v_box_container.get_children():
		if child.name == "Test":
			continue
		child.disabled = disabled
	lastDisabled = disabled
	
func _on_join_button_pressed():
	GamManager._request_lobbies()
	get_tree().change_scene_to_file(SceneManager.OPENGAMESSELECTION)
	
func _on_join_random_button_pressed():
	GamManager._on_join_pressed()

func _on_host_button_pressed():
	GamManager._on_host_pressed()
	get_tree().change_scene_to_file(SceneManager.HOSTSCENE)

func _on_test_pressed():
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
func _update_loading_status(newIsLoading):
	isLoading = newIsLoading
	
#Scenes
func _change_to_peer_view():
	get_tree().change_scene_to_file(SceneManager.PEERSCENE)
