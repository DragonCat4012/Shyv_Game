extends Node

var network = ENetMultiplayerPeer.new()
var port = 9999

func _ready():
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	start_server()
	
func start_server():
	network.create_server(port, 100)
	multiplayer.multiplayer_peer = network
	
	print("Server started")
	#print(IP.get_local_addresses())
	#print(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1))

func _peer_connected(player_id):
	print("> ", player_id, " Connected")
	
func _peer_disconnected(player_id):
	print("> ", player_id, " Disconnected")
