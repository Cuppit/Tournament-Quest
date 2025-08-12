"""
A script to hold preloads of all the textures used in the game
"""

extends Node
var char_portrait_fighter = preload("res://assets/sprites/draft_resources/fighter.png")
var char_portrait_sage = preload("res://assets/sprites/draft_resources/wizard.png")
var char_portrait_bandit = preload("res://assets/sprites/draft_resources/bandit.png")
var char_portrait_goblin = preload("res://assets/sprites/draft_resources/goblin.png")

func _ready():
	initialize_portraits()


func initialize_portraits():
	char_portrait_fighter = preload("res://assets/sprites/draft_resources/fighter.png")
	char_portrait_sage = preload("res://assets/sprites/draft_resources/wizard.png")
	char_portrait_bandit = preload("res://assets/sprites/draft_resources/bandit.png")
	char_portrait_goblin = preload("res://assets/sprites/draft_resources/goblin.png")
