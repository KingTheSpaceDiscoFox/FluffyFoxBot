extends Control

@onready var RemoveChannelButton : Button = $CenterContainer/VBoxContainer/OAuthContainer/RemoveChannelButton
@onready var ChannelLine : LineEdit = $CenterContainer/VBoxContainer/OAuthContainer/ChannelLineEdit
@onready var TokenButton : Button = $CenterContainer/VBoxContainer/HeaderHbox/TokenButton
@onready var AddChannelButton : Button = $CenterContainer/VBoxContainer/OAuthContainer/AddChannelButton
@onready var TargetChannelOption : OptionButton = $CenterContainer/VBoxContainer/HBoxContainer2/TargetChannelOption
@onready var Close : Button = $CenterContainer/VBoxContainer/HBoxContainer/Close
@onready var Gift_Node = $"/root/Node/Gift"

var target_channel : String = ""
var channelname_holder: String = ""

func _ready():
	channelname_holder = Gift_Node.target_channel
	_add_channel()
	Close.connect("pressed", Callable(self,"_on_closed_pressed"))
	RemoveChannelButton.connect("pressed",Callable(self,"_remove_channel"))
	TokenButton.connect("pressed",Callable(self,"_retry_token_fetch"))
	ChannelLine.connect("text_changed",Callable(self,"_on_channel_text_changed"))
	AddChannelButton.connect("pressed",Callable(self,"_add_channel"))
	TargetChannelOption.connect("item_selected", Callable(self,"_Option_Button_Item_Selected"))
	$Panel.position = $CenterContainer.position
	
func _Option_Button_Item_Selected(index):
	target_channel = TargetChannelOption.get_item_text(index)
	_change_target_channel()
	
func _change_target_channel():
	SignalBus.emit_signal("change_target_channel", target_channel)

func _on_closed_pressed():
	ChannelLine.clear()
	var Settings_Menu_Resource : PackedScene = load("res://SettingsMenu.tscn")
	var Settings_Menu_Instance = Settings_Menu_Resource.instantiate()
	$"/root/Node".add_child(Settings_Menu_Instance)
	queue_free()
	
func _add_channel():
	if _filter_bad_channel_names():
		pass
	else:
		channelname_holder = ""
		ChannelLine.clear()
		return
	var item_number : int = 0
	while item_number < TargetChannelOption.item_count:
		var check_name : String = TargetChannelOption.get_item_text(item_number)
		if channelname_holder == check_name:
			print("Name already in list")
			return
		item_number = item_number + 1
	TargetChannelOption.add_item(channelname_holder)

	if TargetChannelOption.item_count == 1:
		target_channel = channelname_holder
		SignalBus.emit_signal("change_target_channel", target_channel)
	ChannelLine.clear()
	channelname_holder = ""
	
func _remove_channel():
	SignalBus.emit_signal("remove_channel_from_channel_list", channelname_holder)
	ChannelLine.clear()
	
func _on_channel_text_changed(text) -> void:
	channelname_holder = text
	
func _retry_token_fetch() -> void:
	SignalBus.emit_signal("retry_token_fetch")

func _populate_options_list(channels : Array):
	if channels != null: for channel in channels: TargetChannelOption.add_item(channel)

func _filter_bad_channel_names()->bool:
	var bad_symbols_check : Array = ["!","<",">",",",".","@","#","$","%","^","&","*","(",")",":",":",",","|","\"","\\","=","+","-","/","`","~"]
	var is_username_kosher : bool = false
	for bad_symbol in bad_symbols_check:
		if channelname_holder.contains(bad_symbol):
			return is_username_kosher
	if channelname_holder.begins_with(" "):
		return is_username_kosher
	if channelname_holder == "":
		return is_username_kosher
	is_username_kosher = true
	return is_username_kosher
