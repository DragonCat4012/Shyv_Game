extends Node2D
@onready var version_label = $VersionLabel
@onready var v_box_container = $VBoxContainer
@onready var animation_player = $cycle/AnimationPlayer


var isLoading = false

func _ready():
	# load server info 
	var file2 = FileAccess.open("res://serverAdress.txt", FileAccess.READ)
	var regex = RegEx.new()
	regex.compile("\\S+")
	var results = []
	for result in regex.search_all(file2.get_as_text()):
		results.push_back(result.get_string())

	GamManager.Adress = results[0]
	file2.close()
	
	# Load version Info
	var file = FileAccess.open("res://version.txt", FileAccess.READ)
	var version = file.get_as_text()
	file.close()
	version_label.text = version
	
	GamManager._connect_to_server()
	EventSystem.LOBBY_JOINED.connect(_change_to_peer_view)
	EventSystem.START_CONNECTING.connect(_update_loading_status.bind(true))
	EventSystem.STOP_CONNECTING.connect(_update_loading_status.bind(false))
	animation_player.play("cycle_loop")
	
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
	RessourceManager.isTestMap = false
	GamManager._request_lobbies()
	get_tree().change_scene_to_file(SceneManager.OPENGAMESSELECTION)
	
func _on_join_random_button_pressed():
	RessourceManager.isTestMap = false
	GamManager._on_join_pressed()

func _on_host_button_pressed():
	RessourceManager.isTestMap = false
	GamManager._on_host_pressed()
	get_tree().change_scene_to_file(SceneManager.HOSTSCENE)

func _on_test_pressed():
	RessourceManager.isTestMap = true
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
func _update_loading_status(newIsLoading):
	isLoading = newIsLoading
	
#Scenes
func _change_to_peer_view():
	if not GamManager.isHost:
		get_tree().change_scene_to_file(SceneManager.PEERSCENE)
