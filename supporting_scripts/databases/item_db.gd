extends Node

var db = Global.weaponDB


func build_item_db():
	db["None"] = Item.new()
