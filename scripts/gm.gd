extends Node2D

var canEarn: bool = false
@onready var timer: Timer = $Timer
@onready var autoSaveTimer: Timer = $AutoSave
@onready var upgradeList = $"CanvasLayer/HUD/UpgradeList"
var upgradeArrList: Array
var savepath = "user://data.save"

@export var timeSave: float = 5.0

@onready var powerup: PackedScene = preload("res://assets/power.tscn")
#For saving
var dc: Dictionary

func rebirth(reset:bool = false):
	if reset:
		Globals.hour = 0; Globals.min = 0; Globals.sec = 0
		updateUI()
	Globals.balance = 4.5
	Globals.earnings = 0
	Globals.bonusTimeLeft = 0
	
	if find_child("Power"):
		for x in get_children():
			if x.name == "Power":
				queue_free()
				break
	
	Globals.bonusEarns = 0
	Globals.canSpawnPowerUp = true
	var list = upgradeList.get_children()
	for x in list:
		x.reset()
		x._updateBtnUI()
	updateEarnings()

func _ready():
	timer.start()
	_loadData()
	updateUI()
	timeSave *= 60
	autoSaveTimer.start(timeSave)
	Globals.canSpawnPowerUp = true

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		spawnPowerBonus()
	if Input.is_action_just_released("save"):
		_saveData()
	if Input.is_action_just_released("exit"):
		$CanvasLayer/HUD/SettingsMenu.visible = !$CanvasLayer/HUD/SettingsMenu.visible
	if canEarn:
		canEarn = false
		Globals.balance += snapped(Globals.earnings, 0.01) + Globals.bonusEarns
		updateUI()
		timer.start()
	if Globals.canSpawnPowerUp and Globals.earnings > 0:
		Globals.canSpawnPowerUp = false
		var t = randi_range(60, 7*60)
		#var t = randi_range(1, 11)
		print("timer Start %s" % t)
		await get_tree().create_timer(t).timeout
		spawnPowerBonus()

func spawnPowerBonus():
	var s = DisplayServer.window_get_size()
	var inst = powerup.instantiate()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var sPos = Vector2(round(rng.randf_range(32, (s.x-300))), -64)
	get_tree().current_scene.add_child(inst)
	inst.position = sPos
	inst.speed = rng.randi_range(1, 2)
	inst.rotateSpeed = rng.randi_range(0.2, 1)
	
	print("Power up")
	
	pass
	

func _saveData():
	dc["gm"] = {"balance":Globals.balance,"earnings":Globals.earnings}
	dc["time"] = {"hour": Globals.hour, "minutes": Globals.min, "seconds": Globals.sec}
	for x in upgradeList.get_children():
		dc[x.name] = x.call("save")
	
	var json_string = JSON.stringify(dc)
	var save = FileAccess.open(savepath, FileAccess.WRITE)
	save.store_line(json_string)
	save.close()
	dc.clear()
	$CanvasLayer/HUD.confirmation("Game saved")

func _loadData():
	if not FileAccess.file_exists(savepath):
		return
	
	var data = FileAccess.open(savepath, FileAccess.READ)
	while data.get_position() < data.get_length():
		var json_string = data.get_line()
		var json = JSON.new()
		var pResult = json.parse(json_string)
		var node_data = json.get_data()
		#print(node_data["gm"]["balance"])
		Globals.balance = node_data["gm"]["balance"]
		Globals.earnings = node_data["gm"]["earnings"]
		Globals.hour = node_data["time"]["hour"]
		Globals.min = node_data["time"]["minutes"]
		Globals.sec = node_data["time"]["seconds"]
		
		#Get data for items based on the names
		for x in upgradeList.get_children():
			x.owned = node_data[x.name]["owned"]
			x.costNEXT = node_data[x.name]["costNEXT"]
			x.prodTOTAL = node_data[x.name]["prodTOTAL"]
			x.multiplier = node_data[x.name]["multiplier"]
			x.multiplierCost = node_data[x.name]["multiplierCost"]
			x._updateBtnUI()

func updateUI():
	$CanvasLayer/HUD.updateUI()

func updateEarnings():
	var list = upgradeList.get_children()
	for x in list:
		upgradeArrList.append(x)
	
	Globals.earnings = 0
	for x in upgradeArrList:
		if x.owned > 0:
			Globals.earnings += x.prodTOTAL
	
	upgradeArrList.clear()
	list.clear()

func _on_timer_timeout():
	canEarn = true

func _on_auto_save_timeout():
	_saveData()
	autoSaveTimer.start(timeSave)
