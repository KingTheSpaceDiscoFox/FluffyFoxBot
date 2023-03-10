extends Gift

@onready var SoundCommandPlayer : AudioStreamPlayer = $"../SoundCommandPlayer"

func _ready() -> void:
	_load_config_file()
	SignalBus.connect("sound_command_delete_request", Callable(self,"_sound_command_delete_request"))
	SignalBus.connect("open_sound_menu", Callable(self,"_open_sound_menu"))
	SignalBus.connect("close_sound_menu", Callable(self,"_close_sound_menu"))
	SignalBus.connect("change_target_channel", Callable(self,"_change_target_channel"))
	SignalBus.connect("retry_token_fetch", Callable(self,"_retry_token_fetch"))
	SignalBus.connect("close_sound_menu", Callable(self,"_close_sound_menu"))
	SignalBus.connect("add_sound_command", Callable(self,"_add_sound_command"))
	SignalBus.connect("on_command_interrupt_button_pressed", Callable(self,"_on_command_interrupt_button_pressed"))
	cmd_no_permission.connect(no_permission)
	chat_message.connect(on_chat)
	event.connect(on_event)

	# When calling this method, a browser will open.
	# Log in to the account that should be used.
	await(authenticate(client_id, client_secret))
	var success = await(connect_to_irc())
	if (success):
		request_caps()
		if channels == {}:
			pass
		var channel_file : FileAccess = FileAccess.open("user://gift/channel", FileAccess.READ)
		if channel_file != null:
			var _target_channel : String = channel_file.get_var()
			if _target_channel == "" or _target_channel == null:
				print("No target channel found")
			else:
				change_target_channel(_target_channel)
	await(connect_to_eventsub())
	# Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
	# what events exist, which API versions are available and which conditions are required.
	# Make sure your token has all required scopes for the event.
	subscribe_event("channel.follow", 2, {"broadcaster_user_id": user_id, "moderator_user_id": user_id})

	# Adds a command with a specified permission flag.
	# All implementations must take at least one arg for the command info.
	# Implementations that recieve args requrires two args,
	# the second arg will contain all params in a PackedStringArray
	# This command can only be executed by VIPS/MODS/SUBS/STREAMER
	add_command("test", command_test, 0, 0, PermissionFlag.NON_REGULAR)

	# These two commands can be executed by everyone
	add_command("helloworld", hello_world)
	add_command("greetme", greet_me)

	# This command can only be executed by the streamer
	add_command("streamer_only", streamer_only, 0, 0, PermissionFlag.STREAMER)

	# Command that requires exactly 1 arg.
	add_command("greet", greet, 1, 1)

	# Command that prints every arg seperated by a comma (infinite args allowed), at least 2 required
	add_command("list", list, -1, 2)

	# Adds a command alias
	add_alias("test","test1")
	add_alias("test","test2")
	add_alias("test","test3")
	# Or do it in a single line
	# add_aliases("test", ["test1", "test2", "test3"])

	# Remove a single command
	remove_command("test2")

	# Now only knows commands "test", "test1" and "test3"
	remove_command("test")
	# Now only knows commands "test1" and "test3"

	# Remove all commands that call the same function as the specified command
	purge_command("test1")
	# Now no "test" command is known

	# Send a chat message to the only connected channel (<channel_name>)
	# Fails, if connected to more than one channel.
#	chat("TEST")

#	 Send a chat message to channel <channel_name>
#	chat("TEST", target_channel)

	# Send a whisper to target user
#	whisper("TEST", initial_channel)

func on_event(type : String, data : Dictionary) -> void:
	match(type):
		"channel.follow":
			print("%s followed your channel!" % data["user_name"])

func on_chat(data : SenderData, msg : String) -> void:
	%ChatContainer.put_chat(data, msg)

# Check the CommandInfo class for the available info of the cmd_info.
@warning_ignore("unused_parameter")
func command_test(cmd_info : CommandInfo) -> void:
	print("A")

@warning_ignore("unused_parameter")
func hello_world(cmd_info : CommandInfo) -> void:
	chat("HELLO WORLD!")

