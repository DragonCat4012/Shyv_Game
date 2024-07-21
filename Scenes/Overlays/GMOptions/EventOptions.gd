extends Panel
@onready var btn_event_1 = $VBoxContainer/BtnEvent1
@onready var btn_event_2 = $VBoxContainer/BtnEvent2
@onready var btn_event_3 = $VBoxContainer/BtnEvent3

var options = ["aloha1","aloha2","aloha3"]

func _on_btn_event_1_pressed():
	EventSystem.EVENT_SELECTED.emit(options[0])

func _on_btn_event_2_pressed():
	EventSystem.EVENT_SELECTED.emit(options[1])

func _on_btn_event_3_pressed():
	EventSystem.EVENT_SELECTED.emit(options[1])

func _on_visibility_changed():
	if visible:
		var events = EventManager.get_random_events()
		options = events
		btn_event_1.text = events[0]
		btn_event_2.text = events[1]
		btn_event_3.text = events[2]
