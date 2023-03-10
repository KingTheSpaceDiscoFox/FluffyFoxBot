extends Resource

class_name ConfigData

@export var sound_command_interrupt: bool
@export var default_command_volume: int
@export var commands_dict : Dictionary = {}


func _init(snd_cmd_int: bool, dft_cmd_vol: int, cmd_dict: Dictionary):
	sound_command_interrupt = snd_cmd_int
	default_command_volume = dft_cmd_vol
	commands_dict = cmd_dict.duplicate()
