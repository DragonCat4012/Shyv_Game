extends Node2D

func _on_join_button_pressed():
	GamManager._on_join_pressed()

func _on_host_button_pressed():
	GamManager._on_host_pressed()

func _on_test_pressed():
	get_tree().change_scene_to_file("res://Scenes/map.tscn")
