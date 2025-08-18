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
									GameCharacter.DEFAULT_ACTION_PREFS,\
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
	
	
	db["Wolf"]=GameCharacter.new("Wolf", \
									{Stat.STR:2,Stat.DEX:4,Stat.CON:2,Stat.INT:1,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1}, \
									"Club", \
									"Jerkin",\
									"Side Satchel",\
									{Attitude.NEUTRAL:3,Attitude.AGGRESSIVE:2,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The wolf stands ready.","The wolf growls menacingly!","It bares it's teeth aggressively.","The wolf is sizing you up."]\
									 ,Attitude.AGGRESSIVE:["The wolf looks ready to charge!","You see a flash of bloodlust in it's eyes!"]\
									 ,Attitude.DEFENSIVE:["The wolf barks while taking a step back!","The wolf's anticipating your next move!"]\
									 ,Attitude.FAINTING:["The wolf is panting heavily!","The wolf's starting to whimper while limping!","It's looking rather weak!"]\
									 ,Attitude.DEFEATED:["The wolf collapses into a heap on the ground!","The wolf sobs as it's strength leaves it!","You defeated the wolf!"]},\
									GameCharacter.DEFAULT_ACTION_PREFS,\
									{},\
									10,\
									10,\
									preload("res://assets/sprites/draft_resources/wolf.png"),\
									"A majestic canine, hungry for blood.",\
									"-Good at dodging attacks\n-Low HP\n"\
									)
	db["Goblin"].gain_item("Healing Salve")
	db["Goblin"].experience_points = 10
	db["Goblin"].money = 10
	
	
	db["Prison Guard"]=GameCharacter.new("Prison Guard", \
									{Stat.STR:3,Stat.DEX:3,Stat.CON:3,Stat.INT:1,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1}, \
									"Halberd", \
									"Chainmail",\
									"Side Satchel",\
									{Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The guard stands ready.","The guard's expression betrays *nothing*.","The guard pensively tilts his weapon.","The guard stares, unblinking."]\
									 ,Attitude.AGGRESSIVE:["The guard's grip suddenly clenches!","The guard's preparing a decisive strike!"]\
									 ,Attitude.DEFENSIVE:["The guard squats into a steady stance!","The guard points his weapon at you while leaning back!"]\
									 ,Attitude.FAINTING:["Heavy breathing's coming through the mask!","The guard's clearly in pain!","Trembling, the guard struggles to stay standing!"]\
									 ,Attitude.DEFEATED:["The guard falls down limply!","The guard cries out in pain before collapsing!","You defeated the guard!"]},\
									GameCharacter.DEFAULT_ACTION_PREFS,\
									{},\
									10,\
									10,\
									preload("res://assets/sprites/draft_resources/prisonguard.png"),\
									"A burly prison warden, seasoned by years of guard work.",\
									"-Decent armor, good at resisting blows\n"
									)
	db["Prison Guard"].gain_item("Healing Salve")
	db["Prison Guard"].experience_points = 20
	db["Prison Guard"].money = 20
	
	
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
									,GameCharacter.DEFAULT_ACTION_PREFS\
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
	
	
	

	db["Sage"]=GameCharacter.new("Sage",{Stat.STR:3,Stat.DEX:3,Stat.CON:2,Stat.INT:5,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1},"Staff","Robe","Side Satchel", \
									{Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The warrior stands ready.","The warrior shouts \"I'll beat your face!\"","The fighter brandishes a weapon menacingly.","The fighter is sizing you up."]\
									 ,Attitude.AGGRESSIVE:["The warrior looks ready to charge!","The warrior postures aggressively!","You see a flash of bloodlust in the warrior's eyes!"]\
									 ,Attitude.DEFENSIVE:["A defensive posture's exhibited.","The warrior's anticipating your next move!"]\
									 ,Attitude.FAINTING:["The warrior's out of breath!","The warrior's struggling to stand!","The warrior appears weakened!"]\
									 ,Attitude.DEFEATED:["The warrior collapses into a heap on the ground!","The warrior falls defeated!","You defeated the warrior!"]}\
									,GameCharacter.DEFAULT_ACTION_PREFS\
									,{}, \
									0,\
									0,\
									preload("res://assets/sprites/draft_resources/sage.png"),
									"A warrior decorated with sturdy armor and a high-quality weapon",
									"a piercing weapon or elemental attacks may overwhelm the tough exterior"
									)
	db["Sage"].unique_abilities["Lightning Spark"] = 0
	
	db["Bandit"]=GameCharacter.new("Bandit",{Stat.STR:3,Stat.DEX:5,Stat.CON:4,Stat.INT:3,Stat.WIS:1,Stat.CHA:1,Stat.BELT_CAP:1},"Dagger","Crook's Cloak","Side Satchel", \
									{Attitude.NEUTRAL:4,Attitude.AGGRESSIVE:1,Attitude.DEFENSIVE:1},\
									{Attitude.NEUTRAL:["The warrior stands ready.","The warrior shouts \"I'll beat your face!\"","The fighter brandishes a weapon menacingly.","The fighter is sizing you up."]\
									 ,Attitude.AGGRESSIVE:["The warrior looks ready to charge!","The warrior postures aggressively!","You see a flash of bloodlust in the warrior's eyes!"]\
									 ,Attitude.DEFENSIVE:["A defensive posture's exhibited.","The warrior's anticipating your next move!"]\
									 ,Attitude.FAINTING:["The warrior's out of breath!","The warrior's struggling to stand!","The warrior appears weakened!"]\
									 ,Attitude.DEFEATED:["The warrior collapses into a heap on the ground!","The warrior falls defeated!","You defeated the warrior!"]}\
									,GameCharacter.DEFAULT_ACTION_PREFS\
									,{}, \
									0,\
									0,\
									preload("res://assets/sprites/draft_resources/bandit.png"),
									"An unscrupulous mercenary specializing in unorthodox tactics",
									"Has a hard time fighting hardy opponents with sturdy armor"
									)
