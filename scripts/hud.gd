extends Control

@onready var confMsg: Label = $Confirmation
var bonusCanDeg: bool = false

func _ready():
	updateUI()
	timeUpdate()

func updateUI():
	var bonus = ""
	$BonusLabel.text = ""
	if Globals.bonusEarns > 0:
		bonus = "+ %s" % Globals.bonusEarns
	$MoneyLabel.text = "balance: %s\n%s p/s %s" % [Globals.balance, Globals.earnings, bonus]
	if Globals.bonusEarns > 0:
		$BonusLabel.text = "Bonus: %s" % str(Globals.bonusTimeLeft+1)

func _process(delta):
	#Fix/Refactor
	if Globals.sec == 60:
		Globals.sec = 0
		Globals.min += 1
		if Globals.min > 59:
			Globals.min = 0
			Globals.hour += 1
	timeUpdate()


func timeUpdate():
	var s: String
	var m: String
	var h: String
	if Globals.sec < 10:
		s = "0%s" % Globals.sec
	else: s = "%s" % Globals.sec
	if Globals.min < 10:
		m = "0%s" % Globals.min
	else: m = "%s" % Globals.min
	if Globals.hour < 10:
		h = "0%s" % Globals.hour
	else:
		h = "%s" % Globals.hour
	$TimePassed.text = "Time\n%s:%s:%s" % [h, m, s]

func _on_timer_timeout():
	Globals.sec += 1
	if Globals.bonusEarns > 0:
		Globals.bonusTimeLeft -= 1
	$Timer.start()

func _on_settings_pressed():
	$SettingsMenu.visible = !$SettingsMenu.visible

func _on_continue_pressed():
	$SettingsMenu.visible = !$SettingsMenu.visible

#Save the game data manually
func _on_save_game_pressed():
	get_tree().current_scene._saveData()
	confirmation("Game Saved")
#remove the current save file
func _on_delete_save_pressed():
	DirAccess.remove_absolute(get_tree().current_scene.savepath)
	confirmation("File Deleted")
	get_tree().current_scene.rebirth(true)

#Save and exit
func _on_exitn_save_pressed():
	get_tree().current_scene._saveData()
	get_tree().quit()

func _on_exit_game_pressed():
	get_tree().quit()

func confirmation(msg):
	confMsg.text = msg
	confMsg.visible = true
	await get_tree().create_timer(1.5).timeout
	confMsg.visible = false
	
