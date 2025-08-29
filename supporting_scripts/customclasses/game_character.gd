extends Node

class_name GameCharacter

const DEFAULT_ACTION_PREFS = { Attitude.NEUTRAL:{"attack":5,"guard":1}\
							,Attitude.AGGRESSIVE:{"attack":1,"guard":0}\
							,Attitude.DEFENSIVE:{"guard":1}\
							,Attitude.FAINTING:{"attack":1,"guard":1}}



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
const STAT_MULTIPLIER = 27  
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

var action_preferences = { Attitude.NEUTRAL:{"attack":5,"guard":1}\
							,Attitude.AGGRESSIVE:{"attack":1,"guard":0}\
							,Attitude.DEFENSIVE:{"guard":1}\
							,Attitude.FAINTING:{"attack":1,"guard":1}}



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
		emit_signal('equipped_accessory_changed',equipped_accessory)
		
		
## List of special abilities the character has access to
## Key: ability name
## Value: current number of turns remaining before cool
var unique_abilities = {}

var character_portrait
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
			toreturn += 2*get_stat(Stat.INT) + int(get_stat(Stat.WIS)/2)
		Stat.ACC:
			toreturn += 2*get_stat(Stat.DEX) + get_stat(Stat.STR)
		Stat.EVADE:
			toreturn += get_stat(Stat.DEX)
		Stat.DMG:
			toreturn += 2*get_stat(Stat.STR) + get_stat(Stat.DEX)
		Stat.DMG_REDUC:
			toreturn += get_stat(Stat.CON)/2 + get_stat(Stat.STR)/4
		Stat.SPEC_ACC:
			toreturn += 2*get_stat(Stat.CHA) + get_stat(Stat.INT)
		Stat.SPEC_DMG:
			toreturn += 2*get_stat(Stat.INT) + get_stat(Stat.WIS)
		Stat.SPEC_DMG_REDUC:
			toreturn += get_stat(Stat.WIS)/2 + get_stat(Stat.INT)/4
		Stat.SPEC_EVADE:
			toreturn += get_stat(Stat.CHA)
		_:
			null 
	if toget in [Stat.EVADE,Stat.DMG_REDUC] and guarding:
		print ("--in GameCharacter.get_stat(): SUCCESSFULLY detected guarding is on!")
		return int((toreturn*4)/3) if int((toreturn*4)/3)> 2 else 2
	return toreturn if toreturn > 1 else 1

## Returns the level this character is currently at
## FORMULA FOR CHARACTER LEVEL: sum of all 6 base stats (STR, DEX, CON, INT, WIS, CHA)
func get_char_lvl() -> int:
	var toreturn = 0
	for stat in base_stats.keys():
		toreturn += base_stats[stat] if stat != Global.Stat.BELT_CAP else 0
	return toreturn - 5

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

	print('**NOTICE in GameCharacter(',self,"': '",character_name,').gain_item(',item_name,"): Not adding item to belt(either because its full, or because told not to)  Attempting to add to inventory instead: ")
	if inv.has(item_name):
		if typeof(inv[item_name]) == TYPE_INT:
			print('**DEBUG in GameCharacter(',self,"': '",character_name,').gain_item(',item_name,"): since item already exists in inventory, we simply add 1 to the number of that item held. ")
			#inv[item_name] = (inv[item_name]+1) if inv[item_name] < 1 else 1 ## if somehow the item count became negative, this fixes the issue # <-- NOTE: this was causing issues, simpler incrementor seems to work fine however
			inv[item_name] += 1
			print('**DEBUG in GameCharacter(',self,"': '",character_name,').gain_item(',item_name,"): NEW VALUE IS: ",inv[item_name])
		else:
			print('**ERROR IN GameCharacter(',self,"': '",character_name,').gain_item(',item_name,"): Inventory count for item is not an integer!?!?")
	else:
		inv[item_name] = 1
	print("-- new state of character '",character_name,"'s inventory: ",inventory)


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

## Used to ensure items lost due to item belt shrinkage get replaced into the
## character's inventory
func manage_item_belt_state():
	if get_stat(Stat.BELT_CAP) < len(item_belt):
		while get_stat(Stat.BELT_CAP) < len(item_belt):
			gain_item(item_belt[-1])
			item_belt.erase(item_belt[-1])

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


func process_turn(ability_name="", target=null, item=""):
	guarding = false # Reset guarding status before processing turn
	if (ability_name == ""):
		print("No ability name passed, automatically deciding action for ",character_name,":")
		var selection = choose_weighted_outcome(action_preferences[current_attitude])
		if selection == "use_item":
			if len(item_belt)>0:
				item=item_belt[0]
		print("  **In ",character_name,"'s GameCharacter.process_turn(",ability_name,",",target,",",item,"): what happens when character tries to use this ability? SELECTION=",selection)
		if (not can_activate(selection, item)):
			## For now, enemy simply flips a coin to either attack or guard. TODO 20250819: make enemy default to a different likely ability instead of simply "guarding"
			
			selection = "guard" if rng.randi_range(1, 2) == 1 else "attack"
			print("  **In ",character_name,"'s GameCharacter.process_turn(",ability_name,",",target,",",item,"): character could NOT use the initial selection, new selection is:",selection)
		# 3) Execute the chosen ability
		if selection == "use_item" and item=="":
			if len(item_belt)>0:
				item=item_belt[0] ## Simply select the item at the top of the item belt. TODO 20250819: Make a more sophisticated method of determining what item on it's belt an enemy would choose based on its strategy.
			
		Abilities.execute_ability(self, selection, target, item)
		
		# 4) Choose a new attitude (and adjust attitude of defeated opponent, if applicable)
		if target != null:
			if target.curr_hp <= 0:
				target.current_attitude = Attitude.DEFEATED
		if curr_hp <= 0:
			current_attitude = Attitude.DEFEATED
		if curr_hp < int(get_stat(Stat.MAX_HP)*fainting_threshold):
			current_attitude = Attitude.FAINTING
		else:
			current_attitude = choose_weighted_outcome(personality)
	else:
		Abilities.execute_ability(self, ability_name, target, item)
		if target != null:
			if target.curr_hp <= 0:
				target.current_attitude = Attitude.DEFEATED

	
