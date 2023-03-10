extends Control

@onready var ShowChannelButton : Button = $Panel/Panel/VBoxContainer/ShowChannelButton
@onready var SoundCommandsButton : Button = $Panel/Panel/VBoxContainer/SoundCommandsButton
@onready var DisconnectButton : Button = $Panel/Panel/VBoxContainer/ConnectionContainer/DisconnectButton
@onready var ConnectButton : Button = $Panel/Panel/VBoxContainer/ConnectionContainer/ConnectButton
@onready var CreditsButton : Button = $Panel/Panel/VBoxContainer/CreditsButton
@onready var CloseButton : Button = $Panel/Panel/VBoxContainer/CloseButton

func _ready():
	ShowChannelButton.connect("pressed", Callable(self,"_on_auth_pressed"))
	SoundCommandsButton.connect("pressed", Callable(self,"_on_sound_commands_pressed"))
	DisconnectButton.connect("pressed", Callable(self,"_on_disconnect_pressed"))
	ConnectButton.connect("pressed", Callable(self,"_on_connect_pressed"))
	CreditsButton.connect("pressed", Callable(self,"_on_credits_pressed"))
	CloseButton.connect("pressed", Callable(self,"_on_close_pressed"))
	
func _on_auth_pressed():
	var authbox_resource : PackedScene = load("res://AuthBox.tscn")
	var authbox_instance = authbox_resource.instantiate()
	$"/root/Node".add_child(authbox_instance)
	queue_free()
	
func _on_sound_commands_pressed():
	var sound_commands_menu_resource : PackedScene = load("res://SoundCommandsMenu.tscn")
	var sound_commands_menu_instance = sound_commands_menu_resource.instantiate()
	get_parent().add_child(sound_commands_menu_instance)
	queue_free()

func _on_disconnect_pressed():
	pass
	
func _on_connect_pressed():
	pass

func _on_credits_pressed():
	var credits_resource : PackedScene = load("res://Credits.tscn")
	var credits_scene : Popup = credits_resource.instantiate()
	$"/root/Node".add_child(credits_scene)
	credits_scene.connect("popup_hide", Callable(self,"_credits_popup_hide"))
	credits_scene.position = $"/root/Node".size/2.5
	self.visible = false

func _credits_popup_hide():
	self.visible = true

func _on_close_pressed():
	queue_free()
