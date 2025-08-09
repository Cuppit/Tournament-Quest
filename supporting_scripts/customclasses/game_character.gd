extends Node

class_name GameCharacter

var Stat = Global.Stat

enum InvType{
	ITEM,
	WEAPON,
	ARMOR,
	ACCESSORY,
}

enum Attitude {
	NEUTRAL,  ## When an enemy is exhibiting their normal behavior
	AGGRESSIVE, ## When an enemy is taking up an aggressive posture, attempting to use a strong attack
	DEFENSIVE, ## When an enemy is taking up a defensive posture
	FAINTING, ## When below a certain HP threshold, usually, 1/3rd, an enemy has to be at to exhibit close to being defeated
	DEFEATED ## Used to indicate 
}

## Utility variables
var rng = Global.rng

## STAT_MULTIPLIER: This is a constant tweaked experimentally to try and balance
## the impact a character's stats have on how effectively powerful they are.
## It's incorporated into functions like "max HP".   
const STAT_MULTIPLIER = 54  
## percent HP a character needs to be at in order to express an attitude of "fainting"
var fainting_threshold = 0.33

var character_name = "None"

signal guarding_state_changed
var guarding:bool = false:
	set(guard_state):
		guarding = guard_state
		emit_signal('guarding_state_changed',guarding)
		

## Only these ones are the base stats
var base_stats={Stat.STR:1,Stat.DEX:1,Stat.CON:1,Stat.INT:1,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1}

## The current attitude of this character (neutral by default)
var current_attitude = Attitude.NEUTRAL

## The types of attitude the character tends to exhibit at the start of a turn
var personality = {Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1}

## Custom messages used to describe character behavior while in a particular attitude
var attitude_msgs = {Attitude.NEUTRAL:["neutralmsg1","neutralmsg2"]\
					 ,Attitude.AGGRESSIVE:["aggressivemsg1","aggressivemsg2"]\
					 ,Attitude.DEFENSIVE:["defensivemsg1","defensivemsg2"]\
					 ,Attitude.FAINTING:["faintingmsg1","faintingmsg2"]\
					 ,Attitude.DEFEATED:["deadmsg1","deadmsg2"]}

signal hp_updated(new_hp)
var curr_hp:int = 1:
	set(new_hp):
		curr_hp = new_hp
		emit_signal('hp_updated', curr_hp)
		

signal mp_updated(new_mp)
var curr_mp:int = 1:
	set(new_mp):
		curr_mp = new_mp
		emit_signal('mp_updated', curr_mp)

signal item_belt_updated
var item_belt:Array = []

signal level_changed(new_lvl)
var current_level:int = 1:
	set(new_lvl):
		current_level = new_lvl
		emit_signal('level_updated', current_level)
		
	
signal xp_changed(new_xp)	
var experience_points:int = 0:
	set(new_xp):
		experience_points = new_xp
		emit_signal('xp_changed', experience_points)
	
	
var inventory = {InvType.ITEM:{},InvType.WEAPON:{},InvType.ARMOR:{},InvType.ACCESSORY:{}}

signal money_changed(new_money)
var money:int = 0:
	set(new_money):
		money = new_money
		emit_signal('money_changed', money)


signal equipped_weapon_changed(new_weapon)
var equipped_weapon:String = "None":
	set(new_weapon):
		equipped_weapon = new_weapon
		emit_signal('equipped_weapon_changed',equipped_weapon)


signal equipped_armor_changed(new_armor)
var equipped_armor:String = "None":
	set(new_armor):
		equipped_armor = new_armor
		emit_signal('equipped_armor_changed',equipped_armor)
		
		
signal equipped_accessory_changed(new_acc)
var equipped_accessory:String = "None":
	set(new_acc):
		equipped_accessory = new_acc
		emit_signal('equipped_weapon_changed',equipped_accessory)
		
		
