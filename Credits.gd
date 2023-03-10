extends Popup


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Button.connect("pressed", Callable(self,"_html_button_pressed"))
	name = "CreditsPopup"
	
func _html_button_pressed():
	OS.shell_open("https://github.com/issork/gift")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
