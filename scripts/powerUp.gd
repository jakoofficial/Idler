extends powerBase

@onready var timer: Timer = $Timer
var mouseOn: bool = false
var ds: Vector2

func _ready():
	timer.wait_time = timeLeft
	ds = DisplayServer.window_get_size()
func _process(delta):
	position.y += speed
	if position.y > (ds.y + 64):
		print("dead")
		queue_free()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			speed = 0
			get_earnings()
			print("%s | %s" % [extra, timeLeft])
			Globals.bonusEarns += extra
			Globals.bonusTimeLeft = timeLeft
			position.y = -2000
			timer.start(timeLeft)

func get_earnings():
	var rng = RandomNumberGenerator.new()
	extra += round(rng.randf_range(Globals.baseExtra, Globals.baseExtra + Globals.earnings))
	timeLeft = round(rng.randf_range(10, 30))

func _on_mouse_entered():
	mouseOn = true

func _on_mouse_exited():
	mouseOn = false

func _on_timer_timeout():
	Globals.bonusEarns = 0
	queue_free()
