## This script handles all the code for abilities

extends Node
var rng = Global.rng
var ItemEffects = preload("res://supporting_scripts/item_effects.gd")
var item_effects = ItemEffects.new()

enum AbilityProps {
	COOLDOWN,
	MP_COST,
	HP_COST,
	ITEM_COST
}

## Performs the ability against the target character
func execute_ability(user:GameCharacter, ability_name:String="", tgt:GameCharacter=null, item_name:String=""):
	Global.battle_log.append(str("--\n"))
	match ability_name:
		"attack":
			if tgt==null:
				print("  error in function 'Abilities.execute_ability(",user,ability_name,tgt,")' -- no target for the attack")
			else:
				Global.battle_log.append(str(user.character_name," attacks!"))
				var roll_range = user.get_accuracy() + tgt.get_evasion()
				var attack_roll = rng.randi_range(1, roll_range)
				if attack_roll > user.get_accuracy():
					Global.battle_log.append(str(user.character_name," misses!"))
				else:
					#calculate damage dealt
					var dmg_dealt = user.get_damage() + rng.randi_range(0,user.get_damage())
					var dmg_resisted = tgt.get_armor()
					
					var net_dmg = dmg_dealt - dmg_resisted
					Global.battle_log.append(str(user.character_name," deals ",net_dmg," damage! (",dmg_dealt," dealt - ",dmg_resisted," reduced)"))
					#Apply damage (ensure "negative" damage isn't applied if armor completely blocks attack)
					tgt.curr_health -= net_dmg if net_dmg > 0 else 0
		"guard":
			print("BEFORE guarding, character ",user.character_name," has ",user.get_evasion()," evasion, and ",user.get_armor()," armor.")
			Global.battle_log.append(str(user.character_name," is guarding!"))
			user.guarding=true
			print("AFTER guarding, character ",user.character_name," has ",user.get_evasion()," evasion, and ",user.get_armor()," armor.")
		
		"Power Attack":
			Global.battle_log.append(str(user.character_name," executes a Power Attack!"))
			if tgt==null:
				print("  error in function 'Abilities.execute_ability(",user,ability_name,tgt,")' -- no target for the attack")
			else:
				Global.battle_log.append(str(user.character_name," attacks!"))
				var roll_range = user.get_accuracy()-2 + tgt.get_evasion()
				var attack_roll = rng.randi_range(1, roll_range)
				if attack_roll > user.get_accuracy():
					Global.battle_log.append(str(user.character_name," misses!"))
				else:
					#calculate damage dealt
					
					var dmg_dealt = user.get_damage() + rng.randi_range(0,user.get_damage())
					var powerattack_dmg = int(dmg_dealt/4)
					var dmg_resisted = tgt.get_armor()
					
					var net_dmg = dmg_dealt+powerattack_dmg - dmg_resisted
					Global.battle_log.append(str(" HIT! ",user.character_name," added ",powerattack_dmg," damage to the attack, totalling ",net_dmg," damage! (",dmg_dealt," dealt - ",dmg_resisted," reduced)"))
					#Apply damage (ensure "negative" damage isn't applied if armor completely blocks attack)
					tgt.curr_health -= net_dmg if net_dmg > 0 else 0
		
		"use_item":
			if (item_name == ""):
				print("ERROR in 'use_item' in abilities.gd: ability invoked, but no valid item name found")
			
			if item_name not in user.item_belt:
				print("ERROR in 'use_item' in abilities.gd: use_item invoked, but item doesn't exist in user's item belt")
			
			else:
				item_effects.use_item(user, item_name, tgt)
		_:
			print("MSG: Abilities.execute_ability(): No script found for specified ability?")
		
	## Apply cooldown to specified ability (if applicable)
	if ability_name in user.unique_abilities.keys():
		user.unique_abilities[ability_name] = get_ability_requirements(ability_name)[AbilityProps.COOLDOWN]


func get_ability_requirements(ability:String):
	match ability:
		"Power Attack":
			return {AbilityProps.COOLDOWN:2,AbilityProps.MP_COST:0,AbilityProps.HP_COST:0,AbilityProps.ITEM_COST:null}
		_:
			pass


func get_ability_description(ability:String):
	var desc = ""
	match ability:
		"Power Attack":
			desc = "-- POWER ATTACK --\n \
				Cooldown: 2 turns \n \
				Performs an attack with a -2 accuracy penalty.  On hit, it deals 25% more damage."
	return desc
