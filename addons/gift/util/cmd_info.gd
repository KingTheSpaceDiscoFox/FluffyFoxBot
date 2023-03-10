extends RefCounted
class_name CommandInfo

var sender_data : SenderData
var command : String
var whisper : bool
var sound_file: String
var volume : int

func _init(sndr_dt, cmd, whspr, snd_file, vlm):
	sender_data = sndr_dt
	command = cmd
	whisper = whspr
	sound_file = snd_file
	volume = vlm
