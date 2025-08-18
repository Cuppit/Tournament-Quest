extends Node
var db = Global.armorDB
var Stat = Global.Stat

func build_armor_db():
	db["None"]=Armor.new()
	db["Gambeson"]=Armor.new("Gambeson", Armor.ArmorType.LIGHT, "Minimal protection for your person.",{Stat.DMG_REDUC:3})
	db["Jerkin"]=Armor.new("Jerkin", Armor.ArmorType.LIGHT, "A worn jerkin.",{Stat.DMG_REDUC:2})
	db["Chainmail"]=Armor.new("Chainmail", Armor.ArmorType.MEDIUM, "A shirt of linked chains, providing a strong defense.",{Stat.DMG_REDUC:6})
	db["Robe"]=Armor.new("Robe", Armor.ArmorType.LIGHT, "A flowing, loose-fitting garment, allowing slight defense through concealment.",{Stat.EVADE:1,Stat.DMG_REDUC:1})
	db["Crook's Cloak"]=Armor.new("Crook's Cloak", Armor.ArmorType.LIGHT, "A cape with an extra utility pocket inside.",{Stat.EVADE:1,Stat.DMG_REDUC:1,Stat.BELT_CAP:1})
