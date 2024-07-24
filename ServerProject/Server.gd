extends Node

var network = ENetMultiplayerPeer.new()
var port = 9999

func _ready():
	start_server()
	
	
func start_server():
	network.create_server(port, 100)
	print("Server started")
	print(IP.get_local_addresses())
	print(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1))
	
	network.connect("peer_connected", _peer_connected)
	network.connect("peer_disconnected", _peer_disconnected)

func _peer_connected(player_id):
	print("> ", player_id, " Connected")
	
func _peer_disconnected(player_id):
	print("> ", player_id, " Disconnected")
