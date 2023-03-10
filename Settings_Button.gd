extends Button

func _pressed():
	var settings_menu_resource = load("res://SettingsMenu.tscn")
	var settings_menu_instance = settings_menu_resource.instantiate()
	$"/root/Node".add_child(settings_menu_instance)
