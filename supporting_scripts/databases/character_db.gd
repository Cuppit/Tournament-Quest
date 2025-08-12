extends Node
var db = Global.characterDB
var Attitude = GameCharacter.Attitude # convenience assignment for copypasting from GameCharacter script
var Stat = Global.Stat

func build_character_db():
	print("Global status is: ",Global)
	db["None"]=GameCharacter.new()
	db["Goblin"]=GameCharacter.new("Goblin", \
									{Stat.STR:2,Stat.DEX:4,Stat.CON:2,Stat.INT:1,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1}, \
									"Club", \
									"Jerkin",\
									"Side Satchel",\
									{Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The goblin stands ready.","The goblin shouts \"I'll eat your face!\"","It brandishes it's weapon menacingly.","The goblin is sizing you up."]\
									 ,Attitude.AGGRESSIVE:["The goblin looks ready to charge!","The goblin's shouting a battle cry!","You see a flash of bloodlust in it's eyes!"]\
									 ,Attitude.DEFENSIVE:["It's taking a defensive posture...","The goblin's anticipating your next move!"]\
									 ,Attitude.FAINTING:["The goblin's out of breath!","The goblin's struggling to stand!","It's looking rather weak!"]\
									 ,Attitude.DEFEATED:["The goblin collapses into a heap on the ground!","The goblin gurgles as it falls defeated!","You eradicated that goblin!"]},\
									{},\
									10,\
									10,\
									preload("res://assets/sprites/draft_resources/goblin.png"),\
									"A short, aggressive, green-skinned humanoid.",\
									"-Good at dodging attacks\n-Low HP\n"\
									)
	db["Goblin"].gain_item("Healing Salve")
	db["Goblin"].experience_points = 10
	db["Goblin"].money = 10
	
	db["Fighter"]=GameCharacter.new("Fighter",\
									{Stat.STR:5,Stat.DEX:2,Stat.CON:4,Stat.INT:3,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1},\
									"Greatsword",\
									"Gambeson",\
									"Side Satchel", \
									{Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The warrior stands ready.","The warrior shouts \"I'll beat your face!\"","The fighter brandishes a weapon menacingly.","The fighter is sizing you up."]\
									 ,Attitude.AGGRESSIVE:["The warrior looks ready to charge!","The warrior postures aggressively!","You see a flash of bloodlust in the warrior's eyes!"]\
									 ,Attitude.DEFENSIVE:["A defensive posture's exhibited.","The warrior's anticipating your next move!"]\
									 ,Attitude.FAINTING:["The warrior's out of breath!","The warrior's struggling to stand!","The warrior appears weakened!"]\
									 ,Attitude.DEFEATED:["The warrior collapses into a heap on the ground!","The warrior falls defeated!","You defeated the warrior!"]}\
									,{}, \
									0,\
									0,\
									preload("res://assets/sprites/draft_resources/fighter.png"),
									"A warrior decorated with sturdy armor and a high-quality weapon",
									"a piercing weapon or elemental attacks may overwhelm the tough exterior"
									)

	
	db["Fighter"].unique_abilities["Power Attack"] = 0
	for x in range(5):
		print("IN character_db.gd, giving 'Fighter' five salves.  Adding salve #)",x,":")
		db["Fighter"].gain_item("Useless Item") if x > 2 else null
		db["Fighter"].gain_item("Healing Salve")

	db["Fighter"].gain_item("Shortspear",GameCharacter.InvType.WEAPON)
	db["Fighter"].gain_item("Jerkin",GameCharacter.InvType.ARMOR)
	db["Fighter"].gain_item("Belt of Strength",GameCharacter.InvType.ACCESSORY)
	
	
	

	db["Sage"]=GameCharacter.new("Sage",{Stat.STR:3,Stat.DEX:3,Stat.CON:2,Stat.INT:5,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1},"Greatsword","Gambeson","Side Satchel", \
									{Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The warrior stands ready.","The warrior shouts \"I'll beat your face!\"","The fighter brandishes a weapon menacingly.","The fighter is sizing you up."]\
									 ,Attitude.AGGRESSIVE:["The warrior looks ready to charge!","The warrior postures aggressively!","You see a flash of bloodlust in the warrior's eyes!"]\
									 ,Attitude.DEFENSIVE:["A defensive posture's exhibited.","The warrior's anticipating your next move!"]\
									 ,Attitude.FAINTING:["The warrior's out of breath!","The warrior's struggling to stand!","The warrior appears weakened!"]\
									 ,Attitude.DEFEATED:["The warrior collapses into a heap on the ground!","The warrior falls defeated!","You defeated the warrior!"]}\
									,{}, \
									0,\
									0,\
									preload("res://assets/sprites/draft_resources/wizard.png"),
									"A warrior decorated with sturdy armor and a high-quality weapon",
									"a piercing weapon or elemental attacks may overwhelm the tough exterior"
									)
	
	
	db["Bandit"]=GameCharacter.new("Bandit",{Stat.STR:3,Stat.DEX:5,Stat.CON:4,Stat.INT:3,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1},"Dagger","Gambeson","Side Satchel", \
									{Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The warrior stands ready.","The warrior shouts \"I'll beat your face!\"","The fighter brandishes a weapon menacingly.","The fighter is sizing you up."]\
									 ,Attitude.AGGRESSIVE:["The warrior looks ready to charge!","The warrior postures aggressively!","You see a flash of bloodlust in the warrior's eyes!"]\
									 ,Attitude.DEFENSIVE:["A defensive posture's exhibited.","The warrior's anticipating your next move!"]\
									 ,Attitude.FAINTING:["The warrior's out of breath!","The warrior's struggling to stand!","The warrior appears weakened!"]\
									 ,Attitude.DEFEATED:["The warrior collapses into a heap on the ground!","The warrior falls defeated!","You defeated the warrior!"]}\
									,{}, \
									0,\
									0,\
									preload("res://assets/sprites/draft_resources/bandit.png"),
									"An unscrupulous mercenary specializing in unorthodox tactics",
									"Has a hard time fighting hardy opponents with sturdy armor"
									)
