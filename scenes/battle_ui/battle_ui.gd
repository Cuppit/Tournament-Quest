extends Control

var player: GameCharacter
var opponent: GameCharacter
var Stat = Global.Stat

## Run-on logs was causing performance bottlenecks, this prevents that from happening
## by limiting how many logs are allowed to exist
var log_limit = 20

enum BattleState {
	FIGHTING,
	PLAYER_LOST,
	PLAYER_WON
}
var curr_battle_state = BattleState.FIGHTING

enum Turn {
	PLAYER,
	OPPONENT
}

## Tracker variable to see whose turn it currently is
## (Starts on the player's turn by default)
var current_turn = Turn.PLAYER

## Utility function to pass turn
func pass_turn():
	
	## First, check for end of battle
	if player.curr_hp <=0 and opponent.curr_hp <=0:
		update_battle_log(str(player.character_name," and ",opponent.character_name,"have both fallen!"))
		current_turn = Turn.OPPONENT
		curr_battle_state = BattleState.PLAYER_LOST
		update_ui()
		return
	elif player.curr_hp <=0:
		update_battle_log(str(player.character_name," has fallen!"))
		current_turn = Turn.OPPONENT
		curr_battle_state = BattleState.PLAYER_LOST
		process_end_of_battle()
		update_ui()
		return
	elif opponent.curr_hp <=0: 
		print("**DEBUG, battle_ui.gd:pass_turn. Player HP:",player.curr_hp,".  Opponent HP:",opponent.curr_hp,".  Why does this get called even in cases when the player loses!?")
		update_battle_log(str(player.character_name," has defeated ",opponent.character_name," in battle!"))
		current_turn = Turn.OPPONENT
		curr_battle_state = BattleState.PLAYER_WON
		process_end_of_battle()
		update_ui()
		return
	
	## Having checked for 'end of battle', now pass turn as appropriate: 
	
	if current_turn == Turn.PLAYER: 
		current_turn = Turn.OPPONENT
		opponent.process_turn("",player)
		opponent.decrement_cooldowns()
		pass_turn()
		update_ui()
	else:
		current_turn = Turn.PLAYER
		player.decrement_cooldowns()
		update_ui()


func update_battle_log(msg=""):
	if msg != "": 
		Global.update_battle_log(msg)
	## clear log before re-filling
	$Background/VBoxContainer/InfoBox/BattleLog.text = ""
	for x in Global.battle_log:
		$Background/VBoxContainer/InfoBox/BattleLog.text += (x+'\n')
		
	## Trim the log if it's growing out of hand
	if len(Global.battle_log) > log_limit:
		Global.battle_log.remove_at(0)

## Code for processing a victorious outcome in the battle.
func process_end_of_battle():
	var rewardsmsg = ""
	if curr_battle_state == BattleState.PLAYER_WON:
		rewardsmsg = str("[type speed=40]VICTORY!\n\n")
		rewardsmsg += str(" You gain ",opponent.experience_points," experience points!\n\n")
		if opponent.money > 0:
			rewardsmsg += str("You find ",opponent.money," money on the opponent.\n\n")
		if len(opponent.item_belt) > 0:
			rewardsmsg += str("You find the following items on the opponent:\n")
			for item in opponent.item_belt:
				rewardsmsg += str("-",item,"\n")
			
		## Give player the appropriate rewards
		print("PLAYER EXPERIENCE POINTS:",player.experience_points)
		
		if player.experience_points == null:
			player.experience_points = 0
		player.experience_points += opponent.experience_points
		player.money += opponent.money
		for item in opponent.item_belt:
			player.gain_item(item)
		
		
	
	if curr_battle_state == BattleState.PLAYER_LOST:
		rewardsmsg = str("DEFEAT!\n\n")
		rewardsmsg += str("That's the end.")
	## Update text of node
	$Background/VBoxContainer/HBoxContainer/vbEndOfBattleMsgs/rtlRewardsMsg.text=rewardsmsg			
	


