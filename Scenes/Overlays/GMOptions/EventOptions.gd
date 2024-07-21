extends Panel


func _on_btn_event_1_pressed():
	EventSystem.EVENT_SELECTED.emit("aloha1")

func _on_btn_event_2_pressed():
	EventSystem.EVENT_SELECTED.emit("aloha2")

func _on_btn_event_3_pressed():
	EventSystem.EVENT_SELECTED.emit("aloha3")


func _on_visibility_changed():
	# TODO: generate new Events?
	print("update event visibillity")
