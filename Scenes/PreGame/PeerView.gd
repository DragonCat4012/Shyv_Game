extends Node2D

@onready var host_name = $HostName


func _process(delta):
	host_name.text = "ee"#str(GamManager)