## Check and update all features of the UI
## TODO 20250811: Separate game logic (e.g. player stats updates) fro
func update_ui():
	
	## Handling UI changes on victory of battle
	#if curr_battle_state == BattleState.PLAYER_WON:
		

	## -- Display or hide "End Battle" button depending on the state of the battle
	$Background/VBoxContainer/HBoxContainer/vbEndOfBattleMsgs.visible = true if ((curr_battle_state == BattleState.PLAYER_LOST) or (curr_battle_state == BattleState.PLAYER_WON)) else false
	
	
	## --- UPDATING PLAYER INFORMATION ---
	# Update player's name
	$Background/VBoxContainer/HBoxContainer/PlayerUI/Name.text = player.character_name
	
	
	# Update player's current HP
	$Background/VBoxContainer/HBoxContainer/PlayerUI/CurrentHP.text = str("HP: ",player.curr_hp,"/",player.get_stat(Stat.MAX_HP))
	
	# Update player's current MP
	$Background/VBoxContainer/HBoxContainer/PlayerUI/CurrentMP.text = str("MP: ",player.curr_mp,"/",player.get_stat(Stat.MAX_MP))
	# Update player's health bar
	$Background/VBoxContainer/HBoxContainer/PlayerUI/HealthBar.max_value = player.get_stat(Stat.MAX_HP)
	$Background/VBoxContainer/HBoxContainer/PlayerUI/HealthBar.value = player.curr_hp
	
	# Update player's mana bar
	$Background/VBoxContainer/HBoxContainer/PlayerUI/ManaBar.max_value = player.get_stat(Stat.MAX_MP)
	$Background/VBoxContainer/HBoxContainer/PlayerUI/ManaBar.value = player.curr_mp
	
	
	# Update whether the player's buttons are clickable
	$Background/VBoxContainer/HBoxContainer/PlayerUI/BtnAttack.disabled=false if current_turn==Turn.PLAYER else true
	$Background/VBoxContainer/HBoxContainer/PlayerUI/BtnGuard.disabled=false if current_turn==Turn.PLAYER else true
	$Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.disabled = false if current_turn == Turn.PLAYER else true
	$Background/VBoxContainer/HBoxContainer/PlayerUI/BtnItem.disabled=false if current_turn==Turn.PLAYER else true
	
	
	## --- UPDATING OPPONENT INFORMATION ---
	# Update opponent's name
	$Background/VBoxContainer/HBoxContainer/OpponentUI/Name.text = opponent.character_name
	
	# Update opponent's current HP TODO 20250719: decide whether to display opponent HP and/or what conditions to do so under
	#$Background/VBoxContainer/HBoxContainer/OpponentUI/CurrentHP.text = str("HP: ",opponent.curr_hp,"/",opponent.get_stat(Stat.MAX_HP))
	# Update opponent's health bar
	$Background/VBoxContainer/HBoxContainer/OpponentUI/HealthBar.max_value = opponent.get_stat(Stat.MAX_HP)
	$Background/VBoxContainer/HBoxContainer/OpponentUI/HealthBar.value = opponent.curr_hp
	
	print(opponent.get_battle_msg()," ...current attitude:",opponent.current_attitude)
	$Background/VBoxContainer/HBoxContainer/OpponentUI/OpponentDescription.text = opponent.get_battle_msg()
	update_battle_log()
	

