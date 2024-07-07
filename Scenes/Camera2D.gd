extends Camera2D

var mouse_start_pos
var screen_start_position

var dragging = false
const maxDraggingVal = 2500

func _input(event):
	if event.is_action("drag"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position =  zoom * (mouse_start_pos - event.position) + screen_start_position
		
		if position.x > maxDraggingVal:
			position.x = maxDraggingVal
		if position.x < -maxDraggingVal:
			position.x = -maxDraggingVal
			
		if position.y > maxDraggingVal:
			position.y = maxDraggingVal
		if position.y < -maxDraggingVal:
			position.y = -maxDraggingVal
		
	#print(zoom)
