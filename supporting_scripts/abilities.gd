## This script handles all the code for abilities
extends Node


var rng = Global.rng
var ItemEffects = preload("res://supporting_scripts/item_effects.gd")
var item_effects = ItemEffects.new()
var Stat = Global.Stat

var ability_name: String = ""
var requirements: Dictionary = {AbilityProps.COOLDOWN:0,AbilityProps.MP_COST:0,AbilityProps.HP_COST:0,AbilityProps.ITEM_COST:null}
var description: String = "[ability description here]"

enum AbilityProps {
	COOLDOWN,
	MP_COST,
	HP_COST,
	ITEM_COST
}


func _init(abi_name:String=ability_name, reqs:Dictionary=requirements, desc:String=description):
	ability_name=abi_name
	requirements=reqs
	description=desc

## Performs the ability against the target character
func execute_ability(user:GameCharacter, ability_name:String="", tgt:GameCharacter=null, item_name:String=""):
	Global.battle_log.append(str("--\n"))
	match ability_name:
		"attack":
			if tgt==null:
				print("  error in function 'Abilities.execute_ability(",user,ability_name,tgt,")' -- no target for the attack")
			else:
				Global.battle_log.append(str(user.character_name," attacks!"))
				var roll_range = user.get_stat(Stat.ACC) + tgt.get_stat(Stat.EVADE)
				var attack_roll = rng.randi_range(1, roll_range)
				if attack_roll > user.get_stat(Stat.EVADE):
					Global.battle_log.append(str(user.character_name," misses!"))
				else:
					#calculate damage dealt
					var dmg_dealt = user.get_stat(Stat.DMG) + rng.randi_range(0,user.get_stat(Stat.DMG))
					var dmg_resisted = tgt.get_stat(Stat.DMG_REDUC)
					
					var net_dmg = dmg_dealt - dmg_resisted
					Global.battle_log.append(str(user.character_name," deals ",net_dmg," damage! (",dmg_dealt," dealt - ",dmg_resisted," reduced)"))
					#Apply damage (ensure "negative" damage isn't applied if armor completely blocks attack)
					tgt.curr_hp -= net_dmg if net_dmg > 0 else 0
		"guard":
			print("BEFORE guarding, character ",user.character_name," has ",user.get_stat(Stat.EVADE)," evasion, and ",user.get_stat(Stat.DMG_REDUC)," armor.")
			Global.battle_log.append(str(user.character_name," is guarding!"))
			user.guarding=true
			print("AFTER guarding, character ",user.character_name," has ",user.get_stat(Stat.EVADE)," evasion, and ",user.get_stat(Stat.DMG_REDUC)," armor.")
		
		"Power Attack":
			Global.battle_log.append(str(user.character_name," executes a Power Attack!"))
			if tgt==null:
				print("  error in function 'Abilities.execute_ability(",user,ability_name,tgt,")' -- no target for the attack")
			else:
				Global.battle_log.append(str("[type]",user.character_name," attacks!"))
				var roll_range = user.get_stat(Stat.ACC)-2 + tgt.get_stat(Stat.EVADE)
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
		
		"Lightning Spark":
			Global.battle_log.append(str(user.character_name, " casts Lightning Spark!"))
			var dmg_dealt = user.get_stat(Stat.SPEC_DMG)*3 + rng.randi_range(0,user.get_stat(Stat.SPEC_DMG)*3)
			Global.battle_log.append(str("Thundering cracks resound as ",user.character_name,"'s sparks strike for ",dmg_dealt," damage!"))
			
			tgt.curr_hp -= dmg_dealt if dmg_dealt > 0 else 0
		
		"Trip":
			Global.battle_log.append(str(user.character_name, " attempts a takedown!"))
			
			
		"use_item":
			if (item_name == ""):
				print("ERROR in 'use_item' in abilities.gd: ability invoked, but no valid item name found")
			
			if item_name not in user.item_belt:
				print("ERROR in 'use_item' in abilities.gd: use_item invoked, but item doesn't exist in user's item belt")
			
			else:
				item_effects.use_item(user, item_name, tgt)
		_:
			print("MSG: Abilities.execute_ability(): No script found for specified ability?")
		
	## Apply costs to using specified ability (if applicable)
	if ability_name in user.unique_abilities.keys():
		var reqs = get_ability_requirements(ability_name)
		user.unique_abilities[ability_name] = reqs[AbilityProps.COOLDOWN]
		## debit MP/HP costs (if applicable)
		user.curr_hp = clamp(user.curr_hp-reqs[AbilityProps.HP_COST],0,user.get_stat(Stat.MAX_HP))
		user.curr_mp = clamp(user.curr_mp-reqs[AbilityProps.MP_COST],0,user.get_stat(Stat.MAX_MP))
		


func get_ability_requirements(ability:String):
	match ability:
		"Power Attack":
			return {AbilityProps.COOLDOWN:3,AbilityProps.MP_COST:0,AbilityProps.HP_COST:0,AbilityProps.ITEM_COST:null}
		"Trip":
			return {AbilityProps.COOLDOWN:3,AbilityProps.MP_COST:0,AbilityProps.HP_COST:0,AbilityProps.ITEM_COST:null}
		"Lightning Spark":
			return {AbilityProps.COOLDOWN:2,AbilityProps.MP_COST:2,AbilityProps.HP_COST:0,AbilityProps.ITEM_COST:null}
		_:
			pass
		



func get_ability_description(ability:String):
	var desc = ""
	match ability:
		"Power Attack":
			desc = "-- POWER ATTACK --\n \
				Cooldown: 2 turns \n \
				Performs an attack with a -2 accuracy penalty.  On hit, it deals 25% more damage."
		"Lightning Spark":
			desc = "-- LIGHTNING SPARK --\n \
				MP Cost: 2 \n \
				Tiny sparks of lightning shoot forth from the caster, dealing damage based on the user's intelligence."
	return desc


## Applies the cost of using an ability to a specific character
func debit_ability_costs(ability:String):
	var costs=get_ability_requirements(ability)
	for cost in costs:
		match cost:
			AbilityProps.COOLDOWN:
				pass
