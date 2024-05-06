extends itemBase

func _enter_tree():
	disabled = true

func makeActive():
	disabled = false