@warning_ignore("unused_parameter")
func streamer_only(cmd_info : CommandInfo) -> void:
	chat("Streamer command executed")

@warning_ignore("unused_parameter")
func no_permission(cmd_info : CommandInfo) -> void:
	chat("NO PERMISSION!")

@warning_ignore("unused_parameter")
func greet(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	chat("Greetings, " + arg_ary[0])

func greet_me(cmd_info : CommandInfo) -> void:
	chat("Greetings, " + cmd_info.sender_data.tags["display-name"] + "!")

func play_sound_command(cmd_info : CommandInfo)->void:
	SignalBus.emit_signal("play_sound_file", cmd_info)

@warning_ignore("unused_parameter")
func list(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
	var msg = ""
	for i in arg_ary.size() - 1:
		msg += arg_ary[i]
		msg += ", "
	msg += arg_ary[arg_ary.size() - 1]
	chat(msg)

func _change_target_channel(new_channel):
	print("attempting changing channel")
	change_target_channel(new_channel)
	
func return_target_channel():
	return target_channel

func _retry_token_fetch():
	remove_token_file()
	get_token()
	
func _open_sound_menu():
	%ChatContainer.visible = false
	%LineEditContainer.visible = false
	
func _close_sound_menu():
	_save_config_file()
	%ChatContainer.visible = true
	%LineEditContainer.visible = true

func _add_sound_command(cmd_dict: Dictionary):
	add_command(cmd_dict.command_name, Callable(self,"play_sound_command"), 0, 0, cmd_dict.permission, WhereFlag.CHAT,  cmd_dict.file_name, cmd_dict.volume)

func _save_config_file():
	var non_interrupt : bool = SoundCommandPlayer.sound_command_non_interrupt
	var master_volume : int = SoundCommandPlayer.master_sound_command_volume
#	var sound_commands : Dictionary = call_capture_all_commands()
	var config_data : ConfigData = ConfigData.new(non_interrupt, master_volume, call_capture_all_commands())
	FileManager.create_config_file(config_data)

func _sound_command_delete_request(cmd_name):
	remove_command(cmd_name)
	
func _read_config_file():
	var config_file : FileAccess = FileAccess.open(FileManager.config_file_path, FileAccess.READ)
	var config_data : Dictionary
	var error : int = FileAccess.get_open_error()
	if error == OK:
		config_data = config_file.get_var(true)
#		while config_file.get_position() < config_file.get_len():
#			config_data = JSON.parse_string(config_file.get_line())
	else:
		push_error(str("Error on config file open, error number: " + str(error)))
	return config_data

func _load_config_file()->void:
	var config_file : Dictionary = _read_config_file()
	print(config_file)
	if config_file.is_empty():
		pass
	else:
		var config_load_data : ConfigData = ConfigData.new(config_file["sound_command_interrupt"], config_file["default_command_volume"],  config_file["sound_commands"])
		SoundCommandPlayer.master_sound_command_volume = int(config_load_data.default_command_volume) 
		SoundCommandPlayer.sound_command_non_interrupt = config_load_data.sound_command_interrupt
		for command in config_load_data.commands_dict:
			var command_dict_for_load = _create_sound_command_dict_from_file(command, config_load_data.commands_dict[command])
			print("config_load_data.commands_dict[command]: ", config_load_data.commands_dict[command])
			_add_sound_command(command_dict_for_load)

func _create_sound_command_dict_from_file(command_name, commands_file_dict) -> Dictionary:
	var snd_cmd_dict: Dictionary = {
		"command_name" : command_name,
		"file_name" : commands_file_dict["sound_file"],
		"permission" : commands_file_dict["permission_level"],
		"volume" : commands_file_dict["volume"]
	}
	print("savedict: ", snd_cmd_dict)
	return snd_cmd_dict

func _on_command_interrupt_button_pressed():
	if SoundCommandPlayer.sound_command_non_interrupt:
		SoundCommandPlayer.sound_command_non_interrupt = false
	else:
		SoundCommandPlayer.sound_command_non_interrupt = true
