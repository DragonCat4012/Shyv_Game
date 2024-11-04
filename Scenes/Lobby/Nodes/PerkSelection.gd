extends Control

@export var id = 0

@onready var color_rect = $ColorRect
@onready var color_rect_2 = $ColorRect2
@onready var label = $Label
@onready var texture_rect = $TextureRect


func _ready():
	EventSystem.PERK_SELECTED.connect(_handle_selected_perk)
	deselect()
	label.text = str(id)
	
func select():
	color_rect.hide()
	color_rect_2.show()
	texture_rect.show()

func deselect():
	color_rect.show()
	color_rect_2.hide()
	texture_rect.hide()
	
func _handle_selected_perk(selectedid):
	if selectedid != id:
		deselect()

func _on_color_rect_gui_input(event):
	if Input.is_action_just_released("left_click"):
		EventSystem.PERK_SELECTED.emit(id)
		select()
