extends Node2D

var canEarn: bool = false
@onready var timer: Timer = $Timer
@onready var autoSaveTimer: Timer = $AutoSave
@onready var upgradeList = $"CanvasLayer/HUD/UpgradeList"
var upgradeArrList: Array

@export var timeSave: float = 5.0

######TODO########
#TODO Add autosave
#
#For saving
var dc: Dictionary

func rebirth():
	Globals.balance = 4.5
	Globals.earnings = 0
	var list = upgradeList.get_children()
	for x in list:
		x.reset()
		x._updateBtnUI()
		print(x.multiplier)
	updateEarnings()

func _ready():
	timer.start()
	_loadData()
	updateUI()
	timeSave *= 60

func _process(delta):
	if Input.is_action_just_released("save"):
		_saveData()
	if Input.is_action_just_released("exit"):
		$CanvasLayer/HUD/SettingsMenu.visible = !$CanvasLayer/HUD/SettingsMenu.visible
	if canEarn:
		canEarn = false
		Globals.balance += snapped(Globals.earnings, 0.01)
		updateUI()
		timer.start()

func _saveData():
	var path = "user://data.save"
	
	dc["gm"] = {"balance":Globals.balance,"earnings":Globals.earnings}
	dc["time"] = {"hour": Globals.hour, "minutes": Globals.min, "seconds": Globals.sec}
	for x in upgradeList.get_children():
		dc[x.name] = x.call("save")
	
	var json_string = JSON.stringify(dc)
	var save = FileAccess.open(path, FileAccess.WRITE)
	save.store_line(json_string)
	save.close()
	dc.clear()
	$CanvasLayer/HUD.confirmation("Game saved")

func _loadData():
	var path = "user://data.save"
	if not FileAccess.file_exists(path):
		return
	
	var data = FileAccess.open(path, FileAccess.READ)
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