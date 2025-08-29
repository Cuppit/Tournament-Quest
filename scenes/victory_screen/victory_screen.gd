extends Control



var player:GameCharacter = GameCharacter.new()

func _ready():
	var params = GGT.get_current_scene_data().params
	if "char_to_manage" in params.keys():
		player = params.char_to_manage
	
	
