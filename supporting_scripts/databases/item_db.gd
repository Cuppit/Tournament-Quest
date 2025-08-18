extends Node

var db = Global.itemDB


func build_item_db():
	db["None"] = Item.new()
	db["Healing Salve"] = Item.new()
