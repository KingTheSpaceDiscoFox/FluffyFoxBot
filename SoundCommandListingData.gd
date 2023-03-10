extends Resource
class_name CommandListingData

var permission_level : int
var sound_file : String
var volume : int
var where : int
var command_name : String

func _init(cmd_nm: String,perm_lvl : int,snd_file: String,vlm : int,whr : int):
	command_name = cmd_nm
	permission_level = perm_lvl
	sound_file = snd_file
	volume = vlm
	where = whr
