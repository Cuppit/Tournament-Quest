extends Node
var db = Global.armorDB
var Stat = Global.Stat

func build_armor_db():
	db["None"]=Armor.new()
	db["Gambeson"]=Armor.new("Gambeson", Armor.ArmorType.LIGHT, "Minimal protection for your person.",{Stat.DMG_REDUC:3})
	db["Jerkin"]=Armor.new("Jerkin", Armor.ArmorType.LIGHT, "A worn jerkin.",{Stat.DMG_REDUC:1})
