extends Camera2D

var mouse_start_pos
var screen_start_position

var dragging = false
const MaxZoomIn = Vector2(2, 2)
const MaxZoomOUT = Vector2(-2, -2)
const zoomSteps = Vector2(0.7, 0.7)

func _input(event):
	if event.is_action("drag"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
			
	if event.is_action_released("zoom_in"):
		if zoom.x + zoomSteps.x >= MaxZoomIn.x:
			zoom = MaxZoomIn
		else:
			zoom += zoomSteps
	elif event.is_action_released("zoom_out"):
		if zoom.x - zoomSteps.x <= MaxZoomOUT.x:
			zoom = MaxZoomOUT	
		else:
			zoom -= zoomSteps
	elif event.is_action_released("zoom_reset"):
		zoom = Vector2(1, 1)
	elif event is InputEventMouseMotion and dragging:
		position = zoom * (mouse_start_pos - event.position) + screen_start_position
		
	print(zoom)
