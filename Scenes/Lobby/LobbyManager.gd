extends Node

# Lobby Stuff
@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_lobby_message(msg):
	var peer_id = multiplayer.get_remote_sender_id()
	GamManager.print_signed("Function called by peer: ", peer_id," msg: ", msg)
	GamManager.messages[peer_id] = msg

func send_lobby_message(newMessage):
	rpc("_on_lobby_message", newMessage)
	#messages[multiplayer.get_unique_id()] = newMessage
	
@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_ready(nation):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id not in GamManager.ready_peer_ids:
		GamManager.ready_peer_ids.append(peer_id)
	
	var playedNation = Jsonutil.NationModel_from_JSON(nation)
	GamManager.nationMapping[str(peer_id)] = playedNation
	print("#### ", playedNation)
	
	if peer_id == GamManager.ownID:
		return
	GamManager.print_signed("Ready peer: ", peer_id)
	
func send_ready(nation: NationModel):
	rpc("_on_ready", Jsonutil.NationModel_to_JSON(nation))
	GamManager.ready_peer_ids.append(multiplayer.get_unique_id())

@rpc("any_peer", "call_local") # Any peer can call it, calls on self
func _on_un_ready():
	var peer_id = multiplayer.get_remote_sender_id()
	GamManager.print_signed("UN-Ready peer: ", peer_id)
	GamManager.ready_peer_ids.erase(peer_id)
	GamManager.nationMapping.erase(str(peer_id))
	
func send_un_ready():
	rpc("_on_un_ready")
	GamManager.ready_peer_ids.erase(multiplayer.get_unique_id())
	
@rpc("any_peer", "call_local") 
func _on_start_game(seed):
	GamManager.seed = seed
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
func start_game(seed):
	rpc("_on_start_game", seed)
	GamManager.seed = seed
	if GamManager.ownID == 1: # Server
		get_tree().change_scene_to_file(SceneManager.HOSTGAMESCENE)
	else: # Client
		get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
