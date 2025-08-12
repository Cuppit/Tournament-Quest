extends Node


## All of the base stats a character can have.
enum Stat {
	STR, DEX, CON, INT, WIS, CHA, BELT_CAP, ## <-- NOTE: These are all FUNDAMENTAL BASE stats
	MAX_HP,MAX_MP,ACC,EVADE,DMG,DMG_REDUC, ## <-- NOTE: These are FUNCTIONAL stats that are functions of the base stats
}

## Used as key value for choosing a specific opponent in the course of a scenario.
## Used by the Battle Select UI when choosing an opponent to fight, and by the 
## ScenarioDB to differentiate between options.
enum BattleChoice {
	OPPONENT1,OPPONENT2,OPPONENT3,
}

## Cleared before every battle.  Battle messages are logged as an array
## of strings that the battle UI pulls from regularly.   
var battle_log = [""]
signal battle_log_updated(battle_log)

var rng = RandomNumberGenerator.new()

var weaponDB = {}
var armorDB = {}
var accessoryDB = {}
var itemDB = {}
var characterDB = {}
var scenarioDB = {}

"""
TODO 20250804_2214
Note to self: consider implementing this database solution if a more robust
data solution is needed in the future: https://github.com/patchfx/gddb
"""

var TexturePreloadsScript = preload("res://supporting_scripts/texture_preloads.gd")
var CharacterDBScript = preload("res://supporting_scripts/databases/character_db.gd")
var WeaponDBScript = preload("res://supporting_scripts/databases/weapon_db.gd")
var ArmorDBScript = preload("res://supporting_scripts/databases/armor_db.gd")
var AccessoryDBScript = preload("res://supporting_scripts/databases/accessory_db.gd")
var ItemDBScript = preload("res://supporting_scripts/databases/item_db.gd") 
var ScenarioDBScript = preload("res://supporting_scripts/databases/scenario_db.gd")

var curr_scenario = "testscenario"
var curr_battle = 0
var curr_battle_choice = BattleChoice.OPPONENT1 ## default pick for any battle

func _ready():
	# var textures = TexturePreloadsScript.new()
	# textures.initialize_portraits()
	var wdbs = WeaponDBScript.new()
	wdbs.build_weapon_db()
	var adbs = ArmorDBScript.new()
	adbs.build_armor_db()
	var acdbs = AccessoryDBScript.new()
	acdbs.build_accessory_db()
	var idbs = ItemDBScript.new()
	idbs.build_item_db()
	var cdbs = CharacterDBScript.new()
	cdbs.build_character_db()
	var sdbs = ScenarioDBScript.new()
	sdbs.build_scenario_db()


func update_battle_log(msg=""):
	battle_log.append(msg)
	emit_signal("battle_log_updated", msg)
	

## Utility function to assist generating scenario battle descriptions
func build_rewards_string(gchar:String):
	var toret = str("MONEY: ",characterDB[gchar].money,"\nEXPERIENCE: ",characterDB[gchar].experience_points,"\nITEMS: \n")
	for item in characterDB[gchar].item_belt:
		toret += str("    ",item,"\n")
	return toret



func generate_scenario_battle_descriptions(scenario, id):
	## Initialize description paragraphs
	
	var desc= {}
	
	#for choice in BattleChoice.values():
	var curr = scenarioDB[curr_scenario][id][BattleChoice.OPPONENT1]
	print("value of curr:",curr)
	desc[BattleChoice.OPPONENT1] = {}
	desc[BattleChoice.OPPONENT1]['description'] = str("--DESCRIPTION--\n",characterDB[curr].description) if curr != null else "--DESCRIPTION--\n(no description)" 
	desc[BattleChoice.OPPONENT1]['strategy'] = str("--STRATEGY--\n",characterDB[curr].strategy) if curr != null else "--STRATEGY--\n(no description)" 
	## Get XP and gold rewards from character sheet
	var rewards_str = "-- REWARDS --\n"
	if curr != null:
		rewards_str += build_rewards_string(curr)
	desc[BattleChoice.OPPONENT1]['rewards'] = rewards_str
	
	curr = scenarioDB[curr_scenario][id][BattleChoice.OPPONENT2]
	
	desc[BattleChoice.OPPONENT2] = {}
	desc[BattleChoice.OPPONENT2]['description'] = str("--DESCRIPTION--\n",characterDB[curr].description) if curr != null else "--DESCRIPTION--\n(no description)" 
	desc[BattleChoice.OPPONENT2]['strategy'] = str("--STRATEGY--\n",characterDB[curr].strategy) if curr != null else "--STRATEGY--\n(no description)" 
	## Get XP and gold rewards from character sheet
	rewards_str = "-- REWARDS --\n"
	if curr != null:
		rewards_str += build_rewards_string(curr)
	desc[BattleChoice.OPPONENT2]['rewards'] = rewards_str
	
	curr = scenarioDB[curr_scenario][id][BattleChoice.OPPONENT3]
	
	desc[BattleChoice.OPPONENT3] = {}
	desc[BattleChoice.OPPONENT3]['description'] = str("--DESCRIPTION--\n",characterDB[curr].description) if curr != null else "--DESCRIPTION--\n(no description)" 
	desc[BattleChoice.OPPONENT3]['strategy'] = str("--STRATEGY--\n",characterDB[curr].strategy) if curr != null else "--STRATEGY--\n(no description)" 
	## Get XP and gold rewards from character sheet
	rewards_str = "-- REWARDS --\n"
	if curr != null:
		rewards_str += build_rewards_string(curr)
	desc[BattleChoice.OPPONENT3]['rewards'] = rewards_str
	
	return desc
