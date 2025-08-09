extends Node

class_name Item



var item_name = "None"
var description = "itemdescription"
var consumable = false
var money_value = 0

func _init(iname="None",desc="itemdescription", consume = false):
	item_name=iname
	description=desc
	consumable = consume
