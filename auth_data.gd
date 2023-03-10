extends Resource

class_name AuthData

@export var bot_username : String
@export var initial_channel : String
@export var oauth_token : String

func _init(username,channel,token):
	bot_username = username
	initial_channel = channel
	oauth_token = token
