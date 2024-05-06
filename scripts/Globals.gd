extends Node

var balance: float = 4.5
var earnings: float = 0.0
var bonusEarns: float = 0.0
var bonusTimeLeft: float = 0.0

var hour: int = 0
var min: int = 0
var sec: int = 0

func _input(event):
	if event.is_action_pressed("exit"):
		#get_tree().quit()
		pass
