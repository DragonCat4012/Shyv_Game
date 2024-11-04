extends Node

# Lobby
signal CONNECTED_SUCCESSFULL
signal FOUND_OPEN_LOBBYS(lobbys)
signal LOBBY_JOINED
signal LOBBY_CLOSED

signal START_CONNECTING
signal STOP_CONNECTING

# Lobby Perks
signal PERK_SELECTED(id)

# Host
signal PHASE_UPDATED(phase)
signal EVENT_SELECTED(name)

# Client
signal EVENT_OCCURED(eventName)
signal EVENT_ACCEPTED()

# Event
signal DISABLE_ACTIONS
signal ENABLE_ACTIONS
