extends Node
var Stat = Global.Stat

## Utility variables
var rng = Global.rng

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
			
		"Potion of Acid":
			Global.battle_log.append(str(user.character_name," threw a Potion of Acid!"))
			var roll_range = user.get_stat(Stat.ACC) + tgt.get_stat(Stat.EVADE)+1
			var attack_roll = rng.randi_range(1, roll_range)
			if attack_roll > user.get_stat(Stat.ACC):
				Global.battle_log.append(str(user.character_name," misses!"))
			else:
				#calculate damage dealt
				var dmg_dealt = user.get_stat(Stat.DMG) + rng.randi_range(0,user.get_stat(Stat.DMG))
				var powerattack_dmg = int(dmg_dealt/4)
				var dmg_resisted = tgt.get_stat(Stat.DMG_REDUC)
				var net_dmg = dmg_dealt+powerattack_dmg - dmg_resisted
				Global.battle_log.append(str(" HIT! ",user.character_name," added ",powerattack_dmg," damage to the attack, totalling ",net_dmg," damage! (",dmg_dealt," dealt - ",dmg_resisted," reduced)"))
				#Apply damage (ensure "negative" damage isn't applied if armor completely blocks attack)
				tgt.curr_hp -= net_dmg if net_dmg > 0 else 0
		_:
			print("MSG: Abilities.use_item(): No script found for that item name?")
			

		
	## Remove item from the character's item belt after using it
	## TODO 20250725: if items are ever used "from the inventory", determine method of 
	## consuming item after it's used.
	if Global.itemDB[item_name].consumable:
		user.item_belt.erase(item_name)
	
