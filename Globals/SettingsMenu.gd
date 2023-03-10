extends Control

onready var AuthButton = $Panel/Panel/VBoxContainer/ShowAuthButton
onready var CloseButton = $Panel/Panel/VBoxContainer/CloseButton
onready var SoundCommandButton = $Panel/Panel/VBoxContainer/SoundCommandsButton
onready var CommandsButton = $Panel/Panel/VBoxContainer/CommandsButton
onready var ConnectButton = $Panel/Panel/VBoxContainer/ConnectionContainer/ConnectButton
onready var DisconnectButton = $Panel/Panel/VBoxContainer/ConnectionContainer/DisconnectButton
onready var CreditsButton = $Panel/Panel/VBoxContainer/CreditsButton

var MasterVolume : int = 100

func _ready():
	CreditsButton.connect("pressed", self, "_credits_button_pressed")
	AuthButton.connect("pressed",self,"_show_auth_box")
	CloseButton.connect("pressed", self, "_close_settings")
	SoundCommandButton.connect("pressed", self, "_show_sound_commands_menu")
	ConnectButton.connect("pressed",self,"_connect_button_pressed")
	DisconnectButton.connect("pressed",self,"_disconnect_button_pressed")
	SignalBus.connect("discard_auth_changes",self,"_discard_auth_changes")
#	SignalBus.connect("discard_command_changes", self, "_discard_command_changes")
	SignalBus.connect("close_sound_menu",self,"_return_from_sound_command_menu")

func _credits_button_pressed():
	if get_node("/root/Node/Credits") == null:
		var creditsResource = preload("res://Credits.tscn").instance()
		get_parent().add_child(creditsResource)
	else:
		print("credits already open")
		get_node("/root/Node/Credits").visible = true
		
func _disconnect_button_pressed():
	SignalBus.emit_signal("disconnect_from_twitch")

func _connect_button_pressed():
	SignalBus.emit_signal("connect_to_twitch")

func _discard_sound_command_changes():
	pass

func _discard_command_changes():
	pass

func _discard_auth_changes():
	AuthButton.show()
	CloseButton.show()
	SoundCommandButton.show()
	CommandsButton.show()
	ConnectButton.show()
	DisconnectButton.show()
	
func _show_auth_box():
	AuthButton.hide()
	CommandsButton.hide()
	SoundCommandButton.hide()
	CloseButton.hide()
	DisconnectButton.hide()
	ConnectButton.hide()
	$Panel/Panel/VBoxContainer.add_child(load("res://AuthBox.tscn").instance())

func _close_settings():
	queue_free()

func _show_sound_commands_menu():
	DisconnectButton.hide()
	ConnectButton.hide()
	AuthButton.hide()
	CommandsButton.hide()
	SoundCommandButton.hide()
	CloseButton.hide()
	get_parent().add_child(load("res://SoundCommandsMenu.tscn").instance())

func _return_from_sound_command_menu():
	AuthButton.show()
	SoundCommandButton.show()
	CommandsButton.show()
	CloseButton.show()
	DisconnectButton.show()
	ConnectButton.show()
