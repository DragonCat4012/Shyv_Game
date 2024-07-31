extends Camera2D

var mouse_start_pos
var screen_start_position

var dragging = false
const maxDraggingVal = 2500
const maxDraggingValY = 2000

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
			
		if position.y > maxDraggingValY:
			position.y = maxDraggingValY
		if position.y < -maxDraggingValY:
			position.y = -maxDraggingValY
			
		%Minimap.update_minimap_focus(position)
		
	#print(zoom)
