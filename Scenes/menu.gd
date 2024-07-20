extends Node2D
@onready var version_label = $VersionLabel

func _ready():
	# Load version Info
	var versionInfo = load("res://version.txt")
	var file = FileAccess.open("res://version.txt", FileAccess.READ)
	var version = file.get_as_text()
	file.close()
	version_label.text = version
	
func _on_join_button_pressed():
	GamManager._on_join_pressed()
	get_tree().change_scene_to_file(SceneManager.PEERSCENE)

func _on_host_button_pressed():
	GamManager._on_host_pressed()
	get_tree().change_scene_to_file(SceneManager.HOSTSCENE)

func _on_test_pressed():
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
