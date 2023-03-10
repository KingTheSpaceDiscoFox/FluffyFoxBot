extends LineEdit

func _input(event : InputEvent):
	if (event is InputEventKey):
		if (event.pressed && event.keycode == KEY_ENTER):
			%Chat_Button._pressed()
