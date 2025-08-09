extends Node

class_name Weapon

# Whether the weapon is simple or martial
enum WeaponCategory{
	SIMPLE,
	MARTIAL
}

# Properties of the weapon
enum WeaponProperty{
	AMMUNITION,
	CLOSE,
	DEADLY,
	DEFENSIVE,
	FINESSE,
	HEAVY,
	LIGHT,
	LOADING,
	REACH,
	SPECIAL,
	THROWN,
	TWO_HANDED,
	VERSATILE
}

enum DamageType{
	SLASHING,
	PIERCING,
	BLUDGEONING
}

#var stat_bonuses={"str":0,"dex":0,"con":0}

## Modifications to character stats this weapon makes
var stat_mods={}
var weapon_name = "WeaponName"
var weapon_description = "Weapon description"
# var weapon_damage = 1
# var weapon_accuracy = 1
var weapon_dmg_type = DamageType.BLUDGEONING

var weapon_category = WeaponCategory.SIMPLE
var weapon_properties = [WeaponProperty.LIGHT]

var money_value = 0

## Initializer for weapons.
func _init(wname="None", dmg_type = DamageType.BLUDGEONING, desc="Nothing but your bare hands.", stat_bons={}):
	print("CREATING WEAPON: ",wname)
	weapon_name = wname
	weapon_description = desc
	#weapon_damage = dmg
	#weapon_accuracy = acc
	weapon_dmg_type = dmg_type
	stat_mods=stat_bons
