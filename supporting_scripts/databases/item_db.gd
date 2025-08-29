extends Node

var db = Global.itemDB


func build_item_db():
	db["None"] = Item.new()
	db["Healing Salve"] = Item.new("Healing Salve","A bandage treated with a soothing medicine.",true)
	db["Useless Item"] = Item.new("Useless Item","It's just some piece of junk.",true)
	db["Potion of Acid"] = Item.new("Healing Salve","A bandage treated with a soothing medicine.",true)
