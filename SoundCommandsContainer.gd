extends VBoxContainer

@onready var SoundFileOptionButton = $HBoxContainer/SoundFileOptionButton
@onready var PermissionsOptionButton = $HBoxContainer/PermissionsOptionButton
@onready var CloseButton = $MenuBar/Close
@onready var ScanButton = $MenuBar/Scan
@onready var FolderButton = $MenuBar/Folder
@onready var CommandVolumeSlider = $HBoxContainer/CommandVolumeSlider
@onready var CommandNameLineEdit = $HBoxContainer/CommandNameLineEdit
@onready var ChangeVolumeButton = $HBoxContainer/ChangeDefaultVolume
@onready var ClearButton = $HBoxContainer2/Clear
@onready var AddCommandButton = $HBoxContainer2/Add
@onready var SoundCommandNonInturruptButton = $MenuBar/SoundCommandInterruptButton
@onready var DebugButton = $MenuBar/DebugButton
@onready var MasterVolumeSlider = $MenuBar/MasterVolume
@onready var FluffBot = get_node("/root/Node/Gift")
@onready var SoundPlayer = get_node("/root/Node/SoundCommandPlayer")

enum PermissionFlag {
	EVERYONE = 0,
	VIP = 1,
	SUB = 2,
	MOD = 4,
	STREAMER = 8,
	# Mods and the streamer
	MOD_STREAMER = 12,
	# Everyone but regular viewers
	NON_REGULAR = 15
}

const DEFAULT_VOLUME: int = 70

var command_name_holder : String = ""
var soundfile_index_list : Dictionary
var soundfile_name_holder : String = ""
var permission_flag_holder : int
var command_volume_holder : int = DEFAULT_VOLUME

func _ready() -> void:
	SignalBus.emit_signal("open_sound_menu")
	DebugButton.connect("pressed",Callable(self,"_on_debug_button_pressed"))
	FolderButton.connect("pressed",Callable(self,"_on_folder_button_pressed"))
	CloseButton.connect("pressed",Callable(self,"_close_sound_command_menu"))
	CommandNameLineEdit.connect("text_changed",Callable(self,"_on_command_name_text_changed"))
	SoundFileOptionButton.connect("item_selected",Callable(self,"_on_sound_file_item_selected"))
	PermissionsOptionButton.connect("item_selected",Callable(self,"_on_permission_option_selected"))
	ScanButton.connect("pressed",Callable(self,"_on_scan_button_pressed"))
	ChangeVolumeButton.connect("pressed",Callable(self,"_on_change_volume_pressed"))
	CommandVolumeSlider.connect("value_changed",Callable(self,"_on_volume_changed"))
	ClearButton.connect("pressed",Callable(self,"_on_clear_button_pressed"))
	AddCommandButton.connect("pressed",Callable(self,"_on_add_button_pressed"))
	SoundCommandNonInturruptButton.connect("pressed",Callable(self,"_on_command_interrupt_button_pressed"))
	MasterVolumeSlider.connect("value_changed",Callable(self,"_on_master_volume_slider_moved"))
	MasterVolumeSlider.value = SoundPlayer.master_sound_command_volume
	_add_all_sound_files_to_option_button()
	_add_permissions_to_option_button()
	_on_clear_button_pressed()
	_populate_commands_list()


func _on_master_volume_slider_moved(value):
	SoundPlayer.master_sound_command_volume = value

func _populate_commands_list()-> void:
	var commands = FluffBot.call_capture_all_commands()
	for command in commands:
		var new_dict : Dictionary = commands[command]
		var cmd_nm: String = command
		var perm_lvl : int = new_dict["permission_level"]
		var snd_file: String = new_dict["sound_file"]
		var vlm : int = new_dict["volume"]
		var whr : int = new_dict["where"]
		var cmd_data = CommandListingData.new(cmd_nm, perm_lvl, snd_file, vlm, whr)
		_put_SoundCommandPanel(cmd_data)
		print("Populating commands list with command: ", command, " full dict: ", commands[command])

func _on_debug_button_pressed() -> void:
	SignalBus.emit_signal("debug_button_pressed")

func _on_command_interrupt_button_pressed() -> void:
	SignalBus.emit_signal("on_command_interrupt_button_pressed")

func _on_add_button_pressed() -> void:
	var cmd_dict = _create_sound_command_dict()
	SignalBus.emit_signal("add_sound_command", cmd_dict)
	_refresh_all_containers()
	_on_clear_button_pressed()
	
func _refresh_all_containers():
	SignalBus.emit_signal("container_refresh_remove")
	_populate_commands_list()


func _create_sound_command_dict() -> Dictionary:
	var snd_cmd_dict: Dictionary = {
		"command_name" : command_name_holder,
		"file_name" : soundfile_name_holder,
		"permission" : permission_flag_holder,
		"volume" : command_volume_holder
	}
	print("savedict: ", snd_cmd_dict)
	return snd_cmd_dict

