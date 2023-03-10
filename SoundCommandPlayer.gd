extends AudioStreamPlayer

var sound_command_queue = []
var sound_command_non_interrupt : bool = false
var sound_command_playing : bool = false
var last_sound_command = Time.get_ticks_msec()
var master_sound_command_volume : float = 100

const maximum_volume: int = 100
const minimum_volume: int = 0

@export var sound_command_timemout_ms: int = 1000
@onready var FluffBot = get_node("/root/Node/FluffBot") 

func _ready()->void:
	SignalBus.connect("play_sound_file",Callable(self,"_add_sound_file_to_queue"))
	SignalBus.connect("on_command_interrupt_button_pressed",Callable(self,"_on_command_interrupt_button_pressed"))
	SignalBus.connect("return_sound_command_non_interrupt",Callable(self,"_return_sound_command_non_interrupt"))
	SignalBus.connect("master_volume_changed",Callable(self,"_master_volume_changed"))
	SignalBus.connect("return_master_volume",Callable(self,"_return_master_volume"))
	SignalBus.connect("skip_sound_command",Callable(self,"_skip_sound_command"))
	SignalBus.connect("clear_sound_command_queue",Callable(self,"_clear_sound_command_queue"))
	self.connect("finished",Callable(self,"_sound_file_finished"))

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if sound_command_non_interrupt == true:
		if (!sound_command_queue.is_empty() && (last_sound_command + sound_command_timemout_ms <= Time.get_ticks_msec()) && sound_command_playing == false):
			_play_sound_file(sound_command_queue.pop_front())
			last_sound_command = Time.get_ticks_msec()
	elif (!sound_command_queue.is_empty() && sound_command_non_interrupt == false):
		_play_sound_file(sound_command_queue.pop_front())

func _skip_sound_command():
	self.stop()

func _clear_sound_command_queue():
	sound_command_queue.clear()

func _return_master_volume():
	return master_sound_command_volume

func _master_volume_changed(new_value):
	master_sound_command_volume = new_value

func _on_command_interrupt_button_pressed():
	if sound_command_non_interrupt == false:
		sound_command_non_interrupt = true
		print("interrupt: ", sound_command_non_interrupt)
	else:
		sound_command_non_interrupt = false
		print("interrupt: ", sound_command_non_interrupt)
		
func _add_sound_file_to_queue(cmd_info):
	if sound_command_non_interrupt == true:
		sound_command_queue.append(cmd_info)
	else:
		_play_sound_file(cmd_info)

func _play_sound_file(cmd_info: CommandInfo)->void:
	sound_command_playing = true
	var volume : float = cmd_info.volume
	var sound_file_path : String = str(FileManager.user_sound_file_path + "/" + cmd_info.sound_file)
	var realpath : String =  ProjectSettings.globalize_path(sound_file_path)
	var play_volume : float  = linear_to_db((volume + (master_sound_command_volume - 100)) / 100)
	stream = _loadfile(realpath)
	set_volume_db(play_volume)
	play()
#	self.playing = true
	print("sound file played: ", sound_file_path, " realpath: ", realpath, " at volume: ", play_volume)

func _loadfile(filepath):
	var file : FileAccess = FileAccess.open(filepath, FileAccess.READ)
	var bytes = file.get_buffer(file.get_length())
	if filepath.ends_with(".mp3"):
		var newstream = AudioStreamMP3.new()
		newstream.loop = false
		newstream.data = bytes
		return newstream
	elif filepath.ends_with(".wav"):
		var newstream = AudioStreamWAV.new()
		newstream.loop = false
		newstream.data = bytes
		return newstream
	elif filepath.ends_with(".ogg"):
		var newstream = AudioStreamOggVorbis.new()
		newstream.loop = false
		newstream.data = bytes
		return newstream
	else:
		print ("ERROR: Wrong filetype or format")
	file.close()

func _sound_file_finished():
	sound_command_playing = false

func _return_sound_command_non_interrupt():
	return sound_command_non_interrupt