func decrement_cooldowns():
	for ability in unique_abilities.keys():
		unique_abilities[ability] -= 1
		if unique_abilities[ability] < 0:
			unique_abilities[ability] = 0


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


## Determines whether a specific ability may activate
func can_activate(ability:String, item_name:String=""):
	if ability in ["attack","guard"]:
		return true
		## In the future, there may be times when the basic abilities
		## might not be useable.  TODO 20250819: implement more sophisticated
		## checks to determine if basic things are useable.
		#-activator has enough resources to activate the ability
		#-There are no conditions that prevent the activator from using the ability (e.g. on cooldown)	
	
	if ability == "use_item":
		if item_name in item_belt:
			return true
		else:
			return false
	
	## If this ability is not listed in unique abilitiies this character possesses...
	if ability not in unique_abilities.keys():
		## don't use them.
		return false
	
	var reqs = Abilities.get_ability_requirements(ability)
	
	## Is the ability on cooldown?
	if unique_abilities[ability] > 0:
		return false 
	## Is there a mana cost involved, and can the character afford it?
	if reqs[Abilities.AbilityProps.MP_COST] > curr_mp:
		return false
	## is there an HP cost involved, and can the character pay it without dying?
	if  reqs[Abilities.AbilityProps.HP_COST] > curr_hp:
		return false
	## is there an item cost involved, and does the character have it on their belt?
	if reqs[Abilities.AbilityProps.ITEM_COST] != null:
		if reqs[Abilities.AbilityProps.ITEM_COST] not in item_belt:
			return false
	## if it passed all the tests, yes, the character can activate the ability.
	return true
	
## returns a string explaining impediments to using a specific ability based on 
## whether the character may use a unique ability
func get_abi_act_impediments_as_str(ability:String):
	var toreturn = ""
	var reqs = Abilities.get_ability_requirements(ability)
	if unique_abilities[ability] > 0:
		toreturn += str("(Cooldown: ",unique_abilities[ability], " turns)")
	
	if reqs[Abilities.AbilityProps.MP_COST] > curr_mp:
		toreturn += str("(Need ",reqs[Abilities.AbilityProps.MP_COST]," mana to use)")
	
	if reqs[Abilities.AbilityProps.HP_COST] > curr_hp:
		toreturn += str("(Need ",reqs[Abilities.AbilityProps.HP_COST]," health to use)")
	
	if (reqs[Abilities.AbilityProps.ITEM_COST] != null):
		toreturn += str("(Need ",reqs[Abilities.AbilityProps.ITEM_COST]," in belt to use)") if (reqs[Abilities.AbilityProps.ITEM_COST] not in item_belt) else null

	return toreturn




## TODO 20250811: Consider ramifications of adding character properties in the
## future, particularly considering how "character_db.gd" currently works
## (e.g. "hand-jamming" new entries).
func _init(cname:String="None"  \
			, stats:Dictionary = base_stats \
			, wpn:String = "None" \
			, amr:String = "None" \
			, access:String = "None" \
			, person:Dictionary = personality \
			, att_msgs:Dictionary = attitude_msgs \
			, act_prefs:Dictionary = action_preferences
			, uniq_abil:Dictionary = unique_abilities \
			, muns:int = 0 \
			, xp:int = 0 \
			, char_port = null \
			, desc:String = "default description text block" \
			, strat:String = "default strategy text block" \
			, invent = inventory \
			, belt=item_belt
		):
	character_name=cname
	base_stats = stats
	equipped_weapon = wpn
	equipped_armor = amr
	equipped_accessory = access
	personality = person
	attitude_msgs = att_msgs
	action_preferences = act_prefs
	unique_abilities = uniq_abil
	money = muns
	experience_points = xp
	character_portrait = char_port
	description = desc
	strategy = strat
	inventory = invent
	item_belt = belt
	
	curr_hp = get_stat(Stat.MAX_HP)
	curr_mp = get_stat(Stat.MAX_MP)
	
	item_belt_updated.connect(manage_item_belt_state)

func _ready():
	print("in GameCharacter._ready() for ",self,"(",character_name,"):")
	print("Setting curr_hp to get_stat(Stat.MAX_HP) which is: ",get_stat(Stat.MAX_HP))
	curr_hp = get_stat(Stat.MAX_HP)
	curr_mp = get_stat(Stat.MAX_MP)
	

## Creates and returns a complete copy of this character
## TODO 20250808: proper copying of characters from the database
## to new character objects was a problem in the last iteration of the game.
## This function has not yet been tested.  Ensure it works
func copy_character():
	var toreturn = GameCharacter.new(self.character_name \
								, self.base_stats.duplicate(true) \
								, self.equipped_weapon \
								, self.equipped_armor \
								, self.equipped_accessory \
								, self.personality.duplicate(true) \
								, self.attitude_msgs.duplicate(true) \
								, self.action_preferences.duplicate(true) \
								, self.unique_abilities.duplicate(true) \
								, self.money \
								, self.experience_points \
								, self.character_portrait \
								, self.description \
								, self.strategy \
								, self.inventory.duplicate(true)
								, self.item_belt.duplicate(true)
								)

	return toreturn