## List of special abilities the character has access to
## Key: ability name
## Value: current number of turns remaining before cool
var unique_abilities = {}

var character_portrait = null ## To be used for determining character portrait
var description = "(default text block for descrtiption of character)"
var strategy = "(Default text block for strategy related to character)"


## Utility function, gets all equipment bonuses to the specified stat.
func get_equip_stat_bonuses(stat:Global.Stat):
	var total = 0
	total += Global.weaponDB.get(equipped_weapon,Global.weaponDB["None"]).stat_mods.get(stat,0) if equipped_weapon != "None" else 0
	total += Global.armorDB.get(equipped_armor,Global.armorDB["None"]).stat_mods.get(stat,0) if equipped_armor != "None" else 0
	total += Global.accessoryDB.get(equipped_accessory,Global.accessoryDB["None"]).stat_mods.get(stat,0) if equipped_accessory != "None" else 0
	return total


func get_stat(toget:Global.Stat):
	#print("getting stat: ",Stat.keys()[toget]," (enum val: ",toget,")")
	var toreturn = get_equip_stat_bonuses(toget)
	
	## If trying to get a base stat, add up the base stat plus any equipment bonuses
	## TODO 20250807: when buffs/debuffs/passive abilities get implemented, be sure
	## to factor that into the get_stat function
	if toget in [Stat.STR, Stat.DEX, Stat.CON, Stat.INT, Stat.WIS, Stat.CHA, Stat.BELT_CAP]:
		toreturn += base_stats[toget]

	match toget:
		Stat.MAX_HP:
			toreturn += get_stat(Stat.CON)*STAT_MULTIPLIER
		Stat.MAX_MP:
			toreturn += get_stat(Stat.INT)*2
		Stat.ACC:
			toreturn += 2*get_stat(Stat.DEX) + get_stat(Stat.STR)
		Stat.EVADE:
			toreturn += get_stat(Stat.DEX)
		Stat.DMG:
			toreturn += 2*get_stat(Stat.STR) + get_stat(Stat.DEX)
		Stat.DMG_REDUC:
			toreturn += get_stat(Stat.CON)/2 + get_stat(Stat.STR)/4
		_:
			null 
	return toreturn if toreturn > 1 else 1


## GAIN and REMOVE item functions, perhaps better worded as ADD and DELETE item
## 
func gain_item(item_name:String="", item_type:InvType = InvType.ITEM, equip_to_belt=true):
	if item_name == "":
		print ("ERROR in GameCharacter.gain_item(",item_name,"): empty string passed (or no name specified)")
		return
	var inv = inventory[item_type]

	## First, attempt to add to the character's item belt 
	if equip_to_belt and (item_type==InvType.ITEM):
		if len(item_belt) < get_stat(Stat.BELT_CAP):
			item_belt.append(item_name)
			emit_signal("item_belt_updated")
			return ## Nothing else to do, the item has been properly gained at this point

	print('**NOTICE in GameCharacter(',self,"': '",character_name,').gain_item(',item_name,"): CANT add to item belt, item belt is full!  Attempting to add to inventory instead: ")
	if inv.has(item_name):
		if typeof(inv[item_name]) == TYPE_INT:
			inv[item_name] = (inv[item_name]+1) if inv[item_name] < 1 else 1 ## if somehow the item count became negative, this fixes the issue 
		else:
			print('**ERROR IN GameCharacter(',self,"': '",character_name,').gain_item(',item_name,"): Inventory count for item is not an integer!?!?")
	else:
		inv[item_name] = 1


func remove_item(item_name:String="", item_type:InvType = InvType.ITEM):
		if item_name == "":
			print ("ERROR in GameCharacter.remove_item(",item_name,"): empty string passed")
		var inv = inventory[item_type]
		if inv.has(item_name):
			if typeof(inv[item_name]) == TYPE_INT:
				if inv[item_name] > 1:
					inv[item_name] -= 1
				else:
					inv.erase(item_name)
			else:
				print ("ERROR in GameCharacter.remove_item(",item_name,"): quantity is not an integer")



