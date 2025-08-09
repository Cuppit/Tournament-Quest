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

var CharacterDBScript = preload("res://supporting_scripts/databases/character_db.gd")
var WeaponDBScript = preload("res://supporting_scripts/databases/weapon_db.gd")
var ArmorDBScript = preload("res://supporting_scripts/databases/armor_db.gd")
var AccessoryDBScript = preload("res://supporting_scripts/databases/accessory_db.gd")
var ItemDBScript = preload("res://supporting_scripts/databases/item_db.gd") 
var ScenarioDBScript = preload("res://supporting_scripts/databases/scenario_db.gd")


func _ready():
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
