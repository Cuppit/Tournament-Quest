extends Node
var Stat = Global.Stat

func use_item(user:GameCharacter, item_name:String="", tgt:GameCharacter=null):
	match item_name:
		"Healing Salve":
			Global.battle_log.append(str(user.character_name," uses a healing balm!"))
			var to_recover = tgt.get_stat(Stat.MAX_HP)/10
			tgt.curr_hp += to_recover
			Global.battle_log.append(str(tgt.character_name," recovered ",to_recover," health!"))
		
		"Useless Item":
			Global.battle_log.append(str(user.character_name," uses a useless item!"))
			Global.battle_log.append(str("...and nothing happened!"))
		_:
			print("MSG: Abilities.use_item(): No script found for that item name?")
		
	## Remove item from the character's item belt after using it
	## TODO 20250725: if items are ever used "from the inventory", determine method of 
	## consuming item after it's used.
	user.item_belt.erase(item_name)
	
