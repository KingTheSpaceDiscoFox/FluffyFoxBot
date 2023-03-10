extends HBoxContainer

var command_name : String


func _ready():
	var deletebutton = Button.new()
	deletebutton.text = "Remove Command"
	deletebutton.connect("pressed",Callable(self,"_delete_sound_command"))
	self.add_child(deletebutton)
	SignalBus.connect("container_refresh_remove",Callable(self,"_container_refresh_remove"))

func _container_refresh_remove():
	queue_free()

func _delete_sound_command():
	print("Attempting to send delete request for: ", command_name)
	SignalBus.emit_signal("sound_command_delete_request", command_name)
	queue_free()

	
func set_sound_command_listing(cmd_data: CommandListingData) -> void:
	$RichTextLabel.text = "Command name: " + cmd_data.command_name + " File_name: " + cmd_data.sound_file + " Default Volume: " + str(cmd_data.volume) + " permission level: " + str(cmd_data.permission_level)
	command_name = cmd_data.command_name
