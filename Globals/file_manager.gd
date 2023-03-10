extends Node

signal save_auth_data

const userpath: String = "user://gift"
const user_sound_file_path : String = "user://gift/user_sound_files"
const file_passkey : String = "thisisntthepasskeyfortheauthfilehahahah32r2369fhwn234wbeoghwu"
const config_file_path : String = "user://gift/user_config"


func get_dir_contents(rootPath: String) -> Array: #Returns two arrays, array[0] is all the files, while array[1] is all of the folders.
	var files: Array = []
	var directories: Array = []
	var dir : DirAccess = DirAccess.open(rootPath)
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()
		_add_dir_contents(dir, files, directories)
	else:
		push_error("An error occurred when trying to access the path.")
	return [files, directories]

func _add_dir_contents(dir: DirAccess, files: Array, directories: Array) -> void:
	var file_name = dir.get_next()
#adds file and director names to an array for the get_dir_contents function.
	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			print("Found directory: %s" % path)
			var subDir : DirAccess = DirAccess.open(path)
			subDir.list_dir_begin()
			directories.append(path)
			_add_dir_contents(subDir, files, directories)
		else:
			print("Found file: %s" % path)
			files.append(path)
		file_name = dir.get_next()
	dir.list_dir_end()

func create_config_file(config_data) -> void:
	var config_dict = {"default_command_volume" : config_data.default_command_volume, "sound_commands" : config_data.commands_dict, "sound_command_interrupt" : config_data.sound_command_interrupt}
	create_new_directory(userpath)
	var config_file : FileAccess = FileAccess.open(config_file_path, FileAccess.WRITE)
	var error : int = FileAccess.get_open_error()
	if error == OK:
		config_file.store_var(config_dict, true)
		config_file.close()
	else:
		push_error(str("Error creating config file, open error number: " + str(error)))
		
func create_new_directory(dir_path: String) -> void: var _dir = DirAccess.make_dir_absolute(dir_path)

func check_for_file(file: String) -> bool:
	var files_and_directories: Array = get_dir_contents(userpath)
	for file_being_checked in files_and_directories[0]:
		if file_being_checked == file:
			print("file found")
			return true
	print("no file found")
	return false

func remove_file(filepath) -> void:
	print("Attempting file removal: ", filepath)
	var file : DirAccess = DirAccess.open(filepath)
	file.remove(filepath)

