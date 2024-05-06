extends Button
class_name itemBase

@export var itemNAME: String = "temp"
@export var owned: int = 0
@export var costBASE: float = 4.0
var costNEXT: float = 0.0
@export var prodBASE: float = 1.0
var prodTOTAL: float = 1.0

@export var rateGROWTH: float = 1.07
@export var multiplierCost: float = 1.0
@export var multiplier: float = 1.0

func reset():
	costNEXT = costBASE
	owned = 0
	get_tree().current_scene.updateUI()
	#$"MultiUpgrade".disabled = true

func save() -> Dictionary:
	var dict := {
		"name": itemNAME, "owned": owned, "costNext": costNEXT, "prodTotal": prodTOTAL,
		"multiplier": multiplier, "multiplierCost": multiplierCost 
	}
	var d = inst_to_dict(self)
	return d

func _enter_tree():
	costNEXT = costBASE

func buy():
	if Globals.balance >= costNEXT:
		Globals.balance -= costNEXT
		get_tree().current_scene.updateUI()
		owned += 1
		_upgrade()

func _upgrade():
	if owned > 0:
		$"MultiUpgrade".makeActive()
	#upgrade the production using the multiplier
	#productionTOTAL = (productionBASE x owned) x multiplier
	prodTOTAL = (prodBASE * owned) * multiplier #production
	costNEXT = costBASE * ((rateGROWTH)**owned)
	costNEXT = snapped(costNEXT, 0.01)
	get_tree().current_scene.updateEarnings()
	#update the price using rateGrowth and the power of owned*
	#costNEXT = costBASE x (rateGROWTH)**owned

func multiUpgrade():
	if Globals.balance >= multiplierCost:
		multiplier += 0.1
		multiplierCost = round((multiplier)*pow(1525, rateGROWTH))
		#Globals.balance -= multiplierCost
		get_tree().current_scene.rebirth()
