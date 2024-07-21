extends Control

func _on_accept_button_pressed():
	EventSystem.EVENT_ACCEPTED.emit()
