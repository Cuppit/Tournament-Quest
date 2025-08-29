extends Node

var db = Global.weaponDB
var Stat = Global.Stat

func build_weapon_db():
	db["None"]=Weapon.new()
	db["Dagger"]=Weapon.new("Dagger", Weapon.DamageType.SLASHING, "A standard six-inch all-purpose blade.",{Stat.ACC:0, Stat.DMG:3})
	db["Club"]=Weapon.new("Club", Weapon.DamageType.BLUDGEONING, "A weapon for applying blunt trauma.",{Stat.ACC:0, Stat.DMG:4})
	db["Shortspear"]=Weapon.new("Shortspear", Weapon.DamageType.PIERCING, "A three-foot pole with a sharp point at the end.",{Stat.ACC:0, Stat.DMG:5})
	db["Greatsword"]=Weapon.new("Greatsword", Weapon.DamageType.SLASHING, "A four-foot long blade.",{Stat.ACC:0, Stat.DMG:6})
	db["Halberd"]=Weapon.new("Halberd", Weapon.DamageType.SLASHING, "An axe-spear combo on a five-foot pole.",{Stat.ACC:0, Stat.DMG:6})
	db["Staff"]=Weapon.new("Staff", Weapon.DamageType.BLUDGEONING, "A shepherd's crook, or possibly a pilgim's walking stick.",{Stat.ACC:0, Stat.DMG:4})
	db["Spike Shield"]=Weapon.new("Spike Shield", Weapon.DamageType.PIERCING, "A board with nails sticking out, fashioned into a basic shield.",{Stat.ACC:0, Stat.DMG:3, Stat.DMG_REDUC:3, Stat.EVADE:2})
