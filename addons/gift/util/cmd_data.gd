extends RefCounted
class_name CommandData

var func_ref : Callable
var permission_level : int
var sound_file : String
var volume : int
var max_args : int
var min_args : int
var where : int


func _init(f_ref : Callable, perm_lvl : int,  mx_args : int, mn_args : int, whr : int, snd_file: String, vlm : int):
	func_ref = f_ref
	permission_level = perm_lvl
	sound_file = snd_file
	volume = vlm
	max_args = mx_args
	min_args = mn_args
	where = whr
	print("initialising command data: ", func_ref, " sound_file: ", sound_file )
