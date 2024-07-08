extends Node2D

@onready var host_name = $HostName
@onready var peer_list = $ColorRect/PeerList

@onready var ready_button = $ReadyButton
@onready var name_field = $nameField
var isReady = false

func _process(delta):
	peer_list.text = show_messages()#str(GamManager.connected_peer_ids)
	host_name.text = "Joined as: " + str(GamManager.multiplayer.get_unique_id())
	isReady = GamManager.ready_peer_ids.has(multiplayer.get_unique_id())
	ready_button.text = "Wait!" if isReady else "Ready"
	
func display_message(message):
	GamManager.send_lobby_message(message)

func _on_line_edit_text_submitted(new_text):
	display_message(new_text)

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
		GamManager.send_un_ready()
	else: 
		GamManager.send_ready()
