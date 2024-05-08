extends itemBase

func _ready():
	_updateBtnUI()
	tooltip_text = "+%s p/sec" % prodBASE
	if iconSVG != null:
		$ItemIcon.SVGTexture = iconSVG

func _on_pressed():
	if Globals.balance > costNEXT:
		buy()
		_updateBtnUI()

func _updateBtnUI():
	if owned == 0:
		tooltip_text = "Not unlocked"
		text = "Not unlocked\n%s" % [costNEXT]
		$ItemIcon.visible = false
	else:
		text = "x%s %s\n%s (%s)" % [owned, itemNAME, costNEXT, multiplier]
		tooltip_text = "+%s p/sec" % [prodBASE]
		$MultiUpgrade.disabled = false
		$MultiUpgrade.tooltip_text = "This will reset the run\nbut will also upgrade the %s.\nCosts: %s" % [itemNAME, multiplierCost]
		$ItemIcon.visible = true
