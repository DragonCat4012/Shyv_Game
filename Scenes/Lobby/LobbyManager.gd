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
	GamManager._add_player_nation_in_lobby(peer_id, playedNation)
	
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
	GamManager._remove_player_nation_in_lobby(peer_id)
	
func send_un_ready():
	rpc("_on_un_ready")
	GamManager.ready_peer_ids.erase(multiplayer.get_unique_id())
	
@rpc("any_peer", "call_local") 
func _on_start_game(seed):
	GamManager.currentPhase = 1
	GamManager.seed = seed
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
func start_game(seed): # Should only be called by server
	GamManager.currentPhase = 1
	_sync_nations_with_peers()
	rpc("_on_start_game", seed)
	GamManager.seed = seed
	
	if GamManager.ownID == 1: # Server
		get_tree().change_scene_to_file(SceneManager.HOSTGAMESCENE)
	else: # Client
		get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
# Sync Nations with Peers
func _sync_nations_with_peers():  # Should only be called by server
	var icons = RessourceManager.ALL_NATION_ICON_OPTIONS.duplicate()
	icons.shuffle()
	for nat in GamManager.allNations: # aplly icon indexes
		var icon = icons.pop_back()
		nat.building_tile_row = icon
		
	print("Manager Nations to sync: ", GamManager.allNations.size())
	var nationJSON = Jsonutil.nations_to_JSON(GamManager.allNations)
	var mappingJSON = Jsonutil.nationMapping_to_JSON(GamManager.nationMapping)
	rpc("_on_sync_nations_with_peers", nationJSON, mappingJSON)

@rpc("any_peer", "call_local") 
func _on_sync_nations_with_peers(nationsJSON, nationsMappingJSON):
	if GamManager.ownID == 1: # Server
		return
	
	GamManager.allNations = Jsonutil.nations_from_JSON(nationsJSON)
	GamManager.nationMapping = Jsonutil.nationMapping_from_JSON(nationsMappingJSON)
	GamManager.ownNation = GamManager.nationMapping[str(GamManager.ownID)]
	get_tree().change_scene_to_file(SceneManager.GAMESCENE)
	
