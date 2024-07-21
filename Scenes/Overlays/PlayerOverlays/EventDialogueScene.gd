extends Control

@onready var description = $VBoxContainer/Description
@onready var title = $VBoxContainer/Title

func _ready():
	EventSystem.EVENT_OCCURED.connect(_on_event_occured)

func _on_accept_button_pressed():
	EventSystem.EVENT_ACCEPTED.emit()

func _on_event_occured(eventName):
	title.text = eventName
	description.text = EventManager.get_event_description_from_name(eventName)