## Used for selecting any pieces of data dependent on a 
## weighted outcome.
func choose_weighted_outcome(outcomes:Dictionary):
	var weights = outcomes.values()
	var total_weight = 0
	for w in weights:
		total_weight += w
	var rand_choice = rng.randi_range(1, total_weight)
	var cumulative_weight = 0
	var selection = null
	for outcome in outcomes.keys():
		cumulative_weight += outcomes[outcome]
		if rand_choice <= cumulative_weight:
			selection = outcome
			break
	return selection

## Returns an appropriate battle message based on the 
## character's current attitude.
func get_battle_msg():
	var msg = rng.randi_range(0,len(attitude_msgs[current_attitude])-1)
	return attitude_msgs[current_attitude][msg]

## Utility function used primarily by the "CharacterManagement.tscn" UI to 
## update contents of the string
func get_stats_str_for_cha_mgmt_scr() -> String:
	var toreturn:String = ""
	toreturn = str(current_level,"\n",\
					money,"\n",\
					experience_points,"\n",\
					get_stat(Stat.STR),"\n",\
					get_stat(Stat.DEX),"\n",\
					get_stat(Stat.CON),"\n",\
					get_stat(Stat.INT),"\n",\
					get_stat(Stat.WIS),"\n",\
					get_stat(Stat.CHA),"\n",\
					get_stat(Stat.ACC),"\n",\
					get_stat(Stat.DMG),"\n",\
					get_stat(Stat.EVADE),"\n",\
					get_stat(Stat.DMG_REDUC))
	
	return toreturn


func _init(cname:String="None"  \
			, stats:Dictionary = base_stats \
			, wpn:String = "None" \
			, amr:String = "None" \
			, access:String = "None" \
			, person:Dictionary = personality \
			, att_msgs:Dictionary = attitude_msgs \
			, uniq_abil:Dictionary = unique_abilities \
			, muns:int = 0 \
			, xp:int = 0 \
			, char_port = null \
			, desc:String = "default description text block" \
			, strat:String = "default strategy text block" \
			, invent = inventory
		):
	character_name=cname
	base_stats = stats
	equipped_weapon = wpn
	equipped_armor = amr
	equipped_accessory = access
	personality = person
	attitude_msgs = att_msgs
	unique_abilities = uniq_abil
	money = muns
	experience_points = xp
	character_portrait = char_port
	description = desc
	strategy = strat
	inventory = invent
	
	curr_hp = get_stat(Stat.MAX_HP)
	curr_mp = get_stat(Stat.MAX_MP)

	
func _ready():
	print("in GameCharacter._ready() for ",self,"(",character_name,"):")
	print("Setting curr_hp to get_stat(Stat.MAX_HP) which is: ",get_stat(Stat.MAX_HP))
	curr_hp = get_stat(Stat.MAX_HP)
	curr_mp = get_stat(Stat.MAX_MP)
	

## Creates and returns a complete copy of this character
## TODO 20250808: proper copying of characters from the database
## to new character objects was a problem in the last iteration of the game.
## This function has not yet been tested.  Ensure it works
func copy_character(to_copy:GameCharacter):
	var toreturn = GameCharacter.new(to_copy.character_name \
								, to_copy.base_stats.duplicate(true) \
								, to_copy.equipped_weapon \
								, to_copy.equipped_armor \
								, to_copy.equipped_accessory \
								, to_copy.personality.duplicate(true) \
								, to_copy.attitude_msgs.duplicate(true) \
								, to_copy.unique_abilities.duplicate(true) \
								, to_copy.money \
								, to_copy.experience_points \
								, to_copy.character_portrait \
								, to_copy.description \
								, to_copy.strategy \
								, to_copy.inventory.duplicate(true)
								)
	return toreturn
