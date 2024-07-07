extends Node2D

@onready var host_name = $HostName

func _process(delta):
	host_name.text = str(GamManager.connected_peer_ids)
