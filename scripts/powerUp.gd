extends powerBase

@onready var timer: Timer = $Timer
var mouseOn: bool = false

func _enter_tree():
	timer.wait_time = time

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("%s | %s" % [multiplier, time])

func _on_mouse_entered():
	mouseOn = true

func _on_mouse_exited():
	mouseOn = false
