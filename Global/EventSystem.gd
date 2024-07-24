extends Node

# Lobby
signal CONNECTED_SUCCESSFULL

# Host
signal PHASE_UPDATED(phase)
signal EVENT_SELECTED(name)

# Client
signal EVENT_OCCURED(eventName)
signal EVENT_ACCEPTED()