func _on_clear_button_pressed() -> void:
	command_name_holder = ""
	SoundFileOptionButton.select(0)
	command_volume_holder = DEFAULT_VOLUME
	CommandVolumeSlider.value = command_volume_holder
	PermissionsOptionButton.select(0)
	ChangeVolumeButton.show()
	CommandVolumeSlider.hide()
	CommandNameLineEdit.clear()
	
func _on_volume_changed(value) -> void:
	command_volume_holder = int(value)

func _on_change_volume_pressed() -> void:
	ChangeVolumeButton.hide()
	CommandVolumeSlider.show()

func _on_folder_button_pressed() -> void:
	print(ProjectSettings.globalize_path(FileManager.user_sound_file_path))
	var error : int = OS.shell_open(ProjectSettings.globalize_path(FileManager.user_sound_file_path))
	if error != OK:
		print("Error #: ", error)
		if error == ERR_FILE_NOT_FOUND:
			print("Folder missing, attempting folder creation")
			FileManager.create_new_directory(FileManager.user_sound_file_path)
			var error2 :int = OS.shell_open(ProjectSettings.globalize_path(FileManager.user_sound_file_path))
			if error2 != OK:
				push_error(str("SOUND FILE FOLDER COULD NOT BE OPENED OR CREATED. ERROR: " +
				str(error)) + " ERROR2: "+ str(error2))
			else:
				print("Shell open ", OK)
	else:
		print("Shell open ", OK)

func _on_scan_button_pressed() -> void:
	_clear_soundfile_list()
	_add_all_sound_files_to_option_button()

func _clear_soundfile_list() -> void:
	soundfile_name_holder = ""
	soundfile_index_list.clear()
	SoundFileOptionButton.clear()

func _on_permission_option_selected(item_index) -> void:
	var item_id = PermissionsOptionButton.get_item_id(item_index)
	permission_flag_holder = item_id

func _on_sound_file_item_selected(item_index) -> void:
	soundfile_name_holder = str(soundfile_index_list[item_index])

func _on_command_name_text_changed(text) -> void:
	command_name_holder = text
	if command_name_holder != "":
		AddCommandButton.disabled = false
	elif command_name_holder == "":
		AddCommandButton.disabled = true
		
func _add_permissions_to_option_button() -> void:
	for key in PermissionFlag:
		PermissionsOptionButton.add_item(str(key), PermissionFlag[key])
	permission_flag_holder = PermissionsOptionButton.get_item_id(0)

func _fetch_list_of_sound_files() -> Array:
	var files_and_folders : Array = FileManager.get_dir_contents(FileManager.user_sound_file_path)
	var sound_files = files_and_folders[0]
	return sound_files
	
func _add_all_sound_files_to_option_button() -> void:
	var sound_files_list : Array = _fetch_list_of_sound_files()
	var index_number : int = 0
	for file in sound_files_list:
		var soundfile_name = (file.rsplit(str(FileManager.user_sound_file_path + "/")))
		SoundFileOptionButton.add_item(str(soundfile_name[1]))
		soundfile_index_list[index_number] = soundfile_name[1]
		print("item added to soundfile_index_list: ", soundfile_index_list[index_number])
		index_number += 1
	SoundFileOptionButton.select(0)
	if soundfile_index_list.is_empty():
		pass
	else:
		soundfile_name_holder = soundfile_index_list[0]
	
func _close_sound_command_menu() -> void:
	SignalBus.emit_signal("close_sound_menu")
	var settings_menu_resource : PackedScene = load("res://SettingsMenu.tscn")
	var settings_menu_instance = settings_menu_resource.instantiate()
	$"/root/Node".add_child(settings_menu_instance)
	get_parent().queue_free()

#The following code was scavanged from chat and will be reused to display existing commands
func _put_SoundCommandPanel(cmd_data) -> void:
	var sound_command_listing_node : Control = preload("res://SoundCommandListing.tscn").instantiate()
	var bottom : bool = $SoundCommandPanel/ScrollContainer.scroll_vertical == $SoundCommandPanel/ScrollContainer.get_v_scroll_bar().max_value - $SoundCommandPanel/ScrollContainer.get_v_scroll_bar().size.y
	sound_command_listing_node.set_sound_command_listing(cmd_data)
	$SoundCommandPanel/ScrollContainer/SoundCommandsList.add_child(sound_command_listing_node)
#	$SoundCommandPanel/ScrollContainer/SoundCommandPanelMessagesContainer.add_child(sound_command_listing_node)
	get_tree().get_frame()
	if (bottom):
		$SoundCommandPanel/ScrollContainer.scroll_vertical = $SoundCommandPanel/ScrollContainer.get_v_scroll_bar().max_value
