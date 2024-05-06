extends powerBase

@onready var timer: Timer = $Timer
var mouseOn: bool = false

func _ready():
	timer.wait_time = timeLeft

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("%s | %s" % [extra, timeLeft])
			get_earnings()
			Globals.bonusEarns += extra
			Globals.bonusTimeLeft = timeLeft
			position.y = -2000
			timer.start(timeLeft)

func get_earnings():
	var rng = RandomNumberGenerator.new()
	extra += round(rng.randf_range(Globals.baseExtra, Globals.baseExtra + Globals.earnings))

func _on_mouse_entered():
	mouseOn = true

func _on_mouse_exited():
	mouseOn = false

func _on_timer_timeout():
	Globals.bonusEarns = 0
	queue_free()
