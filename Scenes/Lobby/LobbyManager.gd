extends Node

# Send ready and nations, Server RPCs
func _publish_ready(nation):
	rpc_id(1, "publish_ready", Jsonutil.NationModel_to_JSON(nation))
func _publish_unready():
	rpc_id(1, "publish_unready")
@rpc("any_peer", "reliable") 
func publish_ready(_nationSTR): # Client says its ready
	pass
@rpc("any_peer", "reliable") 
func publish_unready(): # Client says its not ready
	pass
	
# HOST RPCS
@rpc("authority", "reliable") 
func on_client_ready(nationSTR, peerID): # host updates his nations
	if peerID not in GamManager.ready_peer_ids:
		GamManager.ready_peer_ids.append(peerID)
	
	var playedNation = Jsonutil.NationModel_from_JSON(nationSTR)
	GamManager._add_player_nation_in_lobby(peerID, playedNation)
	
	GamManager.print_signed("Ready peer: ", peerID)
	
@rpc("authority", "reliable") 
func on_client_unready(peerID): # host updates his nations
	#var peer_id = multiplayer.get_remote_sender_id()
	GamManager.print_signed("UN-Ready peer: ", peerID)
	GamManager.ready_peer_ids.erase(peerID)
	GamManager._remove_player_nation_in_lobby(peerID)
	
# Host advertises nations & mapSeed on start
# Start
func _start_game(mapSeed): #  only called by host
	if not GamManager.isHost:
		print("youre not host :c")
		return
	GamManager.mapSeed = mapSeed
	GamManager.currentPhase = 1
	
	var data = _get_nations_to_send()
	rpc_id(1, "start_game", mapSeed, data[0], data[1])
	get_tree().change_scene_to_file(SceneManager.HOSTGAMESCENE) # TODO: move into hostView!?
		
@rpc("any_peer", "reliable") 
func start_game(mapSeed, nations): # For server
	pass

@rpc("authority", "reliable") 
func _on_start_game(mapSeed, nationsJSON, nationsMappingJSON): # All clients should get this exept host
	if GamManager.isHost:
		return
	GamManager.currentPhase = 1
	GamManager.mapSeed = mapSeed
	
	GamManager.allNations = Jsonutil.nations_from_JSON(nationsJSON)
	GamManager.nationMapping = Jsonutil.nationMapping_from_JSON(nationsMappingJSON)
	GamManager.ownNation = GamManager.nationMapping[str(GamManager.ownID)]
	
	get_tree().change_scene_to_file(SceneManager.GAMESCENE) #TODO: move this ino peerView?!
	
# Sync Nations with Peers
func _get_nations_to_send() -> Array:  # Should only be called by server
	var icons = RessourceManager.ALL_NATION_ICON_OPTIONS.duplicate()
	icons.shuffle()
	for nat in GamManager.allNations: # aplly icon indexes
		var icon = icons.pop_back()
		nat.building_tile_row = icon
		
	print("Manager Nations to sync: ", GamManager.allNations.size())
	var nationJSON = Jsonutil.nations_to_JSON(GamManager.allNations)
	var mappingJSON = Jsonutil.nationMapping_to_JSON(GamManager.nationMapping)
	return [nationJSON, mappingJSON]