func _ready():

	var params = GGT.get_current_scene_data().params

	## Reset room variables as necessary
	curr_battle_state = BattleState.FIGHTING
	
	## TODO 20250727: if it's ever possible for the enemy to go first, ensure 
	## a proper check to see who goes first is established for this flag.
	## Otherwise, the game is currently designed such that the player always 
	## goes first.
	current_turn = Turn.PLAYER
	
	print("setting up characters for upcoming fight:")
	
	## If actual parameters were passed for player/opponent, use those
	if params != {}:
		player = params.player_character
		
		print("in MAIN_GAME_UI DEBUGGING: trying to clone '",params.get("opponent").character_name,"':")
		print(params.get("opponent").character_name," has these msgs: ",params.get("opponent").attitude_msgs)
		
		opponent = params.opponent
		
	## Otherwise, use this placeholder data for scene testing
	else: 
		player = GameCharacter.new("Devon",{Stat.STR:3,Stat.DEX:3,Stat.CON:3,Stat.INT:3,Stat.BELT_CAP:3},"Club","Jerkin","Side Sachel")
		player.equipped_weapon = "Dagger"
		player.equipped_accessory = "Side Sachel"
		player.gain_item("Healing Salve")
		player.print_health()
		opponent = Global.clone_character(Global.characterDB.get("Goblin", Global.characterDB["None"]))


	## In case the scene was re-entered, reset current turn
	current_turn = Turn.PLAYER
	
	$Background/VBoxContainer/HBoxContainer/PlayerUI/trPlayerPortrait.texture = player.character_portrait
	$Background/VBoxContainer/HBoxContainer/OpponentUI/trOpponentPortrait.texture = opponent.character_portrait
	# make an initial update to the UI
	update_ui()
	
	
func _on_btn_attack_pressed():
	player.process_turn("attack", opponent)
	update_battle_log()
	pass_turn()
	pass # Replace with function body.


func _on_btn_guard_pressed():
	player.process_turn("guard")
	pass_turn()


func _on_battle_log_updated():
	## clear log before re-filling
	$Background/VBoxContainer/InfoBox/BattleLog.text += str("[type]",Global.battle_log[-1])
	#for x in Global.battle_log:
#		$Background/VBoxContainer/InfoBox/BattleLog.text += (x+'\n')


## Populate MenuButton with player's items on player character's item belt
func _on_btn_item_about_to_popup():
	$Background/VBoxContainer/HBoxContainer/PlayerUI/BtnItem.get_popup().clear()
	var id=0
	for item in player.item_belt:
		$Background/VBoxContainer/HBoxContainer/PlayerUI/BtnItem.get_popup().add_item(item,id)
		id +=1 
	$Background/VBoxContainer/HBoxContainer/PlayerUI/BtnItem.get_popup().id_pressed.connect(_on_item_selected)
	print('PLAYER ITEM MENU POPPING UP')


func _on_item_selected(id : int) -> void:
	var itemname = $Background/VBoxContainer/HBoxContainer/PlayerUI/BtnItem.get_popup().get_item_text(id)
	print("USING ITEM.  ITEM SELECTED: '",itemname,"'")
	player.process_turn("use_item", player, itemname)
	pass_turn()


func _on_btn_end_battle_pressed():
	## Clear battle log after every battle
	Global.battle_log=[""]
	var params = {
		"char_to_manage": player
	}
	
	if curr_battle_state == BattleState.PLAYER_WON:
		GGT.change_scene("res://scenes/charactermanagement/character_management.tscn", params)
	elif curr_battle_state == BattleState.PLAYER_LOST:
		GGT.change_scene("res://scenes/menu/menu.tscn", params)


func _on_mbtn_abilities_about_to_popup():
	$Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.get_popup().clear()
	var id=0
	for ability in player.unique_abilities.keys():
		$Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.get_popup().add_item(ability,id)
		if not player.can_activate(ability):
			$Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.get_popup().set_item_disabled(id, true)
			#$Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.get_popup().set_item_text(id, str(ability," (Cooldown: ",player.unique_abilities[ability]," turns)"))
			$Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.get_popup().set_item_text(id, str(ability,player.get_abi_act_impediments_as_str(ability)))
		id +=1 
	$Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.get_popup().id_pressed.connect(_on_ability_selected)
	print('PLAYER ABILITIES MENU POPPING UP')
	

func _on_ability_selected(id : int):
	var abilityname = $Background/VBoxContainer/HBoxContainer/PlayerUI/mbtnAbilities.get_popup().get_item_text(id)
	print("USING ABILITY. ABILITY SELECTED: '",abilityname,"'")
	player.process_turn(abilityname, opponent)
	pass_turn()
