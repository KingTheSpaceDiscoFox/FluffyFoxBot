extends Button

@onready var Gift_Node = $"../../../Gift"
@onready var Chat_Line : LineEdit = $"../LineEdit"

func _pressed():
	Gift_Node.chat(Chat_Line.text)
	Chat_Line.clear()
