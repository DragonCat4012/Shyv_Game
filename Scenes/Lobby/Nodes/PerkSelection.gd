extends Control

@export var id = 0

@onready var color_rect = $ColorRect
@onready var color_rect_2 = $ColorRect2
@onready var color_rect_3 = $ColorRect3
@onready var label = $Label
@onready var texture_rect = $TextureRect
@onready var indicator = $Indicator

var isDisabled = false

func _ready():
	EventSystem.PERK_SELECTED.connect(_handle_selected_perk)
	EventSystem.UNREADY_SENT.connect(_handle_unready)
	EventSystem.READY_SENT.connect(_handle_ready)
	
	deselect()
	label.text = str(id)
	
	if id == 2:
		select()
	
func select():
	color_rect.hide()
	color_rect_2.show()
	texture_rect.show()
	color_rect_3.hide()

func deselect():
	color_rect.show()
	color_rect_2.hide()
	texture_rect.hide()
	color_rect_3.hide()
	
func _handle_selected_perk(selectedid):
	if selectedid != id:
		deselect()

func _on_color_rect_gui_input(event):
	if isDisabled:
		return
		
	if Input.is_action_just_released("left_click"):
		EventSystem.PERK_SELECTED.emit(id)
		select()

func _handle_unready():
	isDisabled = false
	color_rect_3.hide()

func _handle_ready():
	isDisabled = true
	color_rect_3.show()
